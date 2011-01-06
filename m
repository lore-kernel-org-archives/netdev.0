From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: Re: genetlink misinterprets NEW as GET
Date: Thu, 06 Jan 2011 15:55:09 +0100
Message-ID: <4D25D7CD.6070006@netfilter.org>
References: <alpine.LNX.2.01.1101040304500.29858@obet.zrqbmnf.qr> <4D25C82F.4010306@netfilter.org> <alpine.LNX.2.01.1101061508550.13211@obet.zrqbmnf.qr>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Netfilter Developer Mailing List
	<netfilter-devel@vger.kernel.org>,
	Linux Networking Developer Mailing List
	<netdev@vger.kernel.org>
To: Jan Engelhardt <jengelh@medozas.de>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <alpine.LNX.2.01.1101061508550.13211@obet.zrqbmnf.qr>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 06/01/11 15:25, Jan Engelhardt wrote:
> On Thursday 2011-01-06 14:48, Pablo Neira Ayuso wrote:
>>>
>>> 	/* Modifiers to GET request */
>>> 	#define NLM_F_ROOT      0x100
>>> 	#define NLM_F_MATCH     0x200
>>> 	#define NLM_F_ATOMIC    0x400
>>> 	#define NLM_F_DUMP      (NLM_F_ROOT|NLM_F_MATCH)
>>> 	
>>> 	/* Modifiers to NEW request */
>>> 	#define NLM_F_REPLACE   0x100
>>> 	#define NLM_F_EXCL      0x200
>>> 	#define NLM_F_CREATE    0x400
>>> 	#define NLM_F_APPEND    0x800
>>>
>>> Except there is nothing that declares a particular Netlink message
>>> as "GET" or "NEW". Subsequently, genetlink chokes:
>>>
>>> 	if (nlh->nlmsg_flags & NLM_F_DUMP)
>>> 		if (ops->dumpit == NULL)
>>> 			return -EOPNOTSUPP;
>>>
>>> Because NLM_F_CREATE | NLM_F_EXCL == NLM_F_DUMP.
>>> That, of course, is absolutely bogus.
>>
>> Hm, NLM_F_CREATE | NLM_F_EXCL is not equal to NLM_F_DUMP.
>>
>> You must be hitting -EOPNOTSUPP elsewhere.
> 
> No, I am hitting EOPNOTSUPP here; right it's not equal, sorry.
> But nlmsg_flags is tested for NLM_F_MATCH (0x200), which is provided by
> NLM_F_EXCL. ipset does use NLM_F_EXCL and thus ran into this.

i getting confused, so ipset is also setting NLM_F_REPLACE to match the
NLM_F_DUMP bitmask?
