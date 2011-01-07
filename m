From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: Re: [patch] Re: genetlink misinterprets NEW as GET
Date: Fri, 07 Jan 2011 14:33:08 +0100
Message-ID: <4D271614.6000303@netfilter.org>
References: <alpine.LNX.2.01.1101040304500.29858@obet.zrqbmnf.qr> <4D25C82F.4010306@netfilter.org> <878vyyvtci.fsf@benpfaff.org> <4D266CE5.4000309@netfilter.org> <alpine.LNX.2.01.1101071357420.27454@obet.zrqbmnf.qr>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
	Ben Pfaff <blp@nicira.com>,
	Netfilter Developer Mailing List
	<netfilter-devel@vger.kernel.org>,
	Linux Networking Developer Mailing List
	<netdev@vger.kernel.org>
To: Jan Engelhardt <jengelh@medozas.de>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <alpine.LNX.2.01.1101071357420.27454@obet.zrqbmnf.qr>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 07/01/11 14:15, Jan Engelhardt wrote:
> On Friday 2011-01-07 02:31, Pablo Neira Ayuso wrote:
>>>> On 04/01/11 03:14, Jan Engelhardt wrote:
>>>>> 	/* Modifiers to GET request */
>>>>> 	#define NLM_F_ROOT      0x100
>>>>> 	#define NLM_F_MATCH     0x200
>>>>> 	#define NLM_F_ATOMIC    0x400
>>>>> 	#define NLM_F_DUMP      (NLM_F_ROOT|NLM_F_MATCH)
>>> [...]
>>>>> [N.B.: I am also wondering whether
>>>>> 	(nlh->nlmsg_flags & NLM_F_DUMP) == NLM_F_DUMP
>>>>> may have been desired, because NLM_F_DUMP is composed of two bits.]
>>>>
>>>> Someone may include NLM_F_ATOMIC to a dump operation, in that case the
>>>> checking that you propose is not valid.
>>>
>>> Are you saying that NLM_F_MATCH and NLM_F_ATOMIC are mutually
>>> exclusive, and that NLM_F_ROOT|NLM_F_ATOMIC would also signal a
>>> dump operation?  Otherwise the test that Jan proposes looks valid
>>> to me.
>>
>> Indeed, Jan's test is fine to fix this. Please, send a patch to Davem asap.
> 
> Turns out genetlink isn't the only place where &NLM_F_DUMP is used 
> without ==NLM_F_DUMP.
> Thus I am adding it to other spots in net/ too.
> 
> 
> 
> parent c235848c5a76520b90cf31bfbcc17720b24745a2 (v2.6.37-rc1-230-gc235848)
> commit eaab9042b29931730d6785bb3f27b174fb2f5518
> Author: Jan Engelhardt <jengelh@medozas.de>
> Date:   Fri Jan 7 13:53:49 2011 +0100
> 
> netlink: test for all flags of the NLM_F_DUMP composite
> 
> Due to NLM_F_DUMP is composed of two bits, NLM_F_ROOT | NLM_F_MATCH,
> when doing "if (x & NLM_F_DUMP)", it tests for _either_ of the bits
> being set. Because NLM_F_MATCH's value overlaps with NLM_F_EXCL,
> non-dump requests with NLM_F_EXCL set are mistaken as dump requests.
> 
> Substitute the condition to test for _all_ bits being set.
> 
> Signed-off-by: Jan Engelhardt <jengelh@medozas.de>

Acked-by: Pablo Neira Ayuso <pablo@netfilter.org>
