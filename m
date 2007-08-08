From: Michael Buesch <mb@bu3sch.de>
Subject: Re: [PATCH 2/14] nes: device structures and defines
Date: Wed, 8 Aug 2007 18:43:36 +0200
Message-ID: <200708081843.36370.mb@bu3sch.de>
References: <200708080045.l780jE9E004667@neteffect.com> <200708081830.20129.mb@bu3sch.de> <46B9F054.4030000@garzik.org>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Roland Dreier <rdreier@cisco.com>,
	Andi Kleen <andi@firstfloor.org>, ggrundstrom@neteffect.com,
	ewg@lists.openfabrics.org, netdev@vger.kernel.org
To: Jeff Garzik <jeff@garzik.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from static-ip-62-75-166-246.inaddr.intergenia.de ([62.75.166.246]:34692
	"EHLO vs166246.vserver.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S937140AbXHHQoL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 8 Aug 2007 12:44:11 -0400
In-Reply-To: <46B9F054.4030000@garzik.org>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wednesday 08 August 2007 18:33:24 Jeff Garzik wrote:
> Michael Buesch wrote:
> > On Wednesday 08 August 2007 18:18:31 Roland Dreier wrote:
> >>  > But there are indeed a few cases that look wrong.
> >>
> >> yes...
> >>
> >>  > arch/x86_64/kernel/pci-calgary.c:       writel(cpu_to_be32(val), target);
> >>
> >> eg this almost certainly wants to be
> >>
> >> 	writel(swab32(val), target);
> >>
> >> or something equivalent like
> >>
> >> 	__raw_writel(cpu_to_be32(val), target);
> >> 	/* plus some suffficent memory ordering */
> >>
> >>  - R.
> >>
> >>
> > 
> > certainly, yes.
> > Most likely the __raw_writel variant is portable, but I am not
> > sure. Anybody sure?
> 
> Yes, it's portable.  You must however be aware of the guarantees that 
> writel() provides and __raw_writel() does not:  no barriers or flushes, 
> no endian conversions, no ordering constraints, ...  Probably a few more 
> details I'm forgetting too :)

writel doesn't guarantee flushing either.
readl does.
The barrier/ordering issue however might be a critical thing,
when using __raw_XXX. So one must always mmiowb() after such a write.

-- 
Greetings Michael.
