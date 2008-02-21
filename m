From: Nicolas Pitre <nico@cam.org>
Subject: Re: [PATCH 02/04] smc91x: introduce platform data flags
Date: Wed, 20 Feb 2008 22:28:59 -0500 (EST)
Message-ID: <alpine.LFD.1.00.0802202226000.2732@xanadu.home>
References: <20080220095740.22645.36783.sendpatchset@clockwork.opensource.se>
 <20080220095802.22645.44691.sendpatchset@clockwork.opensource.se>
 <alpine.LFD.1.00.0802201044270.2732@xanadu.home>
 <aec7e5c30802201834h7eae8892n7b9434168944eace@mail.gmail.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Content-Transfer-Encoding: 7BIT
Cc: netdev@vger.kernel.org, lethal@linux-sh.org,
	akpm@linux-foundation.org
To: Magnus Damm <magnus.damm@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from relais.videotron.ca ([24.201.245.36]:51718 "EHLO
	relais.videotron.ca" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751387AbYBUD3D (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 20 Feb 2008 22:29:03 -0500
Received: from xanadu.home ([66.131.194.97]) by VL-MH-MR002.ip.videotron.ca
 (Sun Java(tm) System Messaging Server 6.3-4.01 (built Aug  3 2007; 32bit))
 with ESMTP id <0JWK00BRDKCB11C0@VL-MH-MR002.ip.videotron.ca> for
 netdev@vger.kernel.org; Wed, 20 Feb 2008 22:28:59 -0500 (EST)
In-reply-to: <aec7e5c30802201834h7eae8892n7b9434168944eace@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 21 Feb 2008, Magnus Damm wrote:

> On Thu, Feb 21, 2008 at 12:58 AM, Nicolas Pitre <nico@cam.org> wrote:
> > On Wed, 20 Feb 2008, Magnus Damm wrote:
> >
> >  > This patch introduces struct smc91x_platdata and modifies the driver so
> >  > bus width is checked during run time using SMC_nBIT() instead of
> >  > SMC_CAN_USE_nBIT.
> >  >
> >  > Signed-off-by: Magnus Damm <damm@igel.co.jp>
> >  > ---
> >
> >  NAK.
> >
> >  The SMC91C111 (for example) is often used on devices which have a CPU
> >  clock barely higher than the network throughput, hence it is crutial for
> >  those devices to have the most efficient access possible to the chip or
> >  performance will suffer.  This is the main reason behind the heavily
> >  macroized register access so things are always optimized for the data
> >  bus capabilities at compile time.
> 
> I understand that you want to keep the code as fast as possible. So do
> I. But I want to remove the need to modify smc91x.h for each board I
> want to support. It is much better in my opinion to have a wide range
> of boards supported but a little bit lower throughput compared to only
> a few boards supported and excellent performance... People can always
> modify the header file by themselves if they want to squeeze out that
> extra percent of performance.

Sure.  That's perfectly fine for new boards.  But existing setups should 
not regress due to this change.

> >  I think you should add a SMC_DYNAMIC_BUS_CONFIG and redefine SMC_nBITS()
> >  so they dereference cfg.flags only when it is defined.
> 
> Sure, good idea. I'll fix that. Do you mind if I make that the default
> behavior? So boards that doesn't have any hard coded configuration in
> smc91x.h can use the platform data flags method for configuration
> instead.

Yes, that's fine.


Nicolas
