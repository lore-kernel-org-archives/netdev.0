From: Joseph Gasparakis <joseph.gasparakis@intel.com>
Subject: Re: extending ndo_add_rx_vxlan_port
Date: Mon, 28 Oct 2013 10:59:12 -0700 (PDT)
Message-ID: <alpine.LFD.2.03.1310281049210.31450@intel.com>
References: <526D2F8F.1070204@mellanox.com> <alpine.LFD.2.03.1310271017120.19783@intel.com> <CAJZOPZ+S6ngqMjV-2ZMcpzkuWzzLWwCQMtd_1_SjDkqWh_tbYg@mail.gmail.com> <alpine.LFD.2.03.1310271635540.15400@intel.com>
 <CAJZOPZLAg+5dYS=bUCkDMyYq8EmA_uvEv1Zi+drq6Qqe5onrzQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Joseph Gasparakis <joseph.gasparakis@intel.com>,
	Or Gerlitz <ogerlitz@mellanox.com>,
	John Fastabend <john.r.fastabend@intel.com>,
	Yan Burman <yanb@mellanox.com>,
	netdev <netdev@vger.kernel.org>,
	Stephen Hemminger <stephen@networkplumber.org>
To: Or Gerlitz <or.gerlitz@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:36294 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757225Ab3J1Rmj (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 28 Oct 2013 13:42:39 -0400
In-Reply-To: <CAJZOPZLAg+5dYS=bUCkDMyYq8EmA_uvEv1Zi+drq6Qqe5onrzQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



On Mon, 28 Oct 2013, Or Gerlitz wrote:

> On Mon, Oct 28, 2013 at 1:44 AM, Joseph Gasparakis wrote:
> 
> > VXLAN implementation is not done like VLAN. VLANs are stacked on top of
> > real interfaces and what you are saying makes sense. VXLAN however is
> > using ip[6]_tunnel_xmit, and this is why we need to notify all the
> 
> As the name of the ndo you added ndo_add_rx_vxlan_port suggests -- HW
> needs that for RX offloads. So basically, what I am saying is: in a
> similar manner that we already program the NIC "over which" the vxlan
> instance is set to listen on the multicast address which is associated
> with that vxlan segement, lets give them a hint that packets arriving
> on this group are vxlan ones, so they can use it for programming
> steering rules.

Why don't you write up some code so everyone has something to look at?
Then we can see what makes sense to do in terms of the existing or new 
ndos.

> 
> 
> > netdevs in the system that implement the add/del vxlan port ndo (i.e. are
> > capable of offloading inner csums). In effect all physical "real" netdevs
> > are candidates to receive/transmit VXLAN traffic, subject to routing
> > tables changing or not.
> 
