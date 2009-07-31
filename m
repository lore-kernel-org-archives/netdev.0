From: Mark Smith <lk-netdev@lk-netdev.nosense.org>
Subject: Re: Bonding ALB sends bogus packets
Date: Fri, 31 Jul 2009 11:00:58 +0930
Message-ID: <20090731110058.0e4216ee.lk-netdev@lk-netdev.nosense.org>
References: <20090730130656.680e9152@nehalam>
	<22132.1248985699@death.nxdomain.ibm.com>
	<20090730133545.77e5a76a@nehalam>
	<20090731090658.db36b555.lk-netdev@lk-netdev.nosense.org>
	<4A72314C.9080007@hp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Stephen Hemminger <shemminger@vyatta.com>,
	Jay Vosburgh <fubar@us.ibm.com>,
	Ben Greear <greearb@candelatech.com>,
	bonding-devel@lists.sf.net, netdev@vger.kernel.org
To: Rick Jones <rick.jones2@hp.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.adam.net.au ([202.136.110.253]:43025 "EHLO
	smtp1.adam.net.au" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751199AbZGaBbU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 30 Jul 2009 21:31:20 -0400
In-Reply-To: <4A72314C.9080007@hp.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Rick,

On Thu, 30 Jul 2009 16:48:28 -0700
Rick Jones <rick.jones2@hp.com> wrote:

> Mark Smith wrote:
> > 
> > ETH_P_LOOP should probably have been avoided, as "LOOP" or "loopback"
> > is commonly used to refer to the Ethernet Configuration Testing
> > Protocol (google search for "Ethernet Loop protocol"). 
> 
> I wonder how that relates to linkloop:
> 
> http://sourceforge.net/projects/linkloop/
> 
> http://fr2.rpmfind.net/linux/RPM/opensuse/factory/x86_64/usr_share_doc_packages_linkloop_Tree.html
> 

> > 
> > I'd suggest not using any form of ARP for this purpose. It'd place an
> > IPv4 requirement on the bonded interface, and various "empty" ARP
> > frames have meaning e.g. duplicate address detection. 802.2 test frames
> > or the original Ethernet V2.0 Configuration Testing Protocol have been
> > used for this bridge table address refresh purpose in the past.
> 
> I can never remember if linkloop uses XID or Test frames :(
> 

>From memory when I looked into it a year or so ago, linkloop
used 802.2 test frames.

When I decided to have a go at implementing ECTP for the Linux kernel
a couple of years ago, one thing I didn't want to was to duplicate
already existing layer 2 testing functionality in the kernel, which
meant comparing 802.2 test frames capability verses ECTP. 802.2 test
frames only do single hop unicast request/reply testing, obviously
requiring you to already know the test unicast address. ECTP, in
addition, provides broadcast and optionally multicast ECTP capable node
discovery, and the ability test a path of nodes, by providing a list of
unicast addresses to visit i.e. a strict source route. As I've found
IPv4 'broadcast pings' occasionally useful, I thought a layer 2
equivalent, not requiring IPv4 to be functioning, would also be quite
useful.

ECTP could also probably be used over any 802.2 capable network, by
using the SNAP encoding with an OUI of 0x000000 and then a protocol ID
of 0x9000. 

(When you start looking into it, it's interesting how many layer 2
keepalive/testing protocols have been developed over the years,
including most recently the Ethernet OAM protocols. What is also
suprising is that the original Ethernet V2.0 Configuration Testing
Protocol tends to be more capable than any of them - they're usually
just single-hop request/reply testing)

Regards,
Mark.
