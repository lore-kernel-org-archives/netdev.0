From: Jan Engelhardt <jengelh@medozas.de>
Subject: Re: genetlink misinterprets NEW as GET
Date: Thu, 6 Jan 2011 17:12:59 +0100 (CET)
Message-ID: <alpine.LNX.2.01.1101061706080.14797@obet.zrqbmnf.qr>
References: <alpine.LNX.2.01.1101040304500.29858@obet.zrqbmnf.qr> <4D25C82F.4010306@netfilter.org> <alpine.LNX.2.01.1101061508550.13211@obet.zrqbmnf.qr> <4D25D7CD.6070006@netfilter.org>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Netfilter Developer Mailing List
	<netfilter-devel@vger.kernel.org>,
	Linux Networking Developer Mailing List
	<netdev@vger.kernel.org>
To: Pablo Neira Ayuso <pablo@netfilter.org>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <4D25D7CD.6070006@netfilter.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thursday 2011-01-06 15:55, Pablo Neira Ayuso wrote:

>On 06/01/11 15:25, Jan Engelhardt wrote:
>> On Thursday 2011-01-06 14:48, Pablo Neira Ayuso wrote:
>>>>
>>>> 	/* Modifiers to GET request */
>>>> 	#define NLM_F_ROOT      0x100
>>>> 	#define NLM_F_MATCH     0x200
>>>> 	#define NLM_F_ATOMIC    0x400
>>>> 	#define NLM_F_DUMP      (NLM_F_ROOT|NLM_F_MATCH)
>>>> 	
>>>> 	/* Modifiers to NEW request */
>>>> 	#define NLM_F_REPLACE   0x100
>>>> 	#define NLM_F_EXCL      0x200
>>>> 	#define NLM_F_CREATE    0x400
>>>> 	#define NLM_F_APPEND    0x800
>>>>
>
>i getting confused, so ipset is also setting NLM_F_REPLACE to match the
>NLM_F_DUMP bitmask?

Any userspace program sending a (ge)netlink message with
NLM_F_CREATE|NLM_F_EXCL -- with the intent of creating an entry with
excl semantics --, will be misunderstood by genetlink.c to be a dump
request.

The problem is of general nature and not limited to ipset. I only
noticed it while making the ipset-genl patch, because ipset sends all
IPSET_CMD_CREATE requests with
NLM_F_REQUEST|NLM_F_ACK|NLM_F_CREATE|NLM_F_EXCL (see
ipset/lib/mnl.c).
