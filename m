From: Patrick McHardy <kaber@trash.net>
Subject: Re: [Patch 4/5] Network Drop Monitor: Adding drop monitor implementation
 & Netlink protocol
Date: Mon, 06 Apr 2009 15:21:45 +0200
Message-ID: <49DA01E9.6010602@trash.net>
References: <20090402150908.GA1382@gondor.apana.org.au>	<49D4D66A.50101@trash.net>	<20090402153042.GB1670@gondor.apana.org.au> <20090405.025920.75648090.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Cc: herbert@gondor.apana.org.au, nhorman@tuxdriver.com,
	zbr@ioremap.net, netdev@vger.kernel.org, kuznet@ms2.inr.ac.ru,
	pekkas@netcore.fi, jmorris@namei.org, yoshfuji@linux-ipv6.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:45325 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754818AbZDFNVv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 6 Apr 2009 09:21:51 -0400
In-Reply-To: <20090405.025920.75648090.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Miller wrote:
> From: Herbert Xu <herbert@gondor.apana.org.au>
> Date: Thu, 2 Apr 2009 23:30:42 +0800
> 
>> On Thu, Apr 02, 2009 at 05:14:50PM +0200, Patrick McHardy wrote:
>>> I'd prefer that as well. The only reason to do this is to save a few
>>> bytes and cycles for attribute encapsulation. I don't think this
>>> matters at all, judging by the fact that I've never seen a userspace
>>> implementation using message batching, the current users don't seem
>>> to care about performance *that* much.
>> OK, let's all just keep an eye out for new struct users and see
>> how it goes.
> 
> It might be about time to start working on netlink-2 seriously.
> :-)
> 
> We can start treating it like a real protocol, firmly define
> the endianness of everything to kill all the over-the-wire
> issues, etc. and deal with this 4-byte-align stuff as well.

We could add a setsockopt option for userspace to specify "version 2"
operation. The netlink attributes helpers would need to be aware of
the currently used protocol version and could transparently choose
a different encoding (also taking care of endianess etc). For the
case of one value per attribute this should be a straight-forward
conversion. In case of structures that contain values with different
endianness, we'll probably need to define a new encoding (ideally
also one attribute per value) for version 2.

I'd also suggest to get rid of the 64k attribute and message size
limit at the same time, this is making it quite hard to support
transactional semantics for large updates (f.i. for nf_tables sets).

