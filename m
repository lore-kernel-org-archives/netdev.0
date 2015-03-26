From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [patch net-next] tc: introduce OpenFlow classifier
Date: Thu, 26 Mar 2015 21:39:11 +0100
Message-ID: <1427402351.2093330.245738573.1406B9EA@webmail.messagingengine.com>
References: <1427374439-11587-1-git-send-email-jiri@resnulli.us>
 <1427379836.29436.9.camel@stressinduktion.org>
 <20150326152938.GD2010@nanopsycho.orion>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net, jhs@mojatatu.com,
	tgraf@suug.ch, jesse@nicira.com
To: Jiri Pirko <jiri@resnulli.us>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out2-smtp.messagingengine.com ([66.111.4.26]:54288 "EHLO
	out2-smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752853AbbCZUjM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 26 Mar 2015 16:39:12 -0400
Received: from compute2.internal (compute2.nyi.internal [10.202.2.42])
	by mailout.nyi.internal (Postfix) with ESMTP id 0A41220847
	for <netdev@vger.kernel.org>; Thu, 26 Mar 2015 16:39:09 -0400 (EDT)
In-Reply-To: <20150326152938.GD2010@nanopsycho.orion>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Mar 26, 2015, at 16:29, Jiri Pirko wrote:
> Thu, Mar 26, 2015 at 03:23:56PM CET, hannes@stressinduktion.org wrote:
> >> +static int of_classify(struct sk_buff *skb, const struct tcf_proto *tp,
> >> +		       struct tcf_result *res)
> >> +{
> >> +	struct cls_of_head *head = rcu_dereference_bh(tp->root);
> >> +	struct cls_of_filter *f;
> >> +	struct of_flow_key skb_key;
> >> +	int ret;
> >> +
> >> +	of_extract_key(skb, &skb_key);
> >> +
> >> +	list_for_each_entry_rcu(f, &head->filters, list) {
> >> +		if (!of_match(&skb_key, f))
> >> +			continue;
> >
> >This seems very limited to me, do you have plans to extend this?
> 
> What do you have in mind?

We have the possibility to make the order of the matches matter easily
here (like a decision tree).
Maybe this would give a benefit over simple full match with mask, so
user space can align the most
significant matches first thus creating less churn in the caches and
make the lookup time shorter?
I understand, if you want build a simples openvswitch replacement a hash
table would be good to go,
too.

Just a proposal, maybe we can add more benefit to this kind of
classifier.

Albeit it looks a bit like cls_bpf could do that more easily.

What do you think?

Bye,
Hannes
