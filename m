From: John Fastabend <john.r.fastabend@intel.com>
Subject: Re: [net-next PATCH 3/3] net: sched: cls_cgroup fix possible memory
 leak of 'new'
Date: Mon, 15 Sep 2014 20:29:05 -0700
Message-ID: <5417AE81.4030501@intel.com>
References: <20140916024729.3010.47421.stgit@nitbit.x32>	<20140916024831.3010.64477.stgit@nitbit.x32> <CAHA+R7Pz2sCRC7BYAtd2P48gy2oxb=YfJqmx4=+8gKEyLwvMBA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: Cong Wang <xiyou.wangcong@gmail.com>,
	David Miller <davem@davemloft.net>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	netdev <netdev@vger.kernel.org>,
	Jamal Hadi Salim <jhs@mojatatu.com>
To: Cong Wang <cwang@twopensource.com>,
	John Fastabend <john.fastabend@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:43046 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752962AbaIPDo3 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 15 Sep 2014 23:44:29 -0400
In-Reply-To: <CAHA+R7Pz2sCRC7BYAtd2P48gy2oxb=YfJqmx4=+8gKEyLwvMBA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 09/15/2014 08:04 PM, Cong Wang wrote:
> On Mon, Sep 15, 2014 at 7:48 PM, John Fastabend
> <john.fastabend@gmail.com> wrote:
>> diff --git a/net/sched/cls_cgroup.c b/net/sched/cls_cgroup.c
>> index 3b75487..52b7900 100644
>> --- a/net/sched/cls_cgroup.c
>> +++ b/net/sched/cls_cgroup.c
>> @@ -127,16 +127,16 @@ static int cls_cgroup_change(struct net *net, struct sk_buff *in_skb,
>>         err = nla_parse_nested(tb, TCA_CGROUP_MAX, tca[TCA_OPTIONS],
>>                                cgroup_policy);
>>         if (err < 0)
>> -               return err;
>> +               goto errout;
>>
>>         tcf_exts_init(&e, TCA_CGROUP_ACT, TCA_CGROUP_POLICE);
>>         err = tcf_exts_validate(net, tp, tb, tca[TCA_RATE], &e, ovr);
>>         if (err < 0)
>> -               return err;
>> +               goto errout;
>>
>>         err = tcf_em_tree_validate(tp, tb[TCA_CGROUP_EMATCHES], &t);
>>         if (err < 0)
>> -               return err;
>> +               goto errout;
>>
> 
> I think you need to call tcf_exts_destroy() too after tcf_exts_validate(),
> while you are on it. :)

Yep, and did a quick audit looks like its handled correctly in the other
classifiers.

Also there is a needed fix for cls_fw I'll include with the update for this patch.

.John

> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 
