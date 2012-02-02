From: Karsten Keil <kkeil@linux-pingi.de>
Subject: Re: [PATCH 01/16] eicon: fix -Warray-bounds warning
Date: Thu, 2 Feb 2012 19:25:15 +0100
Message-ID: <20120202182515.GA11660@gw.linux-pingi.de>
References: <AE90C24D6B3A694183C094C60CF0A2F6026B6E45@saturn3.aculab.com>
 <201202011352.19539.danny.kukawka@bisect.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Laight <David.Laight@aculab.com>,
	Karsten Keil <kkeil@linux-pingi.de>,
	Ben Hutchings <bhutchings@solarflare.com>,
	Armin Schindler <mac@melware.de>, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, Karsten Keil <isdn@linux-pingi.de>
To: Danny Kukawka <danny.kukawka@bisect.de>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <201202011352.19539.danny.kukawka@bisect.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Feb 01, 2012 at 01:52:18PM +0100, Danny Kukawka wrote:
> On Mittwoch, 1. Februar 2012, David Laight wrote:
> > > -----Original Message-----
> > > From: netdev-owner@vger.kernel.org
> > > [mailto:netdev-owner@vger.kernel.org] On Behalf Of Danny Kukawka
> > > Sent: 31 January 2012 17:04
> > > To: Karsten Keil
> > > Cc: Ben Hutchings; Armin Schindler;
> > > linux-kernel@vger.kernel.org; netdev@vger.kernel.org; Karsten Keil
> > > Subject: Re: [PATCH 01/16] eicon: fix -Warray-bounds warning
> > >
> > > On Dienstag, 31. Januar 2012, Karsten Keil wrote:
> > > > On Mon, Jan 30, 2012 at 11:09:32PM +0000, Ben Hutchings wrote:
> > > > > On Mon, 2012-01-30 at 23:00 +0100, Danny Kukawka wrote:
> > > > > > Fix for a -Warray-bounds warning. mixer_notify_update() tries to
> > > > > > write to ((CAPI_MSG *) msg)->info.facility_req.structs[3] while
> > > > > > structs is defined as byte structs[1], define structs[1] as
> > > > > > structs[4].
> > > > >
> > > > > I suspect that all the 'byte structs[1];' fields defined
> > >
> > > in that header
> > >
> > > > > are actually variable-length arrays.  In that case, there
> > >
> > > may be no
> > >
> > > > > reasonable bound you can specify.
> > > >
> > > > Yes, exactely, the structs is a ASN1 coded message so it
> > >
> > > can have any len.
> > >
> > > So, how can we get rid of the compiler warning then?
> >
> > Try defining it as a 'variable sized array' - byte structs[0].
> 
> Okay, that works. I'll send an updated patch.
> 

Nice, I did not know this way.

Karsten
