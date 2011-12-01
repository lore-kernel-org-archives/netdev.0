From: David Lamparter <equinox@diac24.net>
Subject: Re: ebtables on a stick
Date: Thu, 1 Dec 2011 08:14:56 +0100
Message-ID: <20111201071456.GJ589422@jupiter.n2.diac24.net>
References: <925A849792280C4E80C5461017A4B8A2A04879@mail733.InfraSupportEtc.com>
 <925A849792280C4E80C5461017A4B8A2A0487A@mail733.InfraSupportEtc.com>
 <925A849792280C4E80C5461017A4B8A2A0487F@mail733.InfraSupportEtc.com>
 <20111128143901.GA589422@jupiter.n2.diac24.net>
 <4ED566A8.2000108@ziu.info>
 <925A849792280C4E80C5461017A4B8A2A048F6@mail733.InfraSupportEtc.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Lamparter <equinox@diac24.net>, netdev@vger.kernel.org
To: Greg Scott <GregScott@Infrasupport.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from spaceboyz.net ([87.106.131.203]:54282 "EHLO spaceboyz.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751306Ab1LAHPD (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 1 Dec 2011 02:15:03 -0500
Content-Disposition: inline
In-Reply-To: <925A849792280C4E80C5461017A4B8A2A048F6@mail733.InfraSupportEtc.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Nov 30, 2011 at 11:46:02PM -0600, Greg Scott wrote:
> Well this is frustrating.  Now my public host can communicate anywhere it wants internally but nothing outside. Maddening - the exact opposite problem I had before.  
> 
> Here is the config as it sits right now:
> 
> Public IP host (a Windows XP system placeholder for now)
> IP 1.2.115.157, default gw 1.2.115.146.

Note that since the IP should be 1.2.115.157/_32_, it doesn't make any
difference whether you use 1.2.115.146 for the defgw or 192.168.10.1,
since both are out-of-subnet.

> Firewall eth0 - 1.2.115.146/28
> Firewall eth1 - 192.168.10.1. 
> 
> /sbin/ip neigh add proxy 1.2.115.157 dev eth0
> /sbin/ip route add 1.2.115.157/32 dev eth1
> 
> As a troubleshooting step, I also put in:
> /sbin/ip addr add 1.2.115.146/28 dev eth1; so now both eth0 and eth1 have the same IP Address.  This feels ugly and I think I'll take it out because it made no difference.  

I agree, please remove.

> And the relevant iptables rules:
> 
> $IPTABLES -t nat -A POSTROUTING -s $1.2.115.157 -j ACCEPT
> $IPTABLES -t nat -A PREROUTING -d 1.2.115.157 -j ACCEPT
> 
> $IPTABLES -A FORWARD -s 1.2.115.157 -j ACCEPT

Where is the reverse rule of this? -d 1.2.115.157 -j ACCEPT

> $IPTABLES -A FORWARD -s 192.168.10.0/24 -d 1.2.115.157 -j ACCEPT
> $IPTABLES -A FORWARD -p TCP --dport 1720 -d $ADR -j allowed
> $IPTABLES -A FORWARD -p TCP -s $MGMT_IP -d $ADR -j allowed

(what's $ADR?)
[...]
> The ICMP echo reply comes back on eth0, still good.  But I never forward it over to eth1 and it dies right there.  The public host never sees the reply. 

Firewall rules?


-David
