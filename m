From: Olof Johansson <olof@lixom.net>
Subject: Re: [PATCH] [02/10] pasemi_mac: Stop using the pci config space
	accessors for register read/writes
Date: Thu, 23 Aug 2007 13:12:08 -0500
Message-ID: <20070823181208.GA31882@lixom.net>
References: <20070817205413.548020000@lixom.net> <20070822141248.GC16830@lixom.net> <20070823103103.a1815a07.sfr@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, jgarzik@pobox.com, linuxppc-dev@ozlabs.org
To: Stephen Rothwell <sfr@canb.auug.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from lixom.net ([66.141.50.11]:58817 "EHLO mail.lixom.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755659AbXHWTHI (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 23 Aug 2007 15:07:08 -0400
Content-Disposition: inline
In-Reply-To: <20070823103103.a1815a07.sfr@canb.auug.org.au>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Aug 23, 2007 at 10:31:03AM +1000, Stephen Rothwell wrote:
> On Wed, 22 Aug 2007 09:12:48 -0500 Olof Johansson <olof@lixom.net> wrote:
> >
> > -static unsigned int read_iob_reg(struct pasemi_mac *mac, unsigned int reg)
> > +static inline unsigned int read_iob_reg(struct pasemi_mac *mac, unsigned int reg)
>           ^^^^^^
> For static functions in C files, we tend not to bother marking them
> inline any more as the compiler does a pretty good job theses days.

Yeah, sloppy coding on my behalf. It was still there from when I
explicitly added noinline during debugging, forgot to take it out
alltogether.

> > -	pci_read_config_dword(mac->iob_pdev, reg, &val);
> > +	val = in_le32(mac->iob_regs+reg);
> > +
> >  	return val;
> 
> Why not just "return in_le32(mac->iob_regs+reg);" ?
> And similarly below?

Residual from debugging as well, I had debug hooks showing what was
read/written that I took out, but didn't fix up the surrounding stuff.


Refreshed patch posted separately. Thanks for the feedback.

-Olof
