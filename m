From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [patch net-next] tc: introduce OpenFlow classifier
Date: Thu, 26 Mar 2015 16:29:38 +0100
Message-ID: <20150326152938.GD2010@nanopsycho.orion>
References: <1427374439-11587-1-git-send-email-jiri@resnulli.us>
 <1427379836.29436.9.camel@stressinduktion.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, davem@davemloft.net, jhs@mojatatu.com,
	tgraf@suug.ch, jesse@nicira.com
To: Hannes Frederic Sowa <hannes@stressinduktion.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f177.google.com ([209.85.212.177]:35547 "EHLO
	mail-wi0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752611AbbCZP3m (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 26 Mar 2015 11:29:42 -0400
Received: by wibbg6 with SMTP id bg6so68911156wib.0
        for <netdev@vger.kernel.org>; Thu, 26 Mar 2015 08:29:40 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <1427379836.29436.9.camel@stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Thu, Mar 26, 2015 at 03:23:56PM CET, hannes@stressinduktion.org wrote:
>> +static int of_classify(struct sk_buff *skb, const struct tcf_proto *tp,
>> +		       struct tcf_result *res)
>> +{
>> +	struct cls_of_head *head = rcu_dereference_bh(tp->root);
>> +	struct cls_of_filter *f;
>> +	struct of_flow_key skb_key;
>> +	int ret;
>> +
>> +	of_extract_key(skb, &skb_key);
>> +
>> +	list_for_each_entry_rcu(f, &head->filters, list) {
>> +		if (!of_match(&skb_key, f))
>> +			continue;
>
>This seems very limited to me, do you have plans to extend this?

What do you have in mind?

>
>Bye,
>Hannes
>
>
