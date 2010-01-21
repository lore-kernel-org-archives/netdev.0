From: Ben Hutchings <bhutchings@solarflare.com>
Subject: RE: Problems with tg3 driver after lowering the MTU
Date: Thu, 21 Jan 2010 18:30:05 +0000
Message-ID: <1264098605.2794.39.camel@achroite.uk.solarflarecom.com>
References: <ac67d9131001210721q37a6883eg85430f9564d8e007@mail.gmail.com>
	 <1264087643.2794.2.camel@achroite.uk.solarflarecom.com>
	 <ac67d9131001210742x7bb6af87o546007707c412835@mail.gmail.com>
	 <E1829B60731D1740BB7A0626B4FAF0A6467F0DA0D5@XCH-NW-01V.nw.nos.boeing.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Szilveszter Ordog <slipszi@gmail.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: "Templin, Fred L" <Fred.L.Templin@boeing.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.solarflare.com ([216.237.3.220]:42236 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752986Ab0AUSaJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 21 Jan 2010 13:30:09 -0500
In-Reply-To: <E1829B60731D1740BB7A0626B4FAF0A6467F0DA0D5@XCH-NW-01V.nw.nos.boeing.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2010-01-21 at 09:47 -0800, Templin, Fred L wrote:
> > -----Original Message-----
> > From: netdev-owner@vger.kernel.org [mailto:netdev-owner@vger.kernel.org] On Behalf Of Szilveszter
> > Ordog
> > Sent: Thursday, January 21, 2010 7:42 AM
> > To: netdev@vger.kernel.org
> > Subject: Re: Problems with tg3 driver after lowering the MTU
> > 
> > On Thu, Jan 21, 2010 at 16:27, Ben Hutchings <bhutchings@solarflare.com> wrote:
> > > On Thu, 2010-01-21 at 16:21 +0100, Szilveszter Ordog wrote:
> > >> After the MTU is lowered (e.g. to 1420) on a tg3-driven interface,
> > >> received packets larger than that (e.g. 1500 bytes) are silently
> > >> discarded by the driver. Therefore the system doesn't send ICMP
> > >> fragmentation-needed packets and the other side doesn't detect this
> > >> condition.
> > >>
> > >> Is this a known bug?
> > >
> > > I don't believe this a bug.  Within a local network, MTU should be set
> > > the same for all interfaces.  Routers that connect networks with
> > > different MTUs will generate the fragmentation-needed message as
> > > appropriate.
> > 
> > Other drivers do not behave like that. Most of them always allow
> > packets smaller than 1500 bytes. That is why I think that this is a
> > bug.
> 
> The question seems to be what happens when the
> Maximum Transmission Unit (MTU) is smaller than
> the Maximum Receive Unit (MRU)?
> 
> For TCP, MSS is calculated based on MTU (not MRU)
> so there should not be any size mismatches with TCP.
> For large packets of other IP protocols, it should
> be OK for the end system to receive a packet larger
> than it is capable of sending. So, it seems to me
> that packets that are larger than MTU but no larger
> than MRU should be accepted.

In theory, MRU and MTU could be quite separate.  However, there is no
standard interface to set an interface's MRU, so where the hardware
supports a variable MRU drivers normally set it based on the MTU.

Ben.

-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

