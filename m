From: Or Gerlitz <or.gerlitz@gmail.com>
Subject: Re: extending ndo_add_rx_vxlan_port
Date: Mon, 28 Oct 2013 09:35:29 +0200
Message-ID: <CAJZOPZLAg+5dYS=bUCkDMyYq8EmA_uvEv1Zi+drq6Qqe5onrzQ@mail.gmail.com>
References: <526D2F8F.1070204@mellanox.com>
	<alpine.LFD.2.03.1310271017120.19783@intel.com>
	<CAJZOPZ+S6ngqMjV-2ZMcpzkuWzzLWwCQMtd_1_SjDkqWh_tbYg@mail.gmail.com>
	<alpine.LFD.2.03.1310271635540.15400@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Or Gerlitz <ogerlitz@mellanox.com>,
	John Fastabend <john.r.fastabend@intel.com>,
	Yan Burman <yanb@mellanox.com>,
	netdev <netdev@vger.kernel.org>,
	Stephen Hemminger <stephen@networkplumber.org>
To: Joseph Gasparakis <joseph.gasparakis@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f45.google.com ([209.85.220.45]:62271 "EHLO
	mail-pa0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755661Ab3J1Hfa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 28 Oct 2013 03:35:30 -0400
Received: by mail-pa0-f45.google.com with SMTP id kp14so6485534pab.18
        for <netdev@vger.kernel.org>; Mon, 28 Oct 2013 00:35:29 -0700 (PDT)
In-Reply-To: <alpine.LFD.2.03.1310271635540.15400@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Oct 28, 2013 at 1:44 AM, Joseph Gasparakis wrote:

> VXLAN implementation is not done like VLAN. VLANs are stacked on top of
> real interfaces and what you are saying makes sense. VXLAN however is
> using ip[6]_tunnel_xmit, and this is why we need to notify all the

As the name of the ndo you added ndo_add_rx_vxlan_port suggests -- HW
needs that for RX offloads. So basically, what I am saying is: in a
similar manner that we already program the NIC "over which" the vxlan
instance is set to listen on the multicast address which is associated
with that vxlan segement, lets give them a hint that packets arriving
on this group are vxlan ones, so they can use it for programming
steering rules.


> netdevs in the system that implement the add/del vxlan port ndo (i.e. are
> capable of offloading inner csums). In effect all physical "real" netdevs
> are candidates to receive/transmit VXLAN traffic, subject to routing
> tables changing or not.
