From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [next-queue PATCH v4 3/4] net/sched: Introduce Credit Based
 Shaper (CBS) qdisc
Date: Thu, 5 Oct 2017 23:15:02 +0200
Message-ID: <20171005211502.GB2027@nanopsycho>
References: <20171004002831.18371-1-vinicius.gomes@intel.com>
 <20171004002831.18371-4-vinicius.gomes@intel.com>
 <20171004063650.GA1895@nanopsycho>
 <877ew9jrkh.fsf@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, intel-wired-lan@lists.osuosl.org,
        jhs@mojatatu.com, xiyou.wangcong@gmail.com, andre.guedes@intel.com,
        ivan.briano@intel.com, jesus.sanchez-palencia@intel.com,
        boon.leong.ong@intel.com, richardcochran@gmail.com,
        henrik@austad.us, levipearson@gmail.com, rodney.cummings@ni.com
To: Vinicius Costa Gomes <vinicius.gomes@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f65.google.com ([74.125.82.65]:46870 "EHLO
        mail-wm0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752278AbdJEVPF (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 5 Oct 2017 17:15:05 -0400
Received: by mail-wm0-f65.google.com with SMTP id m72so4368948wmc.1
        for <netdev@vger.kernel.org>; Thu, 05 Oct 2017 14:15:04 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <877ew9jrkh.fsf@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Thu, Oct 05, 2017 at 09:57:34PM CEST, vinicius.gomes@intel.com wrote:
>Hi Jiri,
>
>Jiri Pirko <jiri@resnulli.us> writes:
>
>> Wed, Oct 04, 2017 at 02:28:30AM CEST, vinicius.gomes@intel.com wrote:
>>>This queueing discipline implements the shaper algorithm defined by
>>>the 802.1Q-2014 Section 8.6.8.2 and detailed in Annex L.
>>>
>>>It's primary usage is to apply some bandwidth reservation to user
>>>defined traffic classes, which are mapped to different queues via the
>>>mqprio qdisc.
>>>
>>>Initially, it only supports offloading the traffic shaping work to
>>>supporting controllers.
>>>
>>>Later, when a software implementation is added, the current dependency
>>>on being installed "under" mqprio can be lifted.
>>>
>>>Signed-off-by: Vinicius Costa Gomes <vinicius.gomes@intel.com>
>>>Signed-off-by: Jesus Sanchez-Palencia <jesus.sanchez-palencia@intel.com>
>>>---
>>> include/linux/netdevice.h      |   1 +
>>> include/net/pkt_sched.h        |   9 ++
>>> include/uapi/linux/pkt_sched.h |  17 ++++
>>> net/sched/Kconfig              |  11 ++
>>> net/sched/Makefile             |   1 +
>>> net/sched/sch_cbs.c            | 225 +++++++++++++++++++++++++++++++++++++++++
>>> 6 files changed, 264 insertions(+)
>>> create mode 100644 net/sched/sch_cbs.c
>>>
>>>diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
>>>index e1d6ef130611..b8798adc214f 100644
>>>--- a/include/linux/netdevice.h
>>>+++ b/include/linux/netdevice.h
>>>@@ -775,6 +775,7 @@ enum tc_setup_type {
>>> 	TC_SETUP_CLSFLOWER,
>>> 	TC_SETUP_CLSMATCHALL,
>>> 	TC_SETUP_CLSBPF,
>>>+	TC_SETUP_CBS,
>>
>> Please split this into 2 patches. One will introduce the new qdisc,
>> second will add offload capabilities.
>>
>
>Of course.
>
>> [...]
>>
>>
>>>+static struct Qdisc_ops cbs_qdisc_ops __read_mostly = {
>>>+	.next		=	NULL,
>>>+	.id		=	"cbs",
>>>+	.priv_size	=	sizeof(struct cbs_sched_data),
>>>+	.enqueue	=	cbs_enqueue,
>>>+	.dequeue	=	qdisc_dequeue_head,
>>>+	.peek		=	qdisc_peek_dequeued,
>>>+	.init		=	cbs_init,
>>>+	.reset		=	qdisc_reset_queue,
>>>+	.destroy	=	cbs_destroy,
>>>+	.change		=	cbs_change,
>>>+	.dump		=	cbs_dump,
>>>+	.owner		=	THIS_MODULE,
>>>+};
>>
>> I don't see a software implementation for this. Looks like you are
>> trying abuse tc subsystem to bypass kernel. Could you please explain
>> this? The golden rule is: implement in kernel, then offload.
>
>The reason was that we didn't have a use case for the software
>implementation right now, it would be added in a later series.

The policy is very strict, SW implementation first, HW implementation later.



>
>But as that was requested (and it makes sense), I will add it for the
>next version of this series (it is already written, just need to test it
>better).

Good.



>
>
>Cheers,
>--
>Vinicius
