From: Stefan Richter <stefanr@s5r6.in-berlin.de>
Subject: Re: [RFC:] struct net_device_ops: Add function pointer to fill
 device specific ndisc information
Date: Mon, 21 Jan 2013 09:28:06 +0100
Message-ID: <20130121092806.3c741bd2@stein>
References: <50FC2EE4.3080705@gmail.com>
	<20130120212233.GA6776@ppwaskie-mobl2.amr.corp.intel.com>
	<50FCDD89.3020403@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: "Waskiewicz Jr, Peter P" <peter.p.waskiewicz.jr@intel.com>,
	linux1394-devel@lists.sourceforge.net, netdev@vger.kernel.org,
	yoshfuji@linux-ipv6.org, davem@davemloft.net
To: stephan.gatzka@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from einhorn.in-berlin.de ([192.109.42.8]:48359 "EHLO
	einhorn.in-berlin.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751509Ab3AUI22 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 21 Jan 2013 03:28:28 -0500
In-Reply-To: <50FCDD89.3020403@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Jan 21 Stephan Gatzka wrote:
> On Jan 20 Waskiewicz Jr, Peter P wrote:
> > I'm no expert on firewire requirements, but if you go down the path
> > of adding a net_device_ops member, I'd recommend adding a pointer
> > to your own struct of ops.  This would be similar to wireless ops.
> >
> > Only a suggestion, since you may still need to add more ops later
> > on, and this way you can contain the inflation to a firewire-specific
> > struct of function pointers.
> >
> 
> Thanks for your note. Right now I only need on function pointer for 
> filling RFC3146 information and I can imagine doing the same for 
> IPv4/ARP which would be a second function.

There is a limited count of IEEE 1394 specifics:

  a) RFC 2734 ARP:  currently implemented by inspecting and mangling ARP
     packets within the firewire-net driver (inbound as well as outbound
     packets).

  b) RFC 2734 MCAP (Multicast Channel Allocation Protocol):  currently not
     implemented; not sure if needed (I see a few big downsides to using
     per-multicast-group channels); not sure if networking core support
     would be needed for this

  c) RFC 2855 DHCP for IEEE 1394:  currently not implemented; not sure if
     needed; not sure if it would concern the kernel at all

  d) RFC 3146 NDISC (Neighbor Discovery Protocol for IPv6):  That's the
     only real problem in search of a solution.

I bet there won't be any additional RFCs invented for networking over
1394, ever.
-- 
Stefan Richter
-=====-===-= ---= =-=-=
http://arcgraph.de/sr/
