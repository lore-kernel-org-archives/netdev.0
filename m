From: Jamal Hadi Salim <jhs@mojatatu.com>
Subject: Re: [net-next PATCH 0/5] net_sched: Add support for IFE action
Date: Wed, 24 Feb 2016 07:49:44 -0500
Message-ID: <56CDA6E8.7010604@mojatatu.com>
References: <1456147304-13355-1-git-send-email-jhs@emojatatu.com>
 <56CB3B90.8030206@iogearbox.net> <56CC4BEA.70108@mojatatu.com>
 <56CC5CB6.1030807@iogearbox.net> <56CC6C75.1000903@mojatatu.com>
 <56CC7C20.3090302@iogearbox.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, xiyou.wangcong@gmail.com,
	alexei.starovoitov@gmail.com
To: Daniel Borkmann <daniel@iogearbox.net>, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f179.google.com ([209.85.223.179]:36574 "EHLO
	mail-io0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751507AbcBXMtq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 24 Feb 2016 07:49:46 -0500
Received: by mail-io0-f179.google.com with SMTP id l127so36142334iof.3
        for <netdev@vger.kernel.org>; Wed, 24 Feb 2016 04:49:46 -0800 (PST)
In-Reply-To: <56CC7C20.3090302@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 16-02-23 10:34 AM, Daniel Borkmann wrote:
> On 02/23/2016 03:28 PM, Jamal Hadi Salim wrote:
[..]

>> These are basic metadata. The question to ask is what could one use
>> skb->hash for. Today it is used to select a cpu to balance to.
>
> Right, but that happens before you decode that information from your TLV
> on ingress qdisc. And any subsequent skb_get_hash() to read out skb->hash
> will effectively overwrite what you set there and call into flow dissector.
>

Drivers do set the hash. My use case is slightly different.
I have a NIC which has an embedded cavium processor. This thing
strips off the TLV and uses the hash to select the host MSI.
Only thing we dont use at the moment is queue_mapping.


> My concern is we add 20 new modules like this that only do trivial things,
> where instead they could have been consolidated and reduce maintenance. Or
> is this hard module requirement related to the IFE_META_* module parameter?
>

Yes, a bit of that ++.
I am between two worlds: There are people who do user space packet
processing that claim they do so because they can quickly prototype
without compiling the kernel. My goal is to make it easy for people
adding new metadata without having to deal with kernel recompile.
I do expect for there to be many variations of what that metadata
will be. For that reason I have them as standalone modules and they
serve the purpose to illustrate how someone would write such a module.
The IFE_META_XXX is part of saying i dont need to have people
changing the header file either. But i want them to use static
META_IDS. So the IFE module parameter is supposed to allow them to
change the upper bound of modules when insmoding ife_act so that
proper validation can happen. I cant make it as large as 32-bit
or not check if it is correct. If i take it out - then i would have to
do that or introduce some complex mechanism for registration.

cheers,
jamal
