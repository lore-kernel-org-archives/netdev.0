From: David Miller <davem@davemloft.net>
Subject: Re: [BNX2X RESUBMIT][PATCH 0/8] New driver for Broadcom 10Gb
 Ethernet, take two.
Date: Mon, 08 Oct 2007 14:28:01 -0700 (PDT)
Message-ID: <20071008.142801.82028532.davem@davemloft.net>
References: <20071008120855.758d10e7@freepuppy.rosehill>
	<1191879622.5277.11.camel@dell>
	<20071008140301.3e69d01d@freepuppy.rosehill>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: mchan@broadcom.com, eliezert@broadcom.com, jeff@garzik.org,
	netdev@vger.kernel.org, eilong@broadcom.com, vladz@broadcom.com,
	gertner@broadcom.com
To: shemminger@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:56110
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752603AbXJHV2Q (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 8 Oct 2007 17:28:16 -0400
In-Reply-To: <20071008140301.3e69d01d@freepuppy.rosehill>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Stephen Hemminger <shemminger@linux-foundation.org>
Date: Mon, 8 Oct 2007 14:03:01 -0700

> On Mon, 08 Oct 2007 14:40:22 -0700
> "Michael Chan" <mchan@broadcom.com> wrote:
> 
> > On Mon, 2007-10-08 at 12:08 -0700, Stephen Hemminger wrote:
> > > On Mon, 08 Oct 2007 20:34:41 +0200
> > > "Eliezer" <eliezert@broadcom.com> wrote:
> > > 
> > > > > * The MACRO's for 64 bit stats look like they could be done with 
> > > > >   u64 and/or turned into inline's.
> > > > 
> > > > The MACRO's modify some of their arguments, plus they need to work on 32
> > > > bit machines (are 64 bit counters always available on 32 bit machines?).
> > > > so using an inline would allow the inline to be more readable but
> > > > calling it would get ugly.
> > > > I'm open to suggestions.
> > > > 
> > > 
> > > u64 exists on all platforms (including 32 bit).
> > > 
> > 
> > I think the biggest problem with these 64-bits counters (and 64-bit
> > addresses) is that the hardware treats them as big endian and they get
> > DMA'ed in big endian format.  We control the byte swap so that 32-bit
> > quantities will have the correct endianness, but the high and low 32-bit
> > words will be in the wrong spots on little endian machines.  That's why
> > we need to separate the high and the low words and convert them back and
> > forth.
> >
> There are types and tools for checking endianness see be64, etc.

It's not a be64 Stephen, Michael is trying to explain this.

They configure the hardware to swap the bytes within a 32-bit word
into cpu endianness, but the chip doesn't swap the 32-bit words within
a 64-bit word properly, which is why the macros are necessary.
