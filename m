From: Dave Peterson <dsp@llnl.gov>
Subject: Re: possible bug in net/core/pktgen.c (2.6.10 kernel)
Date: Tue, 18 Jan 2005 09:35:25 -0800
Message-ID: <200501180935.25419.dsp@llnl.gov>
References: <200501141129.21461.dsp@llnl.gov> <16874.25146.335366.990655@robur.slu.se>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: robert.olsson@its.uu.se, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Robert Olsson <Robert.Olsson@data.slu.se>
In-Reply-To: <16874.25146.335366.990655@robur.slu.se>
Content-Disposition: inline
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Sunday 16 January 2005 04:46 am, Robert Olsson wrote:
> Dave Peterson writes:
>  > I found a piece of code that looks problematic in the 2.6.10 kernel.
>  > The following code appears starting on line 746 in function inject()
>  > of net/core/pktgen.c:
>  >                                         schedule();
>  >                                 else
>  >                                         do_softirq();
>
>  Thanks!
>  So it should be?

Cool!  Looks like a fix to me.

> --- net/core/pktgen.c.orig	2005-01-16 13:39:10.933427120 +0100
> +++ net/core/pktgen.c	2005-01-16 13:40:41.926751672 +0100
> @@ -753,8 +753,11 @@
>  				}
>  				if (need_resched())
>  					schedule();
> -				else
> +				else {
> +					preempt_disable();
>  					do_softirq();
> +					preempt_enable();
> +				}
>  			} while (netif_queue_stopped(odev));
>  			idle = cycles() - idle_start;
>  			info->idle_acc += idle;
>
>
>
> 						--ro
