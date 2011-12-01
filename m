From: "Greg Scott" <GregScott@Infrasupport.com>
Subject: RE: ebtables on a stick
Date: Thu, 1 Dec 2011 09:29:59 -0600
Message-ID: <925A849792280C4E80C5461017A4B8A2A048F9@mail733.InfraSupportEtc.com>
References: <925A849792280C4E80C5461017A4B8A2A04879@mail733.InfraSupportEtc.com> <925A849792280C4E80C5461017A4B8A2A0487A@mail733.InfraSupportEtc.com> <925A849792280C4E80C5461017A4B8A2A0487F@mail733.InfraSupportEtc.com> <20111128143901.GA589422@jupiter.n2.diac24.net> <4ED566A8.2000108@ziu.info> <925A849792280C4E80C5461017A4B8A2A048F6@mail733.InfraSupportEtc.com> <20111201071456.GJ589422@jupiter.n2.diac24.net> <925A849792280C4E80C5461017A4B8A2A048F8@mail733.InfraSupportEtc.com> <20111201144745.GK589422@jupiter.n2.diac24.net>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: <netdev@vger.kernel.org>
To: "David Lamparter" <equinox@diac24.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.infrasupportetc.com ([216.160.2.132]:28244 "EHLO
	mail.infrasupport.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755043Ab1LAPaB convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 1 Dec 2011 10:30:01 -0500
Content-class: urn:content-classes:message
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> That /32 just means "on my ethernet segment i'm alone with that
> address". If the windows box has /28 as subnet mask, it will try to
ARP
> for other hosts from that subnet, instead of going through the router.
> So, that'll break connectivity to them...

I never did get this. Right now, it's a test Windows box, but eventually
it will be something else.  It's connected to eth1 and needs to go
through the router - right - so how does it find its gateway at
1.2.115.146 on eth0?  And setting the mask to /32 makes it even
stranger.

As long as I can get to it - why don't I try setting it to /32 and let's
see what happens.  Worst case, I have to jump in the car I guess.  Well,
Windows won't allow a mask of 255.255.255.255.  I wonder how the real
stuff I'll eventually connect at that IP Address will behave with a /32
mask?

Digging a little deeper...

>From Windows, arp -a shows both 1.2.114.146 and 192.168.10.1 with a MAC
Address of 00-0d-88-31-d8-24.  Looking on the firewall with ip link show
- sure enough, that's the MAC Address of eth1.  

I wonder what happens with some of the stuff I'm NATing?  There's a
website at public IP 1.2.115.151, private 192.168.10.8.  Pinging
1.2.115.151 and then arp -a; it shows the firewall eth1 MAC Address.
Makes sense - it is NATed after all.

Launching IE from that host - nope - that NATed website doesn't come up.
But it doesn't time out, it errors right away, suggesting it was
rejected instead of dropped.  Well, OK - that's probably because I don't
have any firewall rules to handle this case (and probably don't need any
because this will never happen in production), so it went right to the
firewall itself and was properly rejected.  

But the eventual box at this address will probably have its own built-in
management website.  I wonder what happens with telnets on port 80 and
443 to it?  They both work; the firewall forwards it and the Windows box
rejects it.  So when there's a real website sitting there, it should be
OK.  

So the /28 mask feels OK so far...

- Greg
