From: Daniel Borkmann <daniel@iogearbox.net>
Subject: Re: [RFC 03/12] net: cls_bpf: limit hardware offload by software-only
 flag
Date: Wed, 01 Jun 2016 23:31:25 +0200
Message-ID: <574F542D.5020400@iogearbox.net>
References: <1464799814-4453-1-git-send-email-jakub.kicinski@netronome.com>	<1464799814-4453-4-git-send-email-jakub.kicinski@netronome.com>	<574F3A27.5050208@iogearbox.net>	<20160601220520.717fb5f8@jkicinski-Precision-T1700>	<574F51E4.2020504@iogearbox.net> <20160601222608.04c7b707@jkicinski-Precision-T1700>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, ast@kernel.org,
	dinan.gunawardena@netronome.com
To: Jakub Kicinski <jakub.kicinski@netronome.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:35707 "EHLO
	www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750824AbcFAVb1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 1 Jun 2016 17:31:27 -0400
In-Reply-To: <20160601222608.04c7b707@jkicinski-Precision-T1700>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 06/01/2016 11:26 PM, Jakub Kicinski wrote:
> On Wed, 01 Jun 2016 23:21:40 +0200, Daniel Borkmann wrote:
>> On 06/01/2016 11:05 PM, Jakub Kicinski wrote:
>>> On Wed, 01 Jun 2016 21:40:23 +0200, Daniel Borkmann wrote:
>> [...]
>>>>> @@ -400,8 +406,11 @@ static int cls_bpf_modify_existing(struct net *net, struct tcf_proto *tp,
>>>>>
>>>>>     		have_exts = bpf_flags & TCA_BPF_FLAG_ACT_DIRECT;
>>>>>     	}
>>>>> +	if (tb[TCA_BPF_GEN_TCA_FLAGS])
>>>>> +		gen_flags = nla_get_u32(tb[TCA_BPF_GEN_TCA_FLAGS]);
>>>>>
>>>>>     	prog->exts_integrated = have_exts;
>>>>> +	prog->gen_flags = gen_flags & CLS_BPF_SUPPORTED_GEN_FLAGS;
>>>>
>>>> Invalid flags should probably be rejected here with -EINVAL or something.
>>>
>>> Indeed, that would be more in line with what is done for "the other"
>>> flags attribute, but not so much with how flower and u32 handles
>>> flags. I like the stricter approach better, though, so unless someone
>>> speaks up I'll do as you suggest.
>>
>> If I see this correctly, in patch 4 you're already following up on that
>> with the tc_flags_valid() check, it's probably okay to leave it as-is then.
>
> My concern was that if someone adds a new flag for u32/flower
> tc_flags_valid() will have to accept it but cls_bpf will ignore it.  So
> I went with clearing things we don't support so that the user can at
> least see in tc show that the flags he thrown at us did not stick...

Ok, then doing so is fine. You could probably add that as a comment there
for the rejection.
