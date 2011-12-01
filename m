From: David Lamparter <equinox@diac24.net>
Subject: Re: ebtables on a stick
Date: Thu, 1 Dec 2011 17:50:40 +0100
Message-ID: <20111201165040.GL589422@jupiter.n2.diac24.net>
References: <925A849792280C4E80C5461017A4B8A2A04879@mail733.InfraSupportEtc.com>
 <925A849792280C4E80C5461017A4B8A2A0487A@mail733.InfraSupportEtc.com>
 <925A849792280C4E80C5461017A4B8A2A0487F@mail733.InfraSupportEtc.com>
 <20111128143901.GA589422@jupiter.n2.diac24.net>
 <4ED566A8.2000108@ziu.info>
 <925A849792280C4E80C5461017A4B8A2A048F6@mail733.InfraSupportEtc.com>
 <20111201071456.GJ589422@jupiter.n2.diac24.net>
 <925A849792280C4E80C5461017A4B8A2A048F8@mail733.InfraSupportEtc.com>
 <20111201144745.GK589422@jupiter.n2.diac24.net>
 <925A849792280C4E80C5461017A4B8A2A048F9@mail733.InfraSupportEtc.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Lamparter <equinox@diac24.net>, netdev@vger.kernel.org
To: Greg Scott <GregScott@Infrasupport.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from spaceboyz.net ([87.106.131.203]:54130 "EHLO spaceboyz.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755442Ab1LAQur (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 1 Dec 2011 11:50:47 -0500
Content-Disposition: inline
In-Reply-To: <925A849792280C4E80C5461017A4B8A2A048F9@mail733.InfraSupportEtc.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Dec 01, 2011 at 09:29:59AM -0600, Greg Scott wrote:
> > That /32 just means "on my ethernet segment i'm alone with that
> > address". If the windows box has /28 as subnet mask, it will try to
> ARP
> > for other hosts from that subnet, instead of going through the router.
> > So, that'll break connectivity to them...
> 
> I never did get this. Right now, it's a test Windows box, but eventually
> it will be something else.  It's connected to eth1 and needs to go
> through the router - right - so how does it find its gateway at
> 1.2.115.146 on eth0?  And setting the mask to /32 makes it even
> stranger.
> 
> As long as I can get to it - why don't I try setting it to /32 and let's
> see what happens.  Worst case, I have to jump in the car I guess.  Well,
> Windows won't allow a mask of 255.255.255.255.  I wonder how the real
> stuff I'll eventually connect at that IP Address will behave with a /32
> mask?

The default gateway is always assumed to be on-link / arp-able. Because
if it wasn't, it wouldn't be an usable default gateway...

On the box I'm writing this mail from right now:

# ip -4 a l eth0; ip r l match 0.0.0.0; ip r l exact 10.255.255.1
2: eth0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc pfifo_fast
state UNKNOWN qlen 1000
    inet 87.106.131.203/32 scope global eth0
default via 10.255.255.1 dev eth0
10.255.255.1 dev eth0  scope link

(that config is pushed through DHCP)

> I wonder what happens with some of the stuff I'm NATing?  There's a
> website at public IP 1.2.115.151, private 192.168.10.8.  Pinging
> 1.2.115.151 and then arp -a; it shows the firewall eth1 MAC Address.
> Makes sense - it is NATed after all.

I don't work with windows and have no clue what's happening there :)

Well, as long as it works, I guess that's fine.


-David
