From: Jamal Hadi Salim <jhs@mojatatu.com>
Subject: Re: [net-next PATCH 0/5] net_sched: Add support for IFE action
Date: Tue, 23 Feb 2016 09:28:05 -0500
Message-ID: <56CC6C75.1000903@mojatatu.com>
References: <1456147304-13355-1-git-send-email-jhs@emojatatu.com>
 <56CB3B90.8030206@iogearbox.net> <56CC4BEA.70108@mojatatu.com>
 <56CC5CB6.1030807@iogearbox.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, xiyou.wangcong@gmail.com,
	alexei.starovoitov@gmail.com
To: Daniel Borkmann <daniel@iogearbox.net>, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f178.google.com ([209.85.223.178]:36559 "EHLO
	mail-io0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752928AbcBWO2M (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 23 Feb 2016 09:28:12 -0500
Received: by mail-io0-f178.google.com with SMTP id l127so213702950iof.3
        for <netdev@vger.kernel.org>; Tue, 23 Feb 2016 06:28:11 -0800 (PST)
In-Reply-To: <56CC5CB6.1030807@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 16-02-23 08:20 AM, Daniel Borkmann wrote:
> On 02/23/2016 01:09 PM, Jamal Hadi Salim wrote:
>> On 16-02-22 11:47 AM, Daniel Borkmann wrote:
> [...]
>>> So, basically this is a L2 encap with TLVs, right?
>>>
>>> And as TLVs you have skb->mark, skb->priority, skb->hash,
>>> skb->queue_mapping
>>> that you transfer from one machine to another, where on the destination,
>>> you
>>> are applying the above meta data to the skb itself. And, configuration
>>> is via
>>> tc.
>>>
>>> I couldn't parse from the commit log what the real world use case is,
>>> resp.
>>> who is going to use this infrastructure?
>>>
>>> Do you have some typical setup, where the above needs to be transferred
>>> in the
>>> encap and restored?
>>
>> I am assuming you are asking this for the sake of people who dont
>> have context (and not for yourself)?
>> I added a pointer to the paper. It is 6 pages and simple to read.
>> Isnt that sufficient? I dont want to write a novel here. Some could
>> argue that in fact i am already writing a novel in commit 1/5.
>
> Ok, the paper talks about, quote:
>
>   - Pipeline-stage Indexing.
>   - OAM information - example turn on some packet debug information on a
> need basis.
>   - Exception handling information - example VXLAN service handling.
>   - Authentication and authorization information.
>   - Versioning information.
>   - Compliance information.
>   - Service Identifiers.
>

Which is now added to the cover letter.

> As your primary examples, you provide skb->mark, skb->priority, skb->hash,
> skb->queue_mapping for encapsulating, f.e. how do you use skb>hash in this
> scenario? What's the use-case?

These are basic metadata. The question to ask is what could one use
skb->hash for. Today it is used to select a cpu to balance to.
I dont understand what your concern is: I could pass a string
as metadata if i wanted to. I chose to pass skb metadata;
some of which i actually use. Only one i dont use is queue
map - but because it is still an skb metadata so i wrote code
to pass it.

>> They need to be separated to make them unique. These are basic
>> metadatum; I have a few others lined up - but i just wanted to start
>> with these because they are obvious to see. What i mulled over is
>> to send one big patch or several. In the end it seemed cleaner to
>> send separate patches.
>
> But just to make them unique, you don't need to add extra modules for
> this ... just having a module for encoding one skb member seems like
> total overdesign to me. If you really want them to be separate ops,
> you can still include them into act_ife.c itself.
>

These things will evolve. I would rather leave them the way they
are for that reason and they serve as good examples of how one
would new metadatum.
Example: skb->mark may end up evolving to include masks.

cheers,
jamal
