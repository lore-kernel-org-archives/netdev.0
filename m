From: Vinicius Costa Gomes <vinicius.gomes@intel.com>
Subject: Re: [next-queue PATCH v5 4/5] net/sched: Add support for HW offloading for CBS
Date: Wed, 11 Oct 2017 14:40:00 -0700
Message-ID: <87shepmki7.fsf@intel.com>
References: <20171011004400.14946-1-vinicius.gomes@intel.com> <20171011004400.14946-5-vinicius.gomes@intel.com> <20171011070751.GC2039@nanopsycho>
Mime-Version: 1.0
Content-Type: text/plain
Cc: netdev@vger.kernel.org, intel-wired-lan@lists.osuosl.org,
        jhs@mojatatu.com, xiyou.wangcong@gmail.com, andre.guedes@intel.com,
        ivan.briano@intel.com, jesus.sanchez-palencia@intel.com,
        boon.leong.ong@intel.com, richardcochran@gmail.com,
        henrik@austad.us, levipearson@gmail.com, rodney.cummings@ni.com
To: Jiri Pirko <jiri@resnulli.us>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:26649 "EHLO mga11.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1750912AbdJKVkB (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 11 Oct 2017 17:40:01 -0400
In-Reply-To: <20171011070751.GC2039@nanopsycho>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Jiri Pirko <jiri@resnulli.us> writes:

[...]

>>+static void disable_cbs_offload(struct net_device *dev,
>>+				struct cbs_sched_data *q)
>>+{
>>+	struct tc_cbs_qopt_offload cbs = { };
>>+	const struct net_device_ops *ops;
>>+	int err;
>>+
>>+	if (!q->offload)
>>+		return;
>>+
>>+	ops = dev->netdev_ops;
>>+	if (!ops->ndo_setup_tc)
>>+		return;
>>+
>>+	cbs.queue = q->queue;
>>+	cbs.enable = 0;
>>+
>>+	err = ops->ndo_setup_tc(dev, TC_SETUP_CBS, &cbs);
>>+	if (err < 0)
>>+		pr_warn("Couldn't disable CBS offload for queue %d\n",
>>+			cbs.queue);
>
> Hmm, you have separete helper for disable, yet you have enable spread
> over cbs_change. Please push the enable code into enable_cbs_offload.
> While you are at it, change the names to cbs_ to maintain the qdisc
> prefix in function names: cbs_offload_enable/cbs_offload_disable
>

Sure.


Cheers,
