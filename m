From: Hannes Eder <hannes@hanneseder.net>
Subject: Re: [PATCH 31/43 v2] drivers/net/tokenring: fix sparse warning: cast
	truncates bits from const value
Date: Mon, 16 Feb 2009 18:29:15 +0100
Message-ID: <154e089b0902160929v617ed7d6o963da936b35ef7fb@mail.gmail.com>
References: <154e089b0902150347o4e06683dy1c9c02dc2564ea4f@mail.gmail.com>
	 <20090215121201.26072.42971.stgit@vmbox.hanneseder.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: kernel-janitors@vger.kernel.org, linux-kernel@vger.kernel.org,
	Jay Schulist <jjschlst@gmail.com>,
	Al Viro <viro@zeniv.linux.org.uk>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from fg-out-1718.google.com ([72.14.220.154]:5664 "EHLO
	fg-out-1718.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751095AbZBPR3R (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 16 Feb 2009 12:29:17 -0500
In-Reply-To: <20090215121201.26072.42971.stgit@vmbox.hanneseder.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Feb 15, 2009 at 1:13 PM, Hannes Eder <hannes@hanneseder.net> wrote:
> Impact: Remove the write-only field 'current_ring_status' completely.
>
> Fix this sparse warnings:
>  drivers/net/tokenring/smctr.c:4410:52: warning: cast truncates bits from constant value (100 becomes 0)
>  drivers/net/tokenring/smctr.c:4415:52: warning: cast truncates bits from constant value (400 becomes 0)
>  drivers/net/tokenring/smctr.c:4420:52: warning: cast truncates bits from constant value (800 becomes 0)
>  drivers/net/tokenring/smctr.c:4425:52: warning: cast truncates bits from constant value (1000 becomes 0)
>  drivers/net/tokenring/smctr.c:4430:52: warning: cast truncates bits from constant value (2000 becomes 0)
>  drivers/net/tokenring/smctr.c:4435:52: warning: cast truncates bits from constant value (4000 becomes 0)
>  drivers/net/tokenring/smctr.c:4440:52: warning: cast truncates bits from constant value (8000 becomes 0)
>
> Signed-off-by: Hannes Eder <hannes@hanneseder.net>
> ---
>  drivers/net/tokenring/smctr.c |   10 ----------
>  drivers/net/tokenring/smctr.h |    1 -
>  2 files changed, 0 insertions(+), 11 deletions(-)
>
> diff --git a/drivers/net/tokenring/smctr.c b/drivers/net/tokenring/smctr.c
> index 5a3ff20..e66eb8a 100644
> --- a/drivers/net/tokenring/smctr.c
> +++ b/drivers/net/tokenring/smctr.c
> @@ -4393,52 +4393,42 @@ static int smctr_ring_status_chg(struct net_device *dev)
>         {
>                 case RING_RECOVERY:
>                         printk(KERN_INFO "%s: Ring Recovery\n", dev->name);
> -                        tp->current_ring_status |= RING_RECOVERY;
>                         break;
>
>                 case SINGLE_STATION:
>                         printk(KERN_INFO "%s: Single Statinon\n", dev->name);
> -                        tp->current_ring_status |= SINGLE_STATION;
>                         break;
>
>                 case COUNTER_OVERFLOW:
>                         printk(KERN_INFO "%s: Counter Overflow\n", dev->name);
> -                        tp->current_ring_status |= COUNTER_OVERFLOW;
>                         break;
>
>                 case REMOVE_RECEIVED:
>                         printk(KERN_INFO "%s: Remove Received\n", dev->name);
> -                        tp->current_ring_status |= REMOVE_RECEIVED;
>                         break;
>
>                 case AUTO_REMOVAL_ERROR:
>                         printk(KERN_INFO "%s: Auto Remove Error\n", dev->name);
> -                        tp->current_ring_status |= AUTO_REMOVAL_ERROR;
>                         break;
>
>                 case LOBE_WIRE_FAULT:
>                         printk(KERN_INFO "%s: Lobe Wire Fault\n", dev->name);
> -                        tp->current_ring_status |= LOBE_WIRE_FAULT;
>                         break;
>
>                 case TRANSMIT_BEACON:
>                         printk(KERN_INFO "%s: Transmit Beacon\n", dev->name);
> -                        tp->current_ring_status |= TRANSMIT_BEACON;
>                         break;
>
>                 case SOFT_ERROR:
>                         printk(KERN_INFO "%s: Soft Error\n", dev->name);
> -                        tp->current_ring_status |= SOFT_ERROR;
>                         break;
>
>                 case HARD_ERROR:
>                         printk(KERN_INFO "%s: Hard Error\n", dev->name);
> -                        tp->current_ring_status |= HARD_ERROR;
>                         break;
>
>                 case SIGNAL_LOSS:
>                         printk(KERN_INFO "%s: Signal Loss\n", dev->name);
> -                        tp->current_ring_status |= SIGNAL_LOSS;
>                         break;
>
>                 default:
> diff --git a/drivers/net/tokenring/smctr.h b/drivers/net/tokenring/smctr.h
> index 52df7dd..6e5700a 100644
> --- a/drivers/net/tokenring/smctr.h
> +++ b/drivers/net/tokenring/smctr.h
> @@ -977,7 +977,6 @@ typedef struct net_local {
>        __u8            monitor_state_ready;
>        __u16           ring_status;
>        __u8            ring_status_flags;
> -       __u8            current_ring_status;
>        __u8            state;
>
>        __u8            join_state;
>
>

forwarding a mail from Jay Schulist:

On Mon, Feb 16, 2009 at 4:17 PM, Jay Schulist <jjschlst@gmail.com> wrote:
> Hello,
> I'm at this email these days. That field was likely a hold-over from
> the original port of their windows driver to Linux, it has never been
> used that I know of. Removing it looks like a fine solution to me.
>
> Jay
