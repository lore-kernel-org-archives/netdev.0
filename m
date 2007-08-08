From: Michael Buesch <mb@bu3sch.de>
Subject: Re: [PATCH 2/14] nes: device structures and defines
Date: Wed, 8 Aug 2007 15:28:33 +0200
Message-ID: <200708081528.34116.mb@bu3sch.de>
References: <200708080045.l780jE9E004667@neteffect.com> <200708081502.35837.mb@bu3sch.de> <20070808130828.GB14419@one.firstfloor.org>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Jeff Garzik <jeff@garzik.org>, ggrundstrom@neteffect.com,
	rdreier@cisco.com, ewg@lists.openfabrics.org,
	netdev@vger.kernel.org
To: Andi Kleen <andi@firstfloor.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from static-ip-62-75-166-246.inaddr.intergenia.de ([62.75.166.246]:52354
	"EHLO vs166246.vserver.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752610AbXHHN3M (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 8 Aug 2007 09:29:12 -0400
In-Reply-To: <20070808130828.GB14419@one.firstfloor.org>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wednesday 08 August 2007 15:08:28 Andi Kleen wrote:
> On Wed, Aug 08, 2007 at 03:02:35PM +0200, Michael Buesch wrote:
> > On Wednesday 08 August 2007 14:55:11 Andi Kleen wrote:
> > > On Wed, Aug 08, 2007 at 01:50:35PM +0200, Michael Buesch wrote:
> > > > On Wednesday 08 August 2007 14:38:10 Andi Kleen wrote:
> > > > > Jeff Garzik <jeff@garzik.org> writes:
> > > > > > > +			val, reg_index, addr, addr+4); */
> > > > > > > +	writel(cpu_to_le32(reg_index), addr);
> > > > > > > +	writel(cpu_to_le32(val),(u8 *)addr + 4);
> > > > > > 
> > > > > > wrong -- endian conversion macros not needed with writel()

> > Fact is that we do _not_ need cpu_to_le32 with writel.
> 
> We do on a big endian platform if the register is LE. I assume that's the case 
> on this hardware.

That is not true.
writeX does automatically convert to bus-endian.
Which, in case of the PCI bus, is little endian.
So if your register is LE (which it is most likely), you don't
need any conversion. If your register is BE (which I very much doubt),
then you need swab32().
In _no_ case you need cpu_to_xx().

-- 
Greetings Michael.
