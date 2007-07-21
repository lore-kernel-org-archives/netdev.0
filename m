From: Krishna Kumar2 <krkumar2@in.ibm.com>
Subject: [ofa-general] Re: [PATCH 03/10] dev.c changes.
Date: Sat, 21 Jul 2007 12:14:12 +0530
Message-ID: <OF2F4CD3AD.13BD72EC-ON6525731F.00242872-6525731F.002501AC@in.ibm.com>
References: <1184953459.12431.21.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Cc: jagana@us.ibm.com, johnpol@2ka.mipt.ru, herbert@gondor.apana.org.au,
	gaagaan@gmail.com, Robert.Olsson@data.slu.se,
	kumarkr@linux.ibm.com, mcarlson@broadcom.com,
	peter.p.waskiewicz.jr@intel.com, hadi@cyberus.ca,
	kaber@trash.net, jeff@garzik.org, general@lists.openfabrics.org,
	mchan@broadcom.com, tgraf@suug.ch, netdev@vger.kernel.org,
	davem@davemloft.net, rdreier@cisco.com
To: Sridhar Samudrala <sri@us.ibm.com>
Return-path: <general-bounces@lists.openfabrics.org>
In-Reply-To: <1184953459.12431.21.camel@localhost.localdomain>
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

Hi Sridhar,

Sridhar Samudrala <sri@us.ibm.com> wrote on 07/20/2007 11:14:19 PM:

> > @@ -1566,7 +1605,7 @@ gso:
> >           /* reset queue_mapping to zero */
> >           skb->queue_mapping = 0;
> >           rc = q->enqueue(skb, q);
> > -         qdisc_run(dev);
> > +         qdisc_run(dev, NULL);
>
> OK. So you are passing a NULL blist here. However, i am
> not sure why batching is not used in this situation.

Actually it could be used, but in most cases there will be only
one skb. If I pass the blist here, the result (for batching
case) will be to put one single skb into the blist and call
the new xmit API. That wastes cycles as we take a skb out
from the queue (as in regular code) and then add it to the
blist (different in the new code) and then the driver has to
remove this skb from the blist (different in the new code).
I could try batching but then require there are more than
1 skbs before adding to the blist (or the blist doesn't already
have skbs, in which case adding even one skb makes sense). Also,
it will have a slight impact for regular drivers where for each
xmit, one extra dereference for dev->skb_blist (which is always
NULL) is made, which was another reason to always pass NULL.

I will check what the results are by giving passing blist here
too and make the above change. I will run tests for that (as
well as NETPERF RR test as asked by Evgeniy).

Thanks,

- KK
