From: Phil Sutter <phil@nwl.cc>
Subject: [iproute PATCH 4/6] man: ip-address: document mngtmpaddr and noprefixroute flags
Date: Fri, 18 Sep 2015 20:17:03 +0200
Message-ID: <1442600225-18355-5-git-send-email-phil@nwl.cc>
References: <1442600225-18355-1-git-send-email-phil@nwl.cc>
Cc: netdev@vger.kernel.org
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from orbit.nwl.cc ([176.31.251.142]:45203 "EHLO mail.nwl.cc"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752217AbbIRSRJ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 18 Sep 2015 14:17:09 -0400
In-Reply-To: <1442600225-18355-1-git-send-email-phil@nwl.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Phil Sutter <phil@nwl.cc>
---
 man/man8/ip-address.8.in | 18 +++++++++++++++++-
 1 file changed, 17 insertions(+), 1 deletion(-)

diff --git a/man/man8/ip-address.8.in b/man/man8/ip-address.8.in
index 43611b9..159d906 100644
--- a/man/man8/ip-address.8.in
+++ b/man/man8/ip-address.8.in
@@ -67,7 +67,7 @@ temporary " | " CONFFLAG-LIST " ]"
 
 .ti -8
 .IR CONFFLAG " := "
-.RB "[ " home " | " nodad " ]"
+.RB "[ " home " | " mngtmpaddr " | " nodad " | " noprefixroute " ]"
 
 .ti -8
 .IR LIFETIME " := [ "
@@ -181,10 +181,26 @@ outgoing connections. Defaults to
 RFC 6275.
 
 .TP
+.B mngtmpaddr
+(IPv6 only) make the kernel manage temporary addresses created from this one as
+template on behalf of Privacy Extensions (RFC3041). For this to become active,
+the \fBuse_tempaddr\fP sysctl setting has to be set to a value greater than
+zero.  The given address needs to have a prefix length of 64. This flag allows
+to use privacy extensions in a manually configured network, just like if
+stateless auto-configuration was active.
+
+.TP
 .B nodad
 (IPv6 only) do not perform Duplicate Address Detection (RFC 4862) when
 adding this address.
 
+.TP
+.B noprefixroute
+Do not automatically create a route for the network prefix of the added
+address, and don't search for one to delete when removing the address. Changing
+an address to add this flag will remove the automatically added prefix route,
+changing it to remove this flag will create the prefix route automatically.
+
 .SS ip address delete - delete protocol address
 .B Arguments:
 coincide with the arguments of
-- 
2.1.2
