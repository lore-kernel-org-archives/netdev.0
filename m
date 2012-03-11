From: Mitar <mmitar@gmail.com>
Subject: Re: Ethernet-over-UDP virtual network interface
Date: Sat, 10 Mar 2012 19:08:29 -0800
Message-ID: <CAKLmikPUo9JTrarmkG66FLurLS2TAwbhDNJA9RB+cFDo7odpFg@mail.gmail.com>
References: <CAKLmikOBPB7rTZu2EfK26=3AhOQUR8xg8n4ySUKRMFmBkC1J3g@mail.gmail.com>
	<20120304170101.GH21526@kvack.org>
	<CAKLmikOVydmSJEBWwDc=Jv4XPMi3dsS+Pn9=BP_bBePD0L7K8A@mail.gmail.com>
	<20120308161138.GB23774@kvack.org>
	<CAKLmikPtvOLgzuSTF=vwfZcMD7jWWRSgWaLxnSxBsa=2RSnPVA@mail.gmail.com>
	<20120310170619.GC22880@kvack.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, Nejc Skoberne <nejc@skoberne.net>,
	Jernej Kos <kostko@unimatrix-one.org>, gw.2012@tnode.com
To: Benjamin LaHaise <bcrl@kvack.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vx0-f174.google.com ([209.85.220.174]:50924 "EHLO
	mail-vx0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752088Ab2CKDIb convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 10 Mar 2012 22:08:31 -0500
Received: by vcqp1 with SMTP id p1so2920875vcq.19
        for <netdev@vger.kernel.org>; Sat, 10 Mar 2012 19:08:30 -0800 (PST)
In-Reply-To: <20120310170619.GC22880@kvack.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi!

On Sat, Mar 10, 2012 at 9:06 AM, Benjamin LaHaise <bcrl@kvack.org> wrot=
e:
> To be honest, I don't see any new stateless protocol actually being w=
idely
> supported.

Yes, I agree. This is probably because our use case is quite specific:
using consumer low-price range network equipment without any dedicated
network chips and so on. So simplicity is much more important to use
than, for example, security (which we do not care much on VPN links
because we already have everything open in the mesh so anybody can
capture or inject packets already, so there is no big reason why to do
any encryption or authentication (on the link level) on VPN links.

>=C2=A0Building a completely proprietary solution (regardless of it
> being open source or not) that isn't supported by any common hardware=
 or
> software networking platforms will paint yourself into a corner when =
it
> comes time to upgrade the network with additional capacity.

That's why I am trying to coordinate our efforts with at least Linux
kernel to be included in the kernel. And also, for example, OpenWrt
distribution. Then we will mostly cover all our target devices.

I am not sure what problems do you have in mind for when upgrading our
network with additional capacity?

> If you're using Linux as a router, I'd probably lean towards a VLAN b=
ased
> protocol, as anything exotic won't be supported by common nic's hardw=
are
> checksum offloading.

I do not understand what VLANs have with tunneling over the Internet?
We are building a mesh network, we parts of this network, which do not
see each other wirelessly, to connect through VPN tunnels. Because we
have cheap hardware we want simplest (CPU light) VPN solution to
connect those parts over existing infrastructure (read: ISPs).
=46urthermore, because nodes are deployed in chaotic and uncoordinated
fashion by volunteers those tunnels have to be self-configuring (or
zero-configuring). We can provide few VPN servers and all nodes then
connect there, connecting nodes connected to them to the rest of the
network.

> Stateless !=3D robust. =C2=A0To deal with failed links you need some =
sort of state
> that is maintained by the system to switch over to backup links.

No. This we do on L3 with dynamic routing protocol (like OLSR) which
we are already using because of the wireless nature of our network
(and because nodes are coming up and down as volunteers' mothers pull
out nodes' power supplies when they are vacuuming). So we just need L2
links. If they work (are not firewalled, VPN servers are online, ...)
or not then determines L3 routing protocol and setup routes
accordingly.

>=C2=A0Existing options (MPLS, GVRP, L2TP) can
> all be configured with a minimum amount of state, are widely used for=
 the
> scenario you're describing, and have migration paths when you need to
> upgrade to higher capacity switches/routers.

Will have to check this a bit more. I admit I do not know much about
MPLS and GVRP. But true, state is not so big problem if tunnels can
still be:

- kernel space only
- no encryption
- zero or auto configuration
- one server can accept multiple connections
- using UDP (and not IP) for transport
- of course, supported in Linux kernel


Mitar
