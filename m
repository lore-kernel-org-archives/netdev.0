From: Dave Peterson <dsp@llnl.gov>
Subject: Re: possible bug in net/core/pktgen.c (2.6.10 kernel)
Date: Tue, 18 Jan 2005 13:46:22 -0800
Message-ID: <200501181346.22905.dsp@llnl.gov>
References: <200501141129.21461.dsp@llnl.gov> <200501180935.25419.dsp@llnl.gov> <20050118124100.17b7f47a.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Robert.Olsson@data.slu.se, robert.olsson@its.uu.se, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@davemloft.net>
In-Reply-To: <20050118124100.17b7f47a.davem@davemloft.net>
Content-Disposition: inline
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Tuesday 18 January 2005 12:41 pm, David S. Miller wrote:
> I'm still a little bit confused on this one.
>
> Since when does do_softirq() need preemption disabled
> around calls to it?
>
> do_softirq() disabled hard IRQs during the duration of it's
> execution, thus effectively disabling preemption.
>
> What is the problematic case again?

Oops... My mistake.  Looking at __do_softirq() I noticed that it enables
interrupts before executing the softirqs.  However I didn't notice that
the call to local_bh_disable() in __do_softirq() disables preemption
before interrupts are enabled.  On second thought everything looks OK
and no bug fix is needed.


Dave
