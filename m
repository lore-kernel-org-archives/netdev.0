From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: Re: genetlink misinterprets NEW as GET
Date: Fri, 07 Jan 2011 02:31:17 +0100
Message-ID: <4D266CE5.4000309@netfilter.org>
References: <alpine.LNX.2.01.1101040304500.29858@obet.zrqbmnf.qr>	<4D25C82F.4010306@netfilter.org> <878vyyvtci.fsf@benpfaff.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Jan Engelhardt <jengelh@medozas.de>,
	Netfilter Developer Mailing List
	<netfilter-devel@vger.kernel.org>,
	Linux Networking Developer Mailing List
	<netdev@vger.kernel.org>
To: Ben Pfaff <blp@nicira.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:47719 "EHLO mail.us.es"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755236Ab1AGBbZ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 6 Jan 2011 20:31:25 -0500
In-Reply-To: <878vyyvtci.fsf@benpfaff.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 06/01/11 18:23, Ben Pfaff wrote:
> Pablo Neira Ayuso <pablo@netfilter.org> writes:
> 
>> On 04/01/11 03:14, Jan Engelhardt wrote:
>>> 	/* Modifiers to GET request */
>>> 	#define NLM_F_ROOT      0x100
>>> 	#define NLM_F_MATCH     0x200
>>> 	#define NLM_F_ATOMIC    0x400
>>> 	#define NLM_F_DUMP      (NLM_F_ROOT|NLM_F_MATCH)
> [...]
>>> [N.B.: I am also wondering whether
>>> 	(nlh->nlmsg_flags & NLM_F_DUMP) == NLM_F_DUMP
>>> may have been desired, because NLM_F_DUMP is composed of two bits.]
>>
>> Someone may include NLM_F_ATOMIC to a dump operation, in that case the
>> checking that you propose is not valid.
> 
> Are you saying that NLM_F_MATCH and NLM_F_ATOMIC are mutually
> exclusive, and that NLM_F_ROOT|NLM_F_ATOMIC would also signal a
> dump operation?  Otherwise the test that Jan proposes looks valid
> to me.

Indeed, Jan's test is fine to fix this. Please, send a patch to Davem asap.
