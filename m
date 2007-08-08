From: Andi Kleen <andi@firstfloor.org>
Subject: Re: [PATCH 2/14] nes: device structures and defines
Date: Wed, 8 Aug 2007 15:38:50 +0200
Message-ID: <20070808133850.GE14419@one.firstfloor.org>
References: <200708080045.l780jE9E004667@neteffect.com> <200708081502.35837.mb@bu3sch.de> <20070808130828.GB14419@one.firstfloor.org> <200708081528.34116.mb@bu3sch.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Andi Kleen <andi@firstfloor.org>, Jeff Garzik <jeff@garzik.org>,
	ggrundstrom@neteffect.com, rdreier@cisco.com,
	ewg@lists.openfabrics.org, netdev@vger.kernel.org
To: Michael Buesch <mb@bu3sch.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from one.firstfloor.org ([213.235.205.2]:53888 "EHLO
	one.firstfloor.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751911AbXHHNiv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 8 Aug 2007 09:38:51 -0400
Content-Disposition: inline
In-Reply-To: <200708081528.34116.mb@bu3sch.de>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Aug 08, 2007 at 03:28:33PM +0200, Michael Buesch wrote:
> On Wednesday 08 August 2007 15:08:28 Andi Kleen wrote:
> > On Wed, Aug 08, 2007 at 03:02:35PM +0200, Michael Buesch wrote:
> > > On Wednesday 08 August 2007 14:55:11 Andi Kleen wrote:
> > > > On Wed, Aug 08, 2007 at 01:50:35PM +0200, Michael Buesch wrote:
> > > > > On Wednesday 08 August 2007 14:38:10 Andi Kleen wrote:
> > > > > > Jeff Garzik <jeff@garzik.org> writes:
> > > > > > > > +			val, reg_index, addr, addr+4); */
> > > > > > > > +	writel(cpu_to_le32(reg_index), addr);
> > > > > > > > +	writel(cpu_to_le32(val),(u8 *)addr + 4);
> > > > > > > 
> > > > > > > wrong -- endian conversion macros not needed with writel()
> 
> > > Fact is that we do _not_ need cpu_to_le32 with writel.
> > 
> > We do on a big endian platform if the register is LE. I assume that's the case 
> > on this hardware.
> 
> That is not true.
> writeX does automatically convert to bus-endian.
> Which, in case of the PCI bus, is little endian.
> So if your register is LE (which it is most likely), you don't
> need any conversion. If your register is BE (which I very much doubt),
> then you need swab32().
> In _no_ case you need cpu_to_xx().

Hmm, I checked a couple of BE architectures and none seem to convert explicitely.
But ok it's possible that their PCI bridges convert. I'll take your
word for it although it sounds somewhat dubious.

However if that's true then there are quite some drivers wrong:

% grep -r write[bwl]\(cpu_to *   | wc -l
57

-Andi

