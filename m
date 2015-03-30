From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [patch net-next] tc: introduce OpenFlow classifier
Date: Mon, 30 Mar 2015 14:18:54 +0200
Message-ID: <20150330121854.GG2045@nanopsycho.orion>
References: <1427374439-11587-1-git-send-email-jiri@resnulli.us>
 <55189B43.6000407@mojatatu.com>
 <20150330062632.GB2045@nanopsycho.orion>
 <55192F20.3030508@mojatatu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, davem@davemloft.net, tgraf@suug.ch,
	jesse@nicira.com
To: Jamal Hadi Salim <jhs@mojatatu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wg0-f46.google.com ([74.125.82.46]:34079 "EHLO
	mail-wg0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752665AbbC3MTb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 30 Mar 2015 08:19:31 -0400
Received: by wgbdm7 with SMTP id dm7so66185212wgb.1
        for <netdev@vger.kernel.org>; Mon, 30 Mar 2015 05:19:30 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <55192F20.3030508@mojatatu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Mon, Mar 30, 2015 at 01:10:24PM CEST, jhs@mojatatu.com wrote:
>On 03/30/15 02:26, Jiri Pirko wrote:
>>Mon, Mar 30, 2015 at 02:39:31AM CEST, jhs@mojatatu.com wrote:
>
>>>Could you have got rid of "type" above given we always have
>>>a "proto" field in tc that is checked at the core?
>>
>>Sure it is possible. But I try to stick with the names used in OpenFlof
>>documentation.
>>
>
>Ok, thats fine. Safer to stick with the spec.
>
>>>Was there something else that was intended to go into that tp union?
>>
>>Following fields are missing:
>>
>>OXM_OF_SCTP_SRC
>>OXM_OF_SCTP_DST
>>OXM_OF_ICMPV4_TYPE
>>OXM_OF_ICMPV4_CODE
>>
>
>It just looked strange to have a union with only one member.

Oh, will remove the union for now as it can be easily extended later.

>
>>>General comments:
>>>so what happens if someone adds a new field? It sounds to me like
>>>given it is tied to datapath match it will never be backward compatible
>>>(i.e think old tc, new kernel vs new tc, old kernel)
>>
>>
>>Well if kernel does not understand the new field, it will simply ignore
>>it.
>>
>
>More like user expectation may be different. I suppose they could query
>the kernel and find that their field was not set.

I believe that is the usual way thing are done using Netlink API.

>BTW, another micro optimization:
>You could pre-compute the user passed key/mask result per field and
>in the fast path use that instead of doing f->match.key & f->match.mask

Yes, I plan to address this as well for v2. Thanks!

>
>cheers,
>jamal
