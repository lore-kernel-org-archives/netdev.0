From: David Laight <David.Laight@ACULAB.COM>
Subject: RE: [next-queue PATCH v7 4/6] net/sched: Introduce Credit Based
 Shaper (CBS) qdisc
Date: Mon, 16 Oct 2017 09:14:11 +0000
Message-ID: <063D6719AE5E284EB5DD2968C1650D6DD00979BC@AcuExch.aculab.com>
References: <20171013004005.17416-1-vinicius.gomes@intel.com>
 <20171013004005.17416-5-vinicius.gomes@intel.com>
 <20171013195924.GA19439@khorivan>
Mime-Version: 1.0
Content-Type: text/plain; charset="Windows-1252"
Content-Transfer-Encoding: 8BIT
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "intel-wired-lan@lists.osuosl.org" <intel-wired-lan@lists.osuosl.org>,
        "jhs@mojatatu.com" <jhs@mojatatu.com>,
        "xiyou.wangcong@gmail.com" <xiyou.wangcong@gmail.com>,
        "jiri@resnulli.us" <jiri@resnulli.us>,
        "andre.guedes@intel.com" <andre.guedes@intel.com>,
        "ivan.briano@intel.com" <ivan.briano@intel.com>,
        "jesus.sanchez-palencia@intel.com" <jesus.sanchez-palencia@intel.com>,
        "boon.leong.ong@intel.com" <boon.leong.ong@intel.com>,
        "richardcochran@gmail.com" <richardcochran@gmail.com>,
        "henrik@austad.us" <henrik@austad.us>,
        "levipearson@gmail.com" <levipearson@gmail.com>,
        "rodney.cummings@ni.com" <rodney.cummings@ni.com>
To: 'Ivan Khoronzhuk' <ivan.khoronzhuk@linaro.org>,
        Vinicius Costa Gomes <vinicius.gomes@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out4.electric.net ([192.162.216.195]:54067 "EHLO
        smtp-out4.electric.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750914AbdJPJOV (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 16 Oct 2017 05:14:21 -0400
In-Reply-To: <20171013195924.GA19439@khorivan>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ivan Khoronzhuk
> Sent: 13 October 2017 20:59
> On Thu, Oct 12, 2017 at 05:40:03PM -0700, Vinicius Costa Gomes wrote:
> > This queueing discipline implements the shaper algorithm defined by
> > the 802.1Q-2014 Section 8.6.8.2 and detailed in Annex L.
> >
> > It's primary usage is to apply some bandwidth reservation to user
> > defined traffic classes, which are mapped to different queues via the
> > mqprio qdisc.
> >
> > Only a simple software implementation is added for now.
> >
> > Signed-off-by: Vinicius Costa Gomes <vinicius.gomes@intel.com>
> > Signed-off-by: Jesus Sanchez-Palencia <jesus.sanchez-palencia@intel.com>
> > ---
> >  include/uapi/linux/pkt_sched.h |  18 +++
> >  net/sched/Kconfig              |  11 ++
> >  net/sched/Makefile             |   1 +
> >  net/sched/sch_cbs.c            | 314 +++++++++++++++++++++++++++++++++++++++++
> >  4 files changed, 344 insertions(+)
> >  create mode 100644 net/sched/sch_cbs.c
> >
> > diff --git a/include/uapi/linux/pkt_sched.h b/include/uapi/linux/pkt_sched.h
> > index 099bf5528fed..41e349df4bf4 100644
> > --- a/include/uapi/linux/pkt_sched.h
> > +++ b/include/uapi/linux/pkt_sched.h
> > @@ -871,4 +871,22 @@ struct tc_pie_xstats {
> >  	__u32 maxq;             /* maximum queue size */
> >  	__u32 ecn_mark;         /* packets marked with ecn*/
> >  };
> > +
> > +/* CBS */
> > +struct tc_cbs_qopt {
> > +	__u8 offload;

You probably don't want unnamed padding in a uapi structure.

> > +	__s32 hicredit;
> > +	__s32 locredit;
> > +	__s32 idleslope;
> > +	__s32 sendslope;
> > +};
> > +
> > +enum {
> > +	TCA_CBS_UNSPEC,
> > +	TCA_CBS_PARMS,
> > +	__TCA_CBS_MAX,
> > +};
> > +
> > +#define TCA_CBS_MAX (__TCA_CBS_MAX - 1)

Why not:
	TCA_CBS_PARMS,
	TCA_CBS_NEXT,
	TCA_CBS_MAX = TCA_CBS_NEXT - 1,

...
	David
