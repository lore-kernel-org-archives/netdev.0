From: "Christian Benvenuti (benve)" <benve@cisco.com>
Subject: RE: Very confused about broute DROP
Date: Thu, 15 Sep 2011 18:08:09 -0500
Message-ID: <184D23435BECB444AB6B9D4630C8EC83028548FD@XMB-RCD-303.cisco.com>
References: <925A849792280C4E80C5461017A4B8A2A040F0@mail733.InfraSupportEtc.com> <20110711130729.607d461e@nehalam.ftrdhcpuser.net> <925A849792280C4E80C5461017A4B8A2A040F3@mail733.InfraSupportEtc.com> <20110711134938.5178797c@nehalam.ftrdhcpuser.net> <925A849792280C4E80C5461017A4B8A2A040F6@mail733.InfraSupportEtc.com> <20110712000242.GA616804@jupiter.n2.diac24.net> <925A849792280C4E80C5461017A4B8A2A040F8@mail733.InfraSupportEtc.com> <20110712033943.GB616804@jupiter.n2.diac24.net> <925A849792280C4E80C5461017A4B8A2A040FA@mail733.InfraSupportEtc.com> <20110712145438.GB909183@jupiter.n2.diac24.net> <925A849792280C4E80C5461017A4B8A2A040FB@mail733.InfraSupportEtc.com> <925A849792280C4E80C5461017A4B8A2A04134@mail733.InfraSupportEtc.com> <925A849792280C4E80C5461017A4B8A2A0413A@mail733.InfraSupportE
 tc.com> <925A849792280C4E80C5461017A4B8A2A04149@mail733.InfraSupportEtc.com> <925A849792280C4E80C5461017A4B8A2A0414B@mail733.InfraSupportEtc.com> <925A849792280C4E80C5461017A4B8A2A04438@mail733.Infr
	aSupportEtc.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "Graham Parenteau" <adfgrahame1@gmail.com>
To: "Greg Scott" <GregScott@Infrasupport.com>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rcdn-iport-2.cisco.com ([173.37.86.73]:40814 "EHLO
	rcdn-iport-2.cisco.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S935157Ab1IOXIL convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 15 Sep 2011 19:08:11 -0400
Content-class: urn:content-classes:message
In-Reply-To: <925A849792280C4E80C5461017A4B8A2A04438@mail733.InfraSupportEtc.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

How about ARP? You need it too ...

> -----Original Message-----
> From: netdev-owner@vger.kernel.org [mailto:netdev-
> owner@vger.kernel.org] On Behalf Of Greg Scott
> Sent: Thursday, September 15, 2011 3:48 PM
> To: netdev@vger.kernel.org
> Cc: Graham Parenteau
> Subject: Very confused about broute DROP
> 
> I don't get this.  Why does:
> 
> ebtables -t broute -A BROUTING -j DROP
> 
> completely knock a Linux host offline?
> 
> This is what the man page for ebtables says:
> 
> The targets DROP and ACCEPT have a special meaning in the broute table
> (these names are used instead of more descriptive  names  to  keep the
> implementation  generic).   DROP  actually means the frame has to be
> routed, while ACCEPT means the frame has to be bridged. The BROUTING
> chain is traversed very early. However, it is  only  traversed  by
> frames  entering  on  a bridge port that is in forwarding state.
> Normally those frames would be bridged, but you can decide otherwise
> here. The redirect target is very handy here.
> 
> So based on the above paragraph, I should be able to do something like
> this:
> 
> # Here is what to bridge
> ebtables -t broute -A BROUTING -p IPv4 --ip-destination $PUBLIC_IP1 -j
> ACCEPT
> ebtables -t broute -A BROUTING -p IPv4 --ip-destination $PUBLIC_IP2 -j
> ACCEPT
> 
> # Route everything else
> ebtables -t broute -A BROUTING -j DROP
> 
> So I tried above and knocked that box completely offline.  I'm missing
> something.
> 
> Here is what the paragraph about redirect in the ebtables man pages
> says:
> 
> The  redirect target will change the MAC target address to that of the
> bridge device the frame arrived on. This target can only be used in
the
> BROUTING chain of the broute table and the PREROUTING chain of  the
> nat
> table.  In  the  BROUTING  chain,  the MAC address of the bridge port
> is
> used as destination address, in the PREROUTING chain, the MAC address
> of
> the bridge is used.
> 
> OK - so this target MAC address - is this the MAC Address of an ethnn
> port that's part of the bridge, or the MAC Address of another node?  I
> was thinking it was the MAC Address of another node, but maybe it's
> just
> the MAC Address of a port on this bridge?
> 
> And there are some examples here:
> http://ebtables.sourceforge.net/examples/basic.html#ex_redirect
> 
> that I really don't get.  So instead of trial and error guessing, I
> figured I would ask.
> 
> If anyone can help me understand this, I'll take a stab at writing it
> up
> as clearly as I know how for use in future versions of man pages.
> 
> Thanks
> 
> - Greg Scott
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
