From: Bill Fink <billfink@mindspring.com>
Subject: Re: Receive side performance issue with multi-10-GigE and NUMA
Date: Fri, 21 Aug 2009 00:00:54 -0400
Message-ID: <20090821000054.3aea8bf6.billfink@mindspring.com>
References: <20090807170600.9a2eff2e.billfink@mindspring.com>
	<20090808112636.GB18518@localhost.localdomain>
	<4A7DC230.6060206@myri.com>
	<20090808183251.GA23300@localhost.localdomain>
	<20090811033210.6b422ed1.billfink@mindspring.com>
	<87ws5af0km.fsf@basil.nowhere.org>
	<20090812003049.185cd52a.billfink@mindspring.com>
	<4A856781.2080301@myri.com>
	<20090814123832.a7a27a9d.billfink@mindspring.com>
	<4A859716.7040904@myri.com>
	<3000d2e90908141413h3e3eae1dm796f4bf788319561@mail.gmail.com>
	<20090820032601.03a628cf.billfink@mindspring.com>
	<1250774056.16001.157.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Aviv Greenberg <avivgnet@gmail.com>,
	Andrew Gallatin <gallatin@myri.com>, netdev@vger.kernel.org
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from elasmtp-masked.atl.sa.earthlink.net ([209.86.89.68]:51945 "EHLO
	elasmtp-masked.atl.sa.earthlink.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750739AbZHUEAz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 21 Aug 2009 00:00:55 -0400
In-Reply-To: <1250774056.16001.157.camel@localhost>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 20 Aug 2009, Ben Hutchings wrote:

> On Thu, 2009-08-20 at 03:26 -0400, Bill Fink wrote:
> > On Sat, 15 Aug 2009, Aviv Greenberg wrote:
> > 
> > > >  There may be something in the chipset
> > > 
> > > shooting in the dark: when you lspci -vvv and check the MaxPayload and
> > > MaxReadReq values for the myri devices - what are the values and are
> > > they equal? Are they the same on all your platforms?
> > 
> > IIRC, under DevCap they indicated MaxPayload 4096 bytes, and under
> > DevCtl they indicated MaxPayload 128 bytes and MaxReadReq 4096 bytes,
> > and was the same on both the Asus and SuperMicro systems.  I will
> > doublecheck tomorrow at work.  I am not clear on the meanings of
> > the different parameters.  And is DevCtl for PCI control messages
> > and DevCap for actual data transfers or something else?
> 
> DevCap is the capability register, which is read-only; DevCtl is the
> control register which holds the actual settings.
> 
> MaxPayload is the MTU and MRU for PCIe packets.  Each sub-tree of
> devices connected to a single PCIe root port needs to have MaxPayload
> set consistently.  MaxReadReq is the maximum size of any DMA read
> request.  It is a per-device setting (or possibly per-function; I
> forget).  It can be much larger than MaxPayload since read completions
> can be fragmented.

Thanks for the explanation.  I saw a BIOS setting that allowed
increasing the MaxPayload from 128 bytes to 256 bytes, and then
verified that an "lspci -vvv" then showed the DevCtl MaxPayload
to be 256 bytes.  But unfortunately it didn't help improve the
read side performance any.

						-Bill
