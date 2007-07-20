From: Krishna Kumar2 <krkumar2@in.ibm.com>
Subject: [ofa-general] Re: [PATCH 05/10] sch_generic.c changes.
Date: Fri, 20 Jul 2007 16:02:42 +0530
Message-ID: <OF9D893096.26B48226-ON6525731E.003999A1-6525731E.0039ED23@in.ibm.com>
References: <46A08A35.5090104@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Cc: jagana@us.ibm.com, johnpol@2ka.mipt.ru, herbert@gondor.apana.org.au,
	gaagaan@gmail.com, Robert.Olsson@data.slu.se,
	kumarkr@linux.ibm.com, rdreier@cisco.com,
	peter.p.waskiewicz.jr@intel.com, hadi@cyberus.ca,
	mcarlson@broadcom.com, jeff@garzik.org,
	general@lists.openfabrics.org, mchan@broadcom.com, tgraf@suug.ch,
	netdev@vger.kernel.org, davem@davemloft.net, sri@us.ibm.com
To: Patrick McHardy <kaber@trash.net>
Return-path: <general-bounces@lists.openfabrics.org>
In-Reply-To: <46A08A35.5090104@trash.net>
List-Unsubscribe: <http://lists.openfabrics.org/cgi-bin/mailman/listinfo/general>,
	<mailto:general-request@lists.openfabrics.org?subject=unsubscribe>
List-Archive: <http://lists.openfabrics.org/pipermail/general>
List-Post: <mailto:general@lists.openfabrics.org>
List-Help: <mailto:general-request@lists.openfabrics.org?subject=help>
List-Subscribe: <http://lists.openfabrics.org/cgi-bin/mailman/listinfo/general>,
	<mailto:general-request@lists.openfabrics.org?subject=subscribe>
Sender: general-bounces@lists.openfabrics.org
Errors-To: general-bounces@lists.openfabrics.org
List-Id: netdev.vger.kernel.org

Patrick McHardy <kaber@trash.net> wrote on 07/20/2007 03:41:01 PM:

> Krishna Kumar wrote:
> > diff -ruNp org/net/sched/sch_generic.c new/net/sched/sch_generic.c
> > --- org/net/sched/sch_generic.c   2007-07-20 07:49:28.000000000 +0530
> > +++ new/net/sched/sch_generic.c   2007-07-20 08:30:22.000000000 +0530
> > @@ -9,6 +9,11 @@
> >   * Authors:   Alexey Kuznetsov, <kuznet@ms2.inr.ac.ru>
> >   *              Jamal Hadi Salim, <hadi@cyberus.ca> 990601
> >   *              - Ingress support
> > + *
> > + * New functionality:
> > + *      Krishna Kumar, <krkumar2@in.ibm.com>, July 2007
> > + *      - Support for sending multiple skbs to devices that support
> > + *        new api - dev->hard_start_xmit_batch()
>
>
> No new changelogs in source code please, git keeps track of that.

Ah, didn't know this, thanks for letting me know.

> > -static inline int qdisc_restart(struct net_device *dev)
> > +static inline int qdisc_restart(struct net_device *dev,
> > +            struct sk_buff_head *blist)
> >  {
> >     struct Qdisc *q = dev->qdisc;
> >     struct sk_buff *skb;
> > -   unsigned lockless;
> > +   unsigned getlock;      /* whether we need to get lock or not */
>
>
> Unrelated rename, please get rid of this to reduce the noise.

OK, I guess I should have sent that change earlier :) The reason to change
the name is to avoid (double-negative) checks like :

      if (!lockless)
to
      if (getlock).

I will remove these changes.

thanks,

- KK
