From: "Greg Scott" <GregScott@Infrasupport.com>
Subject: RE: ebtables on a stick
Date: Thu, 1 Dec 2011 08:10:45 -0600
Message-ID: <925A849792280C4E80C5461017A4B8A2A048F7@mail733.InfraSupportEtc.com>
References: <925A849792280C4E80C5461017A4B8A2A04879@mail733.InfraSupportEtc.com> <925A849792280C4E80C5461017A4B8A2A0487A@mail733.InfraSupportEtc.com> <925A849792280C4E80C5461017A4B8A2A0487F@mail733.InfraSupportEtc.com> <20111128143901.GA589422@jupiter.n2.diac24.net> <4ED566A8.2000108@ziu.info> <925A849792280C4E80C5461017A4B8A2A048F6@mail733.InfraSupportEtc.com> <20111201071456.GJ589422@jupiter.n2.diac24.net>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: <netdev@vger.kernel.org>
To: "David Lamparter" <equinox@diac24.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.infrasupportetc.com ([216.160.2.132]:26944 "EHLO
	mail.infrasupport.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754354Ab1LAOKr convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 1 Dec 2011 09:10:47 -0500
Content-class: urn:content-classes:message
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Oh - woops:

>> IP 1.2.115.157, default gw 1.2.115.146.
>
> Note that since the IP should be 1.2.115.157/_32_, it doesn't make any
> difference whether you use 1.2.115.146 for the defgw or 192.168.10.1,
> since both are out-of-subnet.

Right this second, the whole thing really is 1.2.115.157/28, or mask
255.255.255.240.  So from that host's point of view the default gw makes
sense.  You really want me to set that up as a /32?  I don't get it.  
.
.
.
>> As a troubleshooting step, I also put in:
>> /sbin/ip addr add 1.2.115.146/28 dev eth1; so now both eth0 and eth1
have the same IP Address.  This feels >ugly and I think I'll take it out
because it made no difference.  
>
>I agree, please remove.

I put it in last night because this was the "trick" I had to do years
ago when I used proxy ARP and that scary switch turning it on for
everything.  Btw, there are still write-ups out there advocating that
approach.
.
.
.
>> $IPTABLES -A FORWARD -s 1.2.115.157 -j ACCEPT
>
> Where is the reverse rule of this? -d 1.2.115.157 -j ACCEPT
>
>> $IPTABLES -A FORWARD -s 192.168.10.0/24 -d 1.2.115.157 -j ACCEPT
>> $IPTABLES -A FORWARD -p TCP --dport 1720 -d $ADR -j allowed
>> $IPTABLES -A FORWARD -p TCP -s $MGMT_IP -d $ADR -j allowed
>
>(what's $ADR?)

I was having trouble keeping my eyes open last night. $ADR ends up being
1.2.115.157.  That's the reverse rule you were looking for.  And then
$MGMT_IP is the rule that lets me in no matter what protocol/port.
Allowed is a user defined chain that checks for the right TCP handshake.
I should probably change the $MGMT_IP rule to just ACCEPT.  This won't
matter though - I did my ping tests last night physically sitting in
front of that XP host and trying to ping google.  

> Firewall rules?

There are a bunch of 'em to handle a website and a few ftp sites and a
PPTP VPN and the H.323 stuff I'm trying to hook back up.  I have a
little script named "allow-all-with-nat" that turns all the filtering
rules off, leaving all the NAT rules in place.  Running that makes no
difference.  The last time I posted a whole ruleset I was roundly
chastised because it was too complicated and we went off into a rathole
about H.323.  

- Greg
