From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [patch net-next] tc: introduce OpenFlow classifier
Date: Fri, 27 Mar 2015 07:07:16 +0100
Message-ID: <20150327060716.GB2073@nanopsycho.orion>
References: <1427374439-11587-1-git-send-email-jiri@resnulli.us>
 <1427379836.29436.9.camel@stressinduktion.org>
 <20150326152938.GD2010@nanopsycho.orion>
 <1427402351.2093330.245738573.1406B9EA@webmail.messagingengine.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, davem@davemloft.net, jhs@mojatatu.com,
	tgraf@suug.ch, jesse@nicira.com
To: Hannes Frederic Sowa <hannes@stressinduktion.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f174.google.com ([209.85.212.174]:36997 "EHLO
	mail-wi0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751579AbbC0GHT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 27 Mar 2015 02:07:19 -0400
Received: by wiaa2 with SMTP id a2so17251203wia.0
        for <netdev@vger.kernel.org>; Thu, 26 Mar 2015 23:07:18 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <1427402351.2093330.245738573.1406B9EA@webmail.messagingengine.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Thu, Mar 26, 2015 at 09:39:11PM CET, hannes@stressinduktion.org wrote:
>On Thu, Mar 26, 2015, at 16:29, Jiri Pirko wrote:
>> Thu, Mar 26, 2015 at 03:23:56PM CET, hannes@stressinduktion.org wrote:
>> >> +static int of_classify(struct sk_buff *skb, const struct tcf_proto *tp,
>> >> +		       struct tcf_result *res)
>> >> +{
>> >> +	struct cls_of_head *head = rcu_dereference_bh(tp->root);
>> >> +	struct cls_of_filter *f;
>> >> +	struct of_flow_key skb_key;
>> >> +	int ret;
>> >> +
>> >> +	of_extract_key(skb, &skb_key);
>> >> +
>> >> +	list_for_each_entry_rcu(f, &head->filters, list) {
>> >> +		if (!of_match(&skb_key, f))
>> >> +			continue;
>> >
>> >This seems very limited to me, do you have plans to extend this?
>> 
>> What do you have in mind?
>
>We have the possibility to make the order of the matches matter easily
>here (like a decision tree).
>Maybe this would give a benefit over simple full match with mask, so
>user space can align the most
>significant matches first thus creating less churn in the caches and
>make the lookup time shorter?
>I understand, if you want build a simples openvswitch replacement a hash
>table would be good to go,
>too.
>
>Just a proposal, maybe we can add more benefit to this kind of
>classifier.

Yep sure. This can be implemented in follow-up patches.

>
>Albeit it looks a bit like cls_bpf could do that more easily.

well, you can do *everything* with cls_bpf now that it supports ebpf.
But I think it is a big hammer. cls_openflow suppose to be just
replacement for existing ovs classification, with very simple and well
understood uapi.

>
>What do you think?
>
>Bye,
>Hannes
