From: Segher Boessenkool <segher@kernel.crashing.org>
Subject: Re: [PATCH] Remove powerpc specific parts of 3c509 driver
Date: Wed, 20 Sep 2006 02:58:39 +0200
Message-ID: <9F6F4A8E-C780-4358-97AA-570B33C0598F@kernel.crashing.org>
References: <20060919145433.8fc7d478.sfr@canb.auug.org.au> <20060919184243.GL29167@austin.ibm.com> <45103C62.4080003@genesi-usa.com> <1158708269.6002.186.camel@localhost.localdomain> <488875E7-CCBC-47E1-A273-A2D037A997B2@kernel.crashing.org> <1158711935.6002.226.camel@localhost.localdomain>
Mime-Version: 1.0 (Apple Message framework v752.2)
Content-Type: text/plain; charset=US-ASCII; delsp=yes; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Matt Sealey <matt@genesi-usa.com>, akpm@osdl.org,
	Stephen Rothwell <sfr@canb.auug.org.au>, jgarzik@pobox.com,
	ppc-dev <linuxppc-dev@ozlabs.org>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-in-07.arcor-online.net ([151.189.21.47]:2469 "EHLO
	mail-in-01.arcor-online.net") by vger.kernel.org with ESMTP
	id S1750784AbWITA7L (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 19 Sep 2006 20:59:11 -0400
In-Reply-To: <1158711935.6002.226.camel@localhost.localdomain>
To: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

>> Sure, PCI busses are little-endian.  But is readX()/writeX() for PCI
>> only?  I sure hope not.
>
> It's defined for PCI and possibly ISA memory. You can use it for other
> things if you whish to, but "other things" are arch specific in any
> case.

Huh?  You're saying that only PCI and ISA are standardised busses?

>> It would make a lot more sense if readX()/writeX() used the  
>> endianness
>> of the bus they are performed on.
>
> No way ! Again, it's evil if such a simple thing start doing different
> things depending on random external factors.

That's your opinion, yes.

I'm saying it's *not* doing different things: in both cases it just does
the correct-endian access.  Also it doesn't depend on "random external
factors" -- they're not random factors, and not external either: it only
depends on the bus the access is done on.

> Different bus -> different accessor.

Then please rename readX()/writeX() to pci_readX()/pci_writeX().

>> Now you can say, use readl_be() or something similar, but that's a)
>> ugly,
>> b) error-prone, c) exponential interface explosion, d) ugly.
>
> I'd rather has an interface explosion than having black endian magic
> happening inside of the accessors.

Any comments on a), b) and d) as well?


Segher

