From: stephen@dino.dnsalias.com (Stephen J. Bevan)
Subject: Re: [RFC] Ethernet Cheap Cryptography
Date: Fri, 20 Oct 2006 18:58:01 -0700
Message-ID: <17721.32425.591879.97484@localhost.localdomain>
References: <200610151820.22867.dpc@asn.pl>
	<17717.40394.531846.695392@localhost.localdomain>
	<200610181115.12471.dpc@asn.pl>
	<17718.63424.509719.492216@localhost.localdomain>
	<eh87aq$71t$1@sea.gmane.org>
	<17720.12801.843076.819750@localhost.localdomain>
	<ehbava$iia$1@sea.gmane.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from S010600014e000000.vc.shawcable.net ([70.79.40.36]:51469 "EHLO
	dino.dnsalias.com") by vger.kernel.org with ESMTP id S2992784AbWJUB7F
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 20 Oct 2006 21:59:05 -0400
To: Pawel Foremski <pjf@asn.pl>
In-Reply-To: <ehbava$iia$1@sea.gmane.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Pawel Foremski writes:
 > Consider such an example: our task is to bridge two LANs managed by a
 > third-party ISP over a wireless link, with the highest performance possible
 > for such medium. The ISP has its clients on one LAN and a PPPoE
 > concentrator on the second one.  Because the ISP doesn't trust us
 > or is not aware of our bridge, it uses MPPE to secure PPP. We
 > cannot enforce any changes to the way the ISP provides services to
 > its end users.  
 > 
 > In ASCII art, that would be:
 > 
 > [PPPoE server]---[Linux#1]--ccrypt--[dumb WiFi bridge] )))  \/
 >                                                             ||
 > [PPPoE client]---[Linux#2]--ccrypt--[dumb WiFi bridge] ((( <=/
 > 
 > Obviously, the dumb WiFi bridge cannot speak anything other than 1500-byte,
 > plain (not encrypted) Ethernet.

Since there was no mention of bridging in the ccrypt documentation or
previously in the email thread I (incorrectly) assumed that PPPoE was
terminating on the Linux box.  Thus the IP traffic would be visible
and hence IPsec could be used.  Clearly if the Linux box is bridging
PPPoE as you note above then IPsec is not viable.  Thus the addition
of the above scenario to the ccrypt documentation help would avoid
getting questions about why you can't use IPsec :-)

However, in the above you note that MPPE is being used.  I take this
to mean that all the PPP traffic between the PPPoE client and PPPoE
server is encrypted.  However, if that's the case then I don't
understand why there is a need to use ccrypt for the wireless link
between the two Linux boxes.  Thus perhaps I misunderstood where MPPE
is being used?  Or perhaps you meant this is only one example and in
other scenarios MPPE is not used and so in that case the wireless
traffic does need encrypting?
