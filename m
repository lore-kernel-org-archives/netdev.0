From: "Greg Scott" <GregScott@Infrasupport.com>
Subject: RE: Very confused about broute DROP
Date: Fri, 16 Sep 2011 09:55:47 -0500
Message-ID: <925A849792280C4E80C5461017A4B8A2A0443B@mail733.InfraSupportEtc.com>
References: <925A849792280C4E80C5461017A4B8A2A040F0@mail733.InfraSupportEtc.com> <20110711130729.607d461e@nehalam.ftrdhcpuser.net> <925A849792280C4E80C5461017A4B8A2A040F3@mail733.InfraSupportEtc.com> <20110711134938.5178797c@nehalam.ftrdhcpuser.net> <925A849792280C4E80C5461017A4B8A2A040F6@mail733.InfraSupportEtc.com> <20110712000242.GA616804@jupiter.n2.diac24.net> <925A849792280C4E80C5461017A4B8A2A040F8@mail733.InfraSupportEtc.com> <20110712033943.GB616804@jupiter.n2.diac24.net> <925A849792280C4E80C5461017A4B8A2A040FA@mail733.InfraSupportEtc.com> <20110712145438.GB909183@jupiter.n2.diac24.net> <925A849792280C4E80C5461017A4B8A2A040FB@mail733.InfraSupportEtc.com> <925A849792280C4E80C5461017A4B8A2A04134@mail733.InfraSupportEtc.com> <925A849792280C4E80C5461017A4B8A2A0413A@mail733.InfraSupportE
 tc.com> <925A849792280C4E80C5461017A4B8A2A04149@mail733.InfraSupportEtc.com> <925A849792280C4E80C5461017A4B8A2A0414B@mail733.InfraSupportEtc.com> <925A849792280C4E80C5461017A4B8A2A04438@mail733.Infr
	aSupportEtc.
	com> <184D23435BECB444AB6B9D4630C8EC83028548FD@XMB-RCD-303.cisco.com> <925A849792280C4E80C5461017A4B8A2A0443A@mail733.InfraSupportEtc.com> <184D23435BECB444AB6B9D4630C8EC8302854957@XMB-RCD-303.cisco.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "Graham Parenteau" <adfgrahame1@gmail.com>
To: "Christian Benvenuti \(benve\)" <benve@cisco.com>,
	<netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.infrasupportetc.com ([216.160.2.132]:51279 "EHLO
	mail.InfraSupportEtc.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752481Ab1IPOzt convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 16 Sep 2011 10:55:49 -0400
Content-class: urn:content-classes:message
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Definitely counter-intuitive in my head.  Three little ebtables rules -
ACCEPT anything IPv4 - which includes ARPs - for a couple of IP
Addresses and then DROP everything else for all protocols.  (Which
really means bridge for those IPv4 Addresses and route for everything
else.)

I don't see how a rule specific to ARPs matters here.  ARP is an IPv4
protocol and should be implied in the rules I set up - right?  Why a
rule specific to ARPs when it's already part of IPv4?

This just hit me - layer 2 is stateless.  I have ACCEPT rules for frames
bound for **destination** IPv4 IP Addresses.  I wonder if I need similar
rules for these same IP Addresses as sources?  But that still doesn't
make sense - that rule to DROP everything else covers all sources and
all destinations.  When I put in that ebtables DROP rule, the box turns
into a black hole instead of a router.  

Maybe one day the lightbulb will light up in my head, but right now I
still don't get it.

- Greg



-----Original Message-----
From: Christian Benvenuti (benve) [mailto:benve@cisco.com] 
Sent: Thursday, September 15, 2011 11:23 PM
To: Greg Scott; netdev@vger.kernel.org
Cc: Graham Parenteau
Subject: RE: Very confused about broute DROP

What I meant is that your host needs to be able to route
(which means ... to process) its own ARP traffic, ... IPv4
does not work without ARP, right?
This means you need to add one more DROP rule for the ARP
traffic that is addressed to the MAC of the host interfaces
(nothing to do with proxy ARP).

/Chris
