From: Ben Pfaff <blp@nicira.com>
Subject: Re: genetlink misinterprets NEW as GET
Date: Thu, 06 Jan 2011 09:23:57 -0800
Message-ID: <878vyyvtci.fsf@benpfaff.org>
References: <alpine.LNX.2.01.1101040304500.29858@obet.zrqbmnf.qr>
	<4D25C82F.4010306@netfilter.org>
Reply-To: Ben Pfaff <blp@nicira.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jan Engelhardt <jengelh@medozas.de>,
	Netfilter Developer Mailing List
	<netfilter-devel@vger.kernel.org>,
	Linux Networking Developer Mailing List
	<netdev@vger.kernel.org>
To: Pablo Neira Ayuso <pablo@netfilter.org>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <4D25C82F.4010306@netfilter.org> (Pablo Neira Ayuso's message of
	"Thu, 06 Jan 2011 14:48:31 +0100")
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Pablo Neira Ayuso <pablo@netfilter.org> writes:

> On 04/01/11 03:14, Jan Engelhardt wrote:
>> 	/* Modifiers to GET request */
>> 	#define NLM_F_ROOT      0x100
>> 	#define NLM_F_MATCH     0x200
>> 	#define NLM_F_ATOMIC    0x400
>> 	#define NLM_F_DUMP      (NLM_F_ROOT|NLM_F_MATCH)
[...]
>> [N.B.: I am also wondering whether
>> 	(nlh->nlmsg_flags & NLM_F_DUMP) == NLM_F_DUMP
>> may have been desired, because NLM_F_DUMP is composed of two bits.]
>
> Someone may include NLM_F_ATOMIC to a dump operation, in that case the
> checking that you propose is not valid.

Are you saying that NLM_F_MATCH and NLM_F_ATOMIC are mutually
exclusive, and that NLM_F_ROOT|NLM_F_ATOMIC would also signal a
dump operation?  Otherwise the test that Jan proposes looks valid
to me.
