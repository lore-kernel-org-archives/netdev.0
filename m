From: Joseph Gasparakis <joseph.gasparakis@intel.com>
Subject: Re: extending ndo_add_rx_vxlan_port
Date: Sun, 27 Oct 2013 16:44:39 -0700 (PDT)
Message-ID: <alpine.LFD.2.03.1310271635540.15400@intel.com>
References: <526D2F8F.1070204@mellanox.com> <alpine.LFD.2.03.1310271017120.19783@intel.com> <CAJZOPZ+S6ngqMjV-2ZMcpzkuWzzLWwCQMtd_1_SjDkqWh_tbYg@mail.gmail.com>
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
Received: from mga03.intel.com ([143.182.124.21]:55376 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754649Ab3J0X2H (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 27 Oct 2013 19:28:07 -0400
In-Reply-To: <CAJZOPZ+S6ngqMjV-2ZMcpzkuWzzLWwCQMtd_1_SjDkqWh_tbYg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



On Sun, 27 Oct 2013, Or Gerlitz wrote:

> On Sun, Oct 27, 2013 at 7:25 PM, Joseph Gasparakis
> <joseph.gasparakis@intel.com> wrote:
> >
> >
> > On Sun, 27 Oct 2013, Or Gerlitz wrote:
> >
> >> Hi,
> >>
> >> So with commit 53cf527513eed6e7170e9dceacd198f9267171b0 "vxlan: Notify drivers
> >> for listening UDP port changes" drivers that have HW offloads for vxlan can be
> >> notified on which UDP port to listen. Taking this further, some HW may need to
> >> know the multicast address and/or the VNID used by the vxlan instance/s set
> >> above them. In that respect, do we prefer to extend ndo_add_rx_vxlan_port() or
> >> introduce new ndo?
> >>
> >> Or.
> >>
> >
> > The way this patch works is to notify the drivers when a VXLAN UDP port
> > comes up or down. This way drivers do not need to do any sort of accounting. As
> 
> Could you elaborate why do we want to notify all the netdev instances
> in the system (on a certain name-space)
> that vxlan instance/s are set to listen on certain UDP port and not
> only the device over which the
> vxlan device is being set? say the HW can listen limited amount of UDP
> ports and few vxlan instances are created
> one of top of each "real" netdev in the system and each on different
> port. Each netdevice will get all callbacks on port addition
> and at some point will start to fail adding them into the HW  when the
> HW limit is met.
> 
> Or.
> 
VXLAN implementation is not done like VLAN. VLANs are stacked on top of 
real interfaces and what you are saying makes sense. VXLAN however is 
using ip[6]_tunnel_xmit, and this is why we need to notify all the 
netdevs in the system that implement the add/del vxlan port ndo (i.e. are 
capable of offloading inner csums). In effect all physical "real" netdevs 
are candidates to receive/transmit VXLAN traffic, subject to routing 
tables changing or not.

Joseph
