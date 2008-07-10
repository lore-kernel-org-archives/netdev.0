From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: [PATCH] Documentation: clarify tcp_{r,w}mem sysctl docs
Date: Thu, 10 Jul 2008 16:05:10 -0400
Message-ID: <20080710200510.GE27734@fieldses.org>
References: <adar6a4x510.fsf@cisco.com> <20080708134845.2372a483@speedy> <20080708180500.e8a61231.billfink@mindspring.com> <20080709052534.GA8157@2ka.mipt.ru> <20080709014758.d59be0d8.billfink@mindspring.com> <20080709060341.GA29743@2ka.mipt.ru> <20080709181122.GB488@fieldses.org> <20080709184329.GC5383@2ka.mipt.ru> <20080709222802.GK488@fieldses.org> <20080710010649.GA28491@2ka.mipt.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Bill Fink <billfink@mindspring.com>,
	Stephen Hemminger <stephen.hemminger@vyatta.com>,
	Roland Dreier <rdreier@cisco.com>,
	David Miller <davem@davemloft.net>, aglo@citi.umich.edu,
	shemminger@vyatta.com, netdev@vger.kernel.org, rees@umich.edu,
	Evgeniy Polyakov <johnpol@2ka.mipt.ru>
To: Jonathan Corbet <corbet@lwn.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.fieldses.org ([66.93.2.214]:50658 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753301AbYGJUFS (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 10 Jul 2008 16:05:18 -0400
Content-Disposition: inline
In-Reply-To: <20080710010649.GA28491@2ka.mipt.ru>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: J. Bruce Fields <bfields@citi.umich.edu>
Date: Wed, 9 Jul 2008 18:28:48 -0400

Fix some of the defaults and attempt to clarify some language.

Signed-off-by: J. Bruce Fields <bfields@citi.umich.edu>
Cc: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
---
 Documentation/networking/ip-sysctl.txt |   26 +++++++++++++++-----------
 1 files changed, 15 insertions(+), 11 deletions(-)

On Thu, Jul 10, 2008 at 05:06:50AM +0400, Evgeniy Polyakov wrote:
> On Wed, Jul 09, 2008 at 06:28:02PM -0400, J. Bruce Fields
> (bfields@fieldses.org) wrote:
> > OK, thanks.  Would the following be any more clearer and/or
> > accurate?
>
> Looks good, thank you :)
> It is likely the first ever mention of the fact, that SO_RECV/SNDBUF
> disables autotuning.

OK!  Uh, I'm assuming Jon Corbet's documentation tree would be a
reasonable route to submit this by....

--b.

diff --git a/Documentation/networking/ip-sysctl.txt b/Documentation/networking/ip-sysctl.txt
index 17a6e46..a22af04 100644
--- a/Documentation/networking/ip-sysctl.txt
+++ b/Documentation/networking/ip-sysctl.txt
@@ -336,7 +336,7 @@ tcp_rmem - vector of 3 INTEGERs: min, default, max
 	pressure.
 	Default: 8K
 
-	default: default size of receive buffer used by TCP sockets.
+	default: initial size of receive buffer used by TCP sockets.
 	This value overrides net.core.rmem_default used by other protocols.
 	Default: 87380 bytes. This value results in window of 65535 with
 	default setting of tcp_adv_win_scale and tcp_app_win:0 and a bit
@@ -344,8 +344,10 @@ tcp_rmem - vector of 3 INTEGERs: min, default, max
 
 	max: maximal size of receive buffer allowed for automatically
 	selected receiver buffers for TCP socket. This value does not override
-	net.core.rmem_max, "static" selection via SO_RCVBUF does not use this.
-	Default: 87380*2 bytes.
+	net.core.rmem_max.  Calling setsockopt() with SO_RCVBUF disables
+	automatic tuning of that socket's receive buffer size, in which
+	case this value is ignored.
+	Default: between 87380B and 4MB, depending on RAM size.
 
 tcp_sack - BOOLEAN
 	Enable select acknowledgments (SACKS).
@@ -419,19 +421,21 @@ tcp_window_scaling - BOOLEAN
 	Enable window scaling as defined in RFC1323.
 
 tcp_wmem - vector of 3 INTEGERs: min, default, max
-	min: Amount of memory reserved for send buffers for TCP socket.
+	min: Amount of memory reserved for send buffers for TCP sockets.
 	Each TCP socket has rights to use it due to fact of its birth.
 	Default: 4K
 
-	default: Amount of memory allowed for send buffers for TCP socket
-	by default. This value overrides net.core.wmem_default used
-	by other protocols, it is usually lower than net.core.wmem_default.
+	default: initial size of send buffer used by TCP sockets.  This
+	value overrides net.core.wmem_default used by other protocols.
+	It is usually lower than net.core.wmem_default.
 	Default: 16K
 
-	max: Maximal amount of memory allowed for automatically selected
-	send buffers for TCP socket. This value does not override
-	net.core.wmem_max, "static" selection via SO_SNDBUF does not use this.
-	Default: 128K
+	max: Maximal amount of memory allowed for automatically tuned
+	send buffers for TCP sockets. This value does not override
+	net.core.wmem_max.  Calling setsockopt() with SO_SNDBUF disables
+	automatic tuning of that socket's send buffer size, in which case
+	this value is ignored.
+	Default: between 64K and 4MB, depending on RAM size.
 
 tcp_workaround_signed_windows - BOOLEAN
 	If set, assume no receipt of a window scaling option means the
-- 
1.5.5.rc1

