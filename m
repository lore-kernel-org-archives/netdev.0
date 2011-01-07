From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: Re: genetlink misinterprets NEW as GET
Date: Fri, 07 Jan 2011 13:12:25 +0100
Message-ID: <4D270329.3010702@netfilter.org>
References: <alpine.LNX.2.01.1101040304500.29858@obet.zrqbmnf.qr> <4D25C82F.4010306@netfilter.org> <878vyyvtci.fsf@benpfaff.org> <4D266CE5.4000309@netfilter.org> <alpine.LNX.2.01.1101071033400.25363@obet.zrqbmnf.qr>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Ben Pfaff <blp@nicira.com>,
	Netfilter Developer Mailing List
	<netfilter-devel@vger.kernel.org>,
	Linux Networking Developer Mailing List
	<netdev@vger.kernel.org>
To: Jan Engelhardt <jengelh@medozas.de>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <alpine.LNX.2.01.1101071033400.25363@obet.zrqbmnf.qr>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 07/01/11 10:38, Jan Engelhardt wrote:
> 
> On Friday 2011-01-07 02:31, Pablo Neira Ayuso wrote:
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
> But that would still mean that a user sending a
> NLM_F_REQUEST|NLM_F_REPLACE|NLM_F_EXCL message would be misinterpreted
> as NLM_F_DUMP.

That flag combination does not make sense to me. Valid combinations are:

NLM_F_REQUEST|NLM_F_CREATE : if it does not exist, create it, if it
exists, update it.
NLM_F_REQUEST|NLM_F_CREATE|NLM_F_EXCL: if it does not exist, create it,
if it exists, return -EEXIST.
NLM_F_REQUEST|NLM_F_REPLACE: if it does not exist, return -ENOENT, if it
exists, replace it.
