From: Krzysztof Halasa <khc@pm.waw.pl>
Subject: Re: [PATCH v2] Re: WAN: new PPP code for generic HDLC
Date: Tue, 25 Mar 2008 16:50:27 +0100
Message-ID: <m3skyeby64.fsf@maximus.localdomain>
References: <m3prtzsszg.fsf@maximus.localdomain>
	<m3tzj92xq6.fsf@maximus.localdomain>
	<m33aqedg0a.fsf@maximus.localdomain> <47E91256.3010000@garzik.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Andrew Morton <akpm@linux-foundation.org>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: Jeff Garzik <jeff@garzik.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from khc.piap.pl ([195.187.100.11]:51420 "EHLO khc.piap.pl"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757707AbYCYPu3 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 25 Mar 2008 11:50:29 -0400
In-Reply-To: <47E91256.3010000@garzik.org> (Jeff Garzik's message of "Tue\, 25 Mar 2008 10\:55\:18 -0400")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Jeff Garzik <jeff@garzik.org> writes:

> 	I guess it should go into 2.6.25, not sure about "stable"
> 	series. I will appreciate any feedback, review and/or test
> 	results.

Right. Perhaps I should care a bit more about the stable series...

> At the time of the posting 2.6.25-rc6 had already been released, which
> seems like an inappropriate time for all that new code, which has been
> given so little exposure to real world testing.

Sure.

> Certainly your original message said PPP panics, but without even
> minimal testing how do we know that your new code doesn't have equally
> problematic issues?

Well, there was something like "minimal testing", and it doesn't panic
100% like the old code does. But the probability that it won't work
correctly is quite high.

IOW: the new version is certainly better than the old one, though it's
not the normal quality (in terms of testing) I'd like to see.

> So quite honestly a CONFIG_BROKEN patch might indeed be more
> appropriate since generic HDLC works with Frame Relay at least...

Actually Frame Relay and other protocols are not affected, the PPP
patch doesn't change them a bit, it's a different module. The new code
only affect PPP protocol.

I'm fine with the Kconfig patch, actually I'm not sure what is better
at this time - a known broken module marked as such or a new module
with some small chances that it will crash the machine and with much
bigger chances that it won't work with a certain PPP implementation on
the other end.

Something like that?
Untested :-)

Signed-off-by: Krzysztof Halasa <khc@pm.waw.pl>

--- a/drivers/net/wan/Kconfig
+++ b/drivers/net/wan/Kconfig
@@ -150,9 +150,13 @@ config HDLC_FR
 
 config HDLC_PPP
 	tristate "Synchronous Point-to-Point Protocol (PPP) support"
-	depends on HDLC
+	depends on HDLC && BROKEN
 	help
 	  Generic HDLC driver supporting PPP over WAN connections.
+	  This module is currently broken and will cause a kernel panic
+	  when a device configured in PPP mode is activated.
+
+	  It will be replaced by new PPP implementation in Linux 2.6.26.
 
 	  If unsure, say N.
 
