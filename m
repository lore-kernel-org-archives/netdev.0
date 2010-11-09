From: Patrick McHardy <kaber@trash.net>
Subject: Re: Netlink limitations
Date: Tue, 09 Nov 2010 13:24:26 +0100
Message-ID: <4CD93D7A.2010305@trash.net>
References: <alpine.LNX.2.01.1011071743070.21289@obet.zrqbmnf.qr> <4CD6DF37.6010800@trash.net> <alpine.LNX.2.01.1011091303250.21752@obet.zrqbmnf.qr>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
	Holger Eitzenberger <heitzenberger@astaro.com>,
	Pablo Neira Ayuso <pablo@netfilter.org>,
	netdev@vger.kernel.org
To: Jan Engelhardt <jengelh@medozas.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:54343 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754931Ab0KIMYa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 9 Nov 2010 07:24:30 -0500
In-Reply-To: <alpine.LNX.2.01.1011091303250.21752@obet.zrqbmnf.qr>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Am 09.11.2010 13:10, schrieb Jan Engelhardt:
> 
> On Sunday 2010-11-07 18:17, Patrick McHardy wrote:
>> On 07.11.2010 17:44, Jan Engelhardt wrote:
>>> we mentioned it only briefly at the Netfilter workshop a few weeks ago, 
>>> but as I am trying to figure out how to use Netlink in Xtables, 
>>> Netlink's limitations really start ruining my day.
>>>
>>> The well-known issue is that NL messages[sic] the kernel is supposed to 
>>> receive have a max size of 64K, due to nlmsghdr's use of uint16_t. This 
>>> is very problematic because attributes can easily amass more than 64K. 
>>> Think of a chain full of rules, represented by a top-level attribute 
>>> that nests attributes. The problem is bidirectional, a table 
>>> dump has the same problem.
>>
>> Messages are not limited to 64k, individual attributes are. Holger
>> started working on a nlattr32, which uses 32 bit for the length
>> value.
> 
> Does he have a format specification available?

As I said, the basic idea is to use a length value of zero to indicate
that the length should be read from a second length member. Basically:

struct nlattr32 {
	__u16 nla_len;
	__u16 nla_type;
	__u32 nla_len2;
};

