From: Jan Engelhardt <jengelh@medozas.de>
Subject: Re: genetlink misinterprets NEW as GET
Date: Fri, 7 Jan 2011 10:38:49 +0100 (CET)
Message-ID: <alpine.LNX.2.01.1101071033400.25363@obet.zrqbmnf.qr>
References: <alpine.LNX.2.01.1101040304500.29858@obet.zrqbmnf.qr> <4D25C82F.4010306@netfilter.org> <878vyyvtci.fsf@benpfaff.org> <4D266CE5.4000309@netfilter.org>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Ben Pfaff <blp@nicira.com>,
	Netfilter Developer Mailing List
	<netfilter-devel@vger.kernel.org>,
	Linux Networking Developer Mailing List
	<netdev@vger.kernel.org>
To: Pablo Neira Ayuso <pablo@netfilter.org>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <4D266CE5.4000309@netfilter.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


On Friday 2011-01-07 02:31, Pablo Neira Ayuso wrote:
>>>> 	/* Modifiers to GET request */
>>>> 	#define NLM_F_ROOT      0x100
>>>> 	#define NLM_F_MATCH     0x200
>>>> 	#define NLM_F_ATOMIC    0x400
>>>> 	#define NLM_F_DUMP      (NLM_F_ROOT|NLM_F_MATCH)
>> [...]
>>>> [N.B.: I am also wondering whether
>>>> 	(nlh->nlmsg_flags & NLM_F_DUMP) == NLM_F_DUMP
>>>> may have been desired, because NLM_F_DUMP is composed of two bits.]
>>>
>>> Someone may include NLM_F_ATOMIC to a dump operation, in that case the
>>> checking that you propose is not valid.
>> 
>> Are you saying that NLM_F_MATCH and NLM_F_ATOMIC are mutually
>> exclusive, and that NLM_F_ROOT|NLM_F_ATOMIC would also signal a
>> dump operation?  Otherwise the test that Jan proposes looks valid
>> to me.
>
>Indeed, Jan's test is fine to fix this. Please, send a patch to Davem asap.

But that would still mean that a user sending a
NLM_F_REQUEST|NLM_F_REPLACE|NLM_F_EXCL message would be misinterpreted
as NLM_F_DUMP.
There just is no way for genl to figure out from an arbitrary nlmsghdr
whether it's a dump request or something else without breaking 
something.
The overlapping of NLM_F_ is quite unfortunate.
