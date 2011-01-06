From: Jan Engelhardt <jengelh@medozas.de>
Subject: Re: genetlink misinterprets NEW as GET
Date: Thu, 6 Jan 2011 15:25:25 +0100 (CET)
Message-ID: <alpine.LNX.2.01.1101061508550.13211@obet.zrqbmnf.qr>
References: <alpine.LNX.2.01.1101040304500.29858@obet.zrqbmnf.qr> <4D25C82F.4010306@netfilter.org>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Netfilter Developer Mailing List
	<netfilter-devel@vger.kernel.org>,
	Linux Networking Developer Mailing List
	<netdev@vger.kernel.org>
To: Pablo Neira Ayuso <pablo@netfilter.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from borg.medozas.de ([188.40.89.202]:39566 "EHLO borg.medozas.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752311Ab1AFOZ3 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 6 Jan 2011 09:25:29 -0500
In-Reply-To: <4D25C82F.4010306@netfilter.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thursday 2011-01-06 14:48, Pablo Neira Ayuso wrote:
>> 
>> 	/* Modifiers to GET request */
>> 	#define NLM_F_ROOT      0x100
>> 	#define NLM_F_MATCH     0x200
>> 	#define NLM_F_ATOMIC    0x400
>> 	#define NLM_F_DUMP      (NLM_F_ROOT|NLM_F_MATCH)
>> 	
>> 	/* Modifiers to NEW request */
>> 	#define NLM_F_REPLACE   0x100
>> 	#define NLM_F_EXCL      0x200
>> 	#define NLM_F_CREATE    0x400
>> 	#define NLM_F_APPEND    0x800
>> 
>> Except there is nothing that declares a particular Netlink message
>> as "GET" or "NEW". Subsequently, genetlink chokes:
>> 
>> 	if (nlh->nlmsg_flags & NLM_F_DUMP)
>> 		if (ops->dumpit == NULL)
>> 			return -EOPNOTSUPP;
>> 
>> Because NLM_F_CREATE | NLM_F_EXCL == NLM_F_DUMP.
>> That, of course, is absolutely bogus.
>
>Hm, NLM_F_CREATE | NLM_F_EXCL is not equal to NLM_F_DUMP.
>
>You must be hitting -EOPNOTSUPP elsewhere.

No, I am hitting EOPNOTSUPP here; right it's not equal, sorry.
But nlmsg_flags is tested for NLM_F_MATCH (0x200), which is provided by
NLM_F_EXCL. ipset does use NLM_F_EXCL and thus ran into this.
