From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: Re: Netlink limitations
Date: Tue, 09 Nov 2010 00:36:38 +0100
Message-ID: <4CD88986.2000109@netfilter.org>
References: <alpine.LNX.2.01.1011071743070.21289@obet.zrqbmnf.qr> <4CD6DF37.6010800@trash.net> <20101108151635.GA20629@canuck.infradead.org> <alpine.LNX.2.01.1011081958410.31946@obet.zrqbmnf.qr>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Thomas Graf <tgraf@infradead.org>,
	Patrick McHardy <kaber@trash.net>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
To: Jan Engelhardt <jengelh@medozas.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:51863 "EHLO mail.us.es"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753177Ab0KHXnY (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 8 Nov 2010 18:43:24 -0500
In-Reply-To: <alpine.LNX.2.01.1011081958410.31946@obet.zrqbmnf.qr>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 08/11/10 20:21, Jan Engelhardt wrote:
> On Monday 2010-11-08 16:16, Thomas Graf wrote:
>>>
>>> Messages are not limited to 64k, individual attributes are. Holger
>>> started working on a nlattr32, which uses 32 bit for the length
>>> value.
>>
>> Also, it is not required to pack everything in attributes. Your protocol
>> may specify that the whole message payload consists of chained attributes.
>> Alternatively you may as well split your attribut chain and dump them
>> as several messages.
> 
> Yeah with NETLINK_URELEASE that seems the way to go. However, what are
> compelling arguments to use Netlink over other forms of bidirectional
> communication? (To play devils advocate, one could use nlattr32/TLVs
> over ioctl too.)

Netlink also provides an event-based notification infrastructure. Of
course, you can implement that upon a new socket family that supports
your new ioctls operations taking things in TLV format.

However, I guess that the whole thing will start looking like netlink
quite a lot in the end ;-).
