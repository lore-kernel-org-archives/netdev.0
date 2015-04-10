From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [patch net-next v3] tc: introduce OpenFlow classifier
Date: Fri, 10 Apr 2015 13:46:33 +0200
Message-ID: <20150410114633.GB2021@nanopsycho.orion>
References: <1428584287-8197-1-git-send-email-jiri@resnulli.us>
 <20150409.173423.2258417584616634411.davem@davemloft.net>
 <20150410091203.GA2021@nanopsycho.orion>
 <5527981E.2040505@iogearbox.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	jhs@mojatatu.com, tgraf@suug.ch, jesse@nicira.com
To: Daniel Borkmann <daniel@iogearbox.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wg0-f44.google.com ([74.125.82.44]:36763 "EHLO
	mail-wg0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751030AbbDJLq4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 10 Apr 2015 07:46:56 -0400
Received: by wgsk9 with SMTP id k9so15017834wgs.3
        for <netdev@vger.kernel.org>; Fri, 10 Apr 2015 04:46:54 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <5527981E.2040505@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Fri, Apr 10, 2015 at 11:30:06AM CEST, daniel@iogearbox.net wrote:
>On 04/10/2015 11:12 AM, Jiri Pirko wrote:
>...
>>>However I am sure that I majorly object to having yet another flow
>>>parsing engine.  Therefore, at least adjust this code to use our flow
>>>dissector and datastructures.  Adjust the flow dissector to fit your
>>>needs, if necessary.
>>
>>Yep, Thomas already suggested the merge. The thing is, cls_flow uses
>>linked list for doing lookups. That is not scalable. in cls_openflow I
>>use rhashtable. Using rhashtable in cls_flow would break the existing
>>assumption that first inrested filter would be first hit.
>>
>>So that would lead into major dual code in cls_flow. So I believe that
>>it is better to do it in separate cls_openflow (do one thing and do it
>>right).
>
>Would it be possible to 1) reuse the majority of the existing internal
>cls_flow code as much as possible, integrate the remaining openflow
>parts into it, and then 2) just register a 2nd classifier kind, a la ...
>
>static struct tcf_proto_ops cls_flow_ht_ops __read_mostly = {
>	.kind		= "flow-ht",
>	.classify	= flow_classify_ht,
>	.init		= flow_init,
>	.destroy	= flow_destroy,
>	.change		= flow_change,
>	.delete		= flow_delete,
>	.get		= flow_get,
>	.dump		= flow_dump,
>	.walk		= flow_walk,
>	.owner		= THIS_MODULE,
>};
>
>... so you could do the non-linear rhashtable matching from there, but
>without much duplication?

I might be missing something, but to me, the codes of cls_flow and
cls_openflow are very different. Merging cls_openflow with for example
cls_fw makes similar sense to me.

cls_flow is no match-action classifier. All skbs are hashed into classid
of pre-defined range. You cannot speficy explicit action for match.

On the other hand cls_openflow is match-action classifier (similar to
for example bpf - might make more sense to me to merge it with bpf).

What I say is, lets do things clearly, separate, not "overmerge" stuff.

I will definitelly loose name "openflow" for my future submission to not
to confuse people.

Thanks!
