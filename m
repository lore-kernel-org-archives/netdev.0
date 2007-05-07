From: Krzysztof Halasa <khc@pm.waw.pl>
Subject: Re: [PATCH 3/3] Intel IXP4xx network drivers
Date: Mon, 07 May 2007 21:57:21 +0200
Message-ID: <m33b289zku.fsf@maximus.localdomain>
References: <m3abwhcy74.fsf@maximus.localdomain>
	<m3vef5biob.fsf@maximus.localdomain>
	<5BB7E1AB-5CE1-43C8-8CE3-E0DE0236BD09@cam.ac.uk>
	<m3hcqoa772.fsf@maximus.localdomain>
	<86D26EBE-5899-468F-9C79-23E83E0DE04B@cam.ac.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jeff Garzik <jeff@garzik.org>, netdev@vger.kernel.org,
	lkml <linux-kernel@vger.kernel.org>,
	Russell King <rmk@arm.linux.org.uk>,
	ARM Linux Mailing List
	<linux-arm-kernel@lists.arm.linux.org.uk>
To: Michael-Luke Jones <mlj28@cam.ac.uk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from khc.piap.pl ([195.187.100.11]:58957 "EHLO khc.piap.pl"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754845AbXEGT5Y (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 7 May 2007 15:57:24 -0400
In-Reply-To: <86D26EBE-5899-468F-9C79-23E83E0DE04B@cam.ac.uk> (Michael-Luke Jones's message of "Mon, 7 May 2007 19:14:53 +0100")
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Having thought about it a bit more, a layout similar to the one
proposed by you may make sense.

Michael-Luke Jones <mlj28@cam.ac.uk> writes:

> Despite their name, Network Processing Engines are independent
> coprocessors which are only coincidentally attached to MACs for
> ethernet / WAN purposes. If Intel would allow us to compile code for
> these coprocessors, we could get them to do lots of things other than
> networking.

Not sure about that. Intel doesn't say much about it, but I think
one can safely assume that while NPEs can probably be programmed
to do other things, their performance comes not from NPE firmware
but from specialized network coprocessors (not NPEs) which can only
do (in hardware) things like Ethernet, HDLC, bit sync, CRC16/32,
and MD5/SHA-1/DES/AES.

I think you can even use MD5 and SHA-1 without any firmware (but
would have to check this info).

Note that while certain CPUs have the same set of NPEs, they are
missing some network coprocessors and can't do, for example, crypto.

OTOH, yes, they are not, strictly speaking, only network processors.

> Crypto is not networking, and if the
> kernel gains ixp4xx crypto support, that should be possible to enable
> independently of networking.

Yep. Unfortunately I don't know in-kernel crypto code.

> They can also function as DMA engines,
> which should also be independent of networking functionality.

That's what the docs say. Not sure about real-life purpose of
such DMA engine, though.

> So, the NPE driver (which is basically ixp4xx specific) should be,
> for practical purposes, networking-code agnostic. As it is a lump of
> code talking to an architecture specific piece of hardware, it should
> live in arch/arm/ rather than arch-independent drivers/

Well, I'm told that (compatible) NPEs are present on other IXP CPUs.
Not sure about details.

> As I understand it, functions to talk to the NPE should appear in the
> NPE driver. The NPE driver should then be called by ethernet/wan/
> crypto/dma(?) drivers to carry out the specific firmware-dependent
> tasks.

Actually, the NPE code does two things:
a) initialized NPEs and downloades the firmware
b) exchanges control messages with NPEs.
-- 
Krzysztof Halasa
