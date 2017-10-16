From: Vinicius Costa Gomes <vinicius.gomes@intel.com>
Subject: RE: [next-queue PATCH v7 4/6] net/sched: Introduce Credit Based Shaper (CBS) qdisc
Date: Mon, 16 Oct 2017 15:13:12 -0700
Message-ID: <87376in3lz.fsf@intel.com>
References: <20171013004005.17416-1-vinicius.gomes@intel.com> <20171013004005.17416-5-vinicius.gomes@intel.com> <20171013195924.GA19439@khorivan> <063D6719AE5E284EB5DD2968C1650D6DD00979BC@AcuExch.aculab.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: "netdev\@vger.kernel.org" <netdev@vger.kernel.org>,
        "intel-wired-lan\@lists.osuosl.org"
        <intel-wired-lan@lists.osuosl.org>,
        "jhs\@mojatatu.com" <jhs@mojatatu.com>,
        "xiyou.wangcong\@gmail.com" <xiyou.wangcong@gmail.com>,
        "jiri\@resnulli.us" <jiri@resnulli.us>,
        "andre.guedes\@intel.com" <andre.guedes@intel.com>,
        "ivan.briano\@intel.com" <ivan.briano@intel.com>,
        "jesus.sanchez-palencia\@intel.com"
        <jesus.sanchez-palencia@intel.com>,
        "boon.leong.ong\@intel.com" <boon.leong.ong@intel.com>,
        "richardcochran\@gmail.com" <richardcochran@gmail.com>,
        "henrik\@austad.us" <henrik@austad.us>,
        "levipearson\@gmail.com" <levipearson@gmail.com>,
        "rodney.cummings\@ni.com" <rodney.cummings@ni.com>
To: David Laight <David.Laight@ACULAB.COM>,
        'Ivan Khoronzhuk' <ivan.khoronzhuk@linaro.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:13655 "EHLO mga09.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1755918AbdJPWNN (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 16 Oct 2017 18:13:13 -0400
In-Reply-To: <063D6719AE5E284EB5DD2968C1650D6DD00979BC@AcuExch.aculab.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi David,

David Laight <David.Laight@ACULAB.COM> writes:

[...]

>> > index 099bf5528fed..41e349df4bf4 100644
>> > --- a/include/uapi/linux/pkt_sched.h
>> > +++ b/include/uapi/linux/pkt_sched.h
>> > @@ -871,4 +871,22 @@ struct tc_pie_xstats {
>> >  	__u32 maxq;             /* maximum queue size */
>> >  	__u32 ecn_mark;         /* packets marked with ecn*/
>> >  };
>> > +
>> > +/* CBS */
>> > +struct tc_cbs_qopt {
>> > +	__u8 offload;
>
> You probably don't want unnamed padding in a uapi structure.

Yeah, this needs to be fixed.

>
>> > +	__s32 hicredit;
>> > +	__s32 locredit;
>> > +	__s32 idleslope;
>> > +	__s32 sendslope;
>> > +};
>> > +
>> > +enum {
>> > +	TCA_CBS_UNSPEC,
>> > +	TCA_CBS_PARMS,
>> > +	__TCA_CBS_MAX,
>> > +};
>> > +
>> > +#define TCA_CBS_MAX (__TCA_CBS_MAX - 1)
>
> Why not:
> 	TCA_CBS_PARMS,
> 	TCA_CBS_NEXT,
> 	TCA_CBS_MAX = TCA_CBS_NEXT - 1,

The way it is proposed, at least is consistent with the rest of the
file. So, if you don't have any stronger reasons, I'd like to keep it
this way.

>
> ...
> 	David


Cheers,
