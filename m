From: "Greg Scott" <GregScott@Infrasupport.com>
Subject: RE: Bridging behavior apparently changed around the Fedora 14 time
Date: Fri, 22 Jul 2011 01:20:13 -0500
Message-ID: <925A849792280C4E80C5461017A4B8A2A0414B@mail733.InfraSupportEtc.com>
References: <925A849792280C4E80C5461017A4B8A2A040F0@mail733.InfraSupportEtc.com> <20110711130729.607d461e@nehalam.ftrdhcpuser.net> <925A849792280C4E80C5461017A4B8A2A040F3@mail733.InfraSupportEtc.com> <20110711134938.5178797c@nehalam.ftrdhcpuser.net> <925A849792280C4E80C5461017A4B8A2A040F6@mail733.InfraSupportEtc.com> <20110712000242.GA616804@jupiter.n2.diac24.net> <925A849792280C4E80C5461017A4B8A2A040F8@mail733.InfraSupportEtc.com> <20110712033943.GB616804@jupiter.n2.diac24.net> <925A849792280C4E80C5461017A4B8A2A040FA@mail733.InfraSupportEtc.com> <20110712145438.GB909183@jupiter.n2.diac24.net> <925A849792280C4E80C5461017A4B8A2A040FB@mail733.InfraSupportEtc.com> <925A849792280C4E80C5461017A4B8A2A04134@mail733.InfraSupportEtc.com> <925A849792280C4E80C5461017A4B8A2A0413A@mail733.InfraSupportE
 tc.com> <925A849792280C4E80C5461017A4B8A2A04149@mail733.InfraSupportEtc.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "Lynn Hanson" <LynnHanson@eaganhills.org>,
	"Joe Whalen" <JoeWhalen@eaganhills.org>,
	"Graham Parenteau" <adfgrahame1@gmail.com>,
	"David Lamparter" <equinox@diac24.net>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.infrasupportetc.com ([216.160.2.132]:44689 "EHLO
	mail.InfraSupportEtc.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752172Ab1GVGUO convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 22 Jul 2011 02:20:14 -0400
Content-class: urn:content-classes:message
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hang on a second - David, I think you're trying to tell me I'm the
problem.  Maybe so...

I send a frame in on eth1/br0.  It traverses a bunch of ebtables and
iptables DNAT and SNAT rules and then wants to come back out on
eth1/br0.  But this is both a bridge and a router, and trying to
remember my bridge basics - as I recall, bridges might not want to
forward frames back out the same physical interface they came in on.  

After running this frame/packet through a gauntlet of ebtables/iptables
rules and NATing the snot out of the IP packet inside the frame, I
wonder if it's still the same layer 2 frame when it gets ready to come
back out on eth1?  Even though NAT changed the layer 3 routed packet IP
info, I wonder if it's still the same layer 2 datalink frame?  So the
bridge says, "No way Jose, that's the same physical interface you came
in on" and drops it.  

And then turning on promisc mode makes the bridge less picky and it
happily forwards all frames everywhere.  

Is this what you've been trying to tell me and I'm too thickheaded to
get it?

If so, to work around the problem, I was reading about some ebtables
broute ACCEPT/DROP targets that are apparently named badly - DROP
apparently tells the bridge to route the packet instead of bridging the
frame, while ACCEPT tells the bridge to bridge it.  Should I be looking
in this direction?

But thinking about this some more - there are cases, such as cascaded
switches, or hubs behind a switch, where you want a bridge to forward
frames back out the same interface.  Well . . . maybe.  There's still
something about forwarding out the same interface a frame comes in on
that's bugging me.

- Greg

