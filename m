From: Jens Laas <jens.laas@data.slu.se>
Subject: Re: non-NAPI mode question netif_rx_schedule()
Date: Thu, 15 Apr 2004 10:16:46 +0200 (CEST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <Pine.LNX.4.58.0404151015230.1660@jlaas2.data.slu.se>
References: <C6F5CF431189FA4CBAEC9E7DD5441E0102CBDF32@orsmsx402.jf.intel.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "Feldman, Scott" <scott.feldman@intel.com>
In-Reply-To: <C6F5CF431189FA4CBAEC9E7DD5441E0102CBDF32@orsmsx402.jf.intel.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

(04.04.14 kl.21:44) Feldman, Scott skrev f=F6ljande till netdev@oss.sgi.c=
om:

> Hi,

> this time the check for __LINK_STATE_RX_SCHED fails because RX_SOFTIRQ
> is already running on CPU0.  This means we've put work on the CPU1's
> backlog queue, but we don't start the RX_SOFTIRQ on CPU1.  :-(
>
> So the work on CPU1's backlog queue is stuck.  It'll get started if 1)
> we get another hard interrupt on CPU1, and 2) no other CPUs are running
> their RX_SOFTIRQ.
>
> This could cause unnecessary Rx packet ordering issues as well as
> potentially leaving work pending on a CPU for some time.
>
> What am I missing?

__LINK_STATE_RX_SCHED is set on queue->backlog_dev not on the "real"
netdev.

The backlog_dev is per queue and thus per CPU.

Cheers,
Jens

>
> -scott
>
>
>

-----------------------------------------------------------------------
    'This mail automatically becomes portable when carried.'
-----------------------------------------------------------------------
    Jens L=E5=E5s                              Email: jens.laas@data.slu.=
se
    Department of Computer Services, SLU   Phone: +46 18 67 35 15
    Vindbrov=E4gen 1
    P.O. Box 7079
    S-750 07 Uppsala
    SWEDEN
-----------------------------------------------------------------------
