From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [PATCH] pkt_sched: QFQ Plus: fair-queueing service at DRR cost
Date: Tue, 20 Nov 2012 09:53:04 -0800
Message-ID: <20121120095304.420ded7c@nehalam.linuxnetplumber.net>
References: <20121112164833.GA12970@paolo-ThinkPad-W520>
	<20121119.184828.628106002307042971.davem@davemloft.net>
	<50ABC19E.9030209@unimore.it>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-7
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, jhs@mojatatu.com,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	rizzo@iet.unipi.it, fchecconi@gmail.com
To: Paolo Valente <paolo.valente@unimore.it>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <50ABC19E.9030209@unimore.it>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 20 Nov 2012 18:45:02 +0100
Paolo Valente <paolo.valente@unimore.it> wrote:

> Il 20/11/2012 00:48, David Miller ha scritto:
> > From: Paolo Valente <paolo.valente@unimore.it>
> > Date: Mon, 12 Nov 2012 17:48:33 +0100
> >
> >> [This patch received positive feedback from Stephen Hemminger ("pu=
t in
> >> net-next"), but no further feedback or decision. So I am (re)sendi=
ng
> >> an updated version of it. The only differences with respect to the
> >> previous version are the support for TSO/GSO (taken from QFQ), and=
 a
> >> hopefully improved description.]
> >
> > Can you rearrange the logic so that the compiler doesn't emit this
> > warning?
> >
> > In file included from net/sched/sch_qfq.c:18:0:
> > net/sched/sch_qfq.c: In function =A1qfq_dequeue=A2:
> > include/net/sch_generic.h:480:15: warning: =A1skb=A2 may be used un=
initialized in this function [-Wmaybe-uninitialized]
> > net/sched/sch_qfq.c:1007:18: note: =A1skb=A2 was declared here
> >
> > You and I both know that SKB will be initialized at this point, but
> > the compiler can't see it clearly enough.
> >
> Unfortunately I could not reproduce the warning (with
> gcc-4.7 -Wmaybe-uninitialized). I am however about to send a new vers=
ion=20
> with skb initialized to NULL. I hope that this fix properly addresses=
=20
> this issue.

There are actually lots of bogus warnings than seem to only occur
because gcc 4.4 does a bad job of checking. Later versions are fixed
and don't generate warnings.

My preference is to not add the unnecessary initialization because
if you get in the habit of doing it. The whole purpose of the uninitial=
ized
check is lost.=20
