From: John Fastabend <john.fastabend@gmail.com>
Subject: Re: [PATCH net-next 7/7] cxgb4: add support for drop and redirect
 actions
Date: Mon, 12 Sep 2016 08:17:08 -0700
Message-ID: <57D6C6F4.7070307@gmail.com>
References: <cover.1473667613.git.rahul.lakkireddy@chelsio.com>
 <13800cc26e45257999003861820b0bc65ab7a8d1.1473667613.git.rahul.lakkireddy@chelsio.com>
 <20160912085253.GF2021@nanopsycho>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net,
        hariprasad@chelsio.com, leedom@chelsio.com, nirranjan@chelsio.com,
        indranil@chelsio.com
To: Jiri Pirko <jiri@resnulli.us>,
        Rahul Lakkireddy <rahul.lakkireddy@chelsio.com>,
        Jamal Hadi Salim <jhs@mojatatu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f65.google.com ([209.85.220.65]:36519 "EHLO
        mail-pa0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932883AbcILPRY (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 12 Sep 2016 11:17:24 -0400
Received: by mail-pa0-f65.google.com with SMTP id p2so1690370pap.3
        for <netdev@vger.kernel.org>; Mon, 12 Sep 2016 08:17:24 -0700 (PDT)
In-Reply-To: <20160912085253.GF2021@nanopsycho>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 16-09-12 01:52 AM, Jiri Pirko wrote:
> Mon, Sep 12, 2016 at 10:12:40AM CEST, rahul.lakkireddy@chelsio.com wrote:
>> Add support for dropping matched packets in hardware.  Also add support
>> for re-directing matched packets to a specified port in hardware.
>>
>> Signed-off-by: Rahul Lakkireddy <rahul.lakkireddy@chelsio.com>
>> Signed-off-by: Hariprasad Shenai <hariprasad@chelsio.com>
>> ---

[...]

>>
>> +/* Fill ch_filter_specification with parsed action. */
>> +static int fill_action_fields(struct adapter *adap,
>> +			      struct ch_filter_specification *fs,
>> +			      struct tc_cls_u32_offload *cls)
>> +{
>> +	const struct tc_action *a;
>> +	struct tcf_exts *exts;
>> +	LIST_HEAD(actions);
>> +	unsigned int num_actions = 0;
>> +	bool found = false;
>> +
>> +	exts = cls->knode.exts;
>> +	if (tc_no_actions(exts))
>> +		return -EINVAL;
>> +
>> +	tcf_exts_to_list(exts, &actions);
>> +	list_for_each_entry(a, &actions, list) {
>> +		/* Don't allow more than one action per rule. */
>> +		if (num_actions)
>> +			return -EINVAL;
> 
> 
> Looking at this, unrelated to this patch, we really need some advanced
> reporting to user about what went wrong. Otherwise he's playing a
> guessing game.
> 

+1 my recommendation to new users has been to annotate or read the
kernel source when they get errors which is obviously a failure on
our part to build usable error messages.

Note its not even really related to hardware offload its bad just
with software use case and the hardware offloads make it a bit more
mysterious when an error is returned.

Maybe Jamal can add it to his tc-workshop at netdev conference so
we can get some consensus about how to do this.

.John
