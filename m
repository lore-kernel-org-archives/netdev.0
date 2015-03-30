From: Jamal Hadi Salim <jhs@mojatatu.com>
Subject: Re: [patch net-next] tc: introduce OpenFlow classifier
Date: Mon, 30 Mar 2015 07:10:24 -0400
Message-ID: <55192F20.3030508@mojatatu.com>
References: <1427374439-11587-1-git-send-email-jiri@resnulli.us> <55189B43.6000407@mojatatu.com> <20150330062632.GB2045@nanopsycho.orion>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net, tgraf@suug.ch,
	jesse@nicira.com
To: Jiri Pirko <jiri@resnulli.us>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f181.google.com ([209.85.213.181]:37083 "EHLO
	mail-ig0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751086AbbC3LK3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 30 Mar 2015 07:10:29 -0400
Received: by igcxg11 with SMTP id xg11so68743304igc.0
        for <netdev@vger.kernel.org>; Mon, 30 Mar 2015 04:10:28 -0700 (PDT)
In-Reply-To: <20150330062632.GB2045@nanopsycho.orion>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 03/30/15 02:26, Jiri Pirko wrote:
> Mon, Mar 30, 2015 at 02:39:31AM CEST, jhs@mojatatu.com wrote:

>> Could you have got rid of "type" above given we always have
>> a "proto" field in tc that is checked at the core?
>
> Sure it is possible. But I try to stick with the names used in OpenFlof
> documentation.
>

Ok, thats fine. Safer to stick with the spec.

>> Was there something else that was intended to go into that tp union?
>
> Following fields are missing:
>
> OXM_OF_SCTP_SRC
> OXM_OF_SCTP_DST
> OXM_OF_ICMPV4_TYPE
> OXM_OF_ICMPV4_CODE
>

It just looked strange to have a union with only one member.

>> General comments:
>> so what happens if someone adds a new field? It sounds to me like
>> given it is tied to datapath match it will never be backward compatible
>> (i.e think old tc, new kernel vs new tc, old kernel)
>
>
> Well if kernel does not understand the new field, it will simply ignore
> it.
>

More like user expectation may be different. I suppose they could query
the kernel and find that their field was not set.
BTW, another micro optimization:
You could pre-compute the user passed key/mask result per field and
in the fast path use that instead of doing f->match.key & f->match.mask

cheers,
jamal
