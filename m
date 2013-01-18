From: ebiederm@xmission.com (Eric W. Biederman)
Subject: [PATCH iproute2-3.8 5/6] iproute2: Fill in the ip-netns.8 manpage
Date: Thu, 17 Jan 2013 16:47:47 -0800
Message-ID: <87d2x348r0.fsf_-_@xmission.com>
References: <87a9u4q7k9.fsf@xmission.com>
	<1354039239.2701.8.camel@bwh-desktop.uk.solarflarecom.com>
	<87622v5ngt.fsf_-_@xmission.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>, "Serge E. Hallyn" <serge@hallyn.com>,
	Ben Hutchings <bhutchings@solarflare.com>
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out03.mta.xmission.com ([166.70.13.233]:56138 "EHLO
	out03.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753825Ab3ARAsB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 17 Jan 2013 19:48:01 -0500
In-Reply-To: <87622v5ngt.fsf_-_@xmission.com> (Eric W. Biederman's message of
	"Thu, 17 Jan 2013 16:44:34 -0800")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Document ip netns monitor.

Add a few senteces describing each command.  The manpage was looking
very scrawny.

Signed-off-by: "Eric W. Biederman" <ebiederm@xmission.com>
---
 man/man8/ip-netns.8 |   46 +++++++++++++++++++++++++++++++++++++++++++++-
 1 files changed, 45 insertions(+), 1 deletions(-)

diff --git a/man/man8/ip-netns.8 b/man/man8/ip-netns.8
index 349ee7e..ff08232 100644
--- a/man/man8/ip-netns.8
+++ b/man/man8/ip-netns.8
@@ -1,4 +1,4 @@
-.TH IP\-NETNS 8 "20 Dec 2011" "iproute2" "Linux"
+.TH IP\-NETNS 8 "16 Jan 2013" "iproute2" "Linux"
 .SH NAME
 ip-netns \- process network namespace management
 .SH SYNOPSIS
@@ -23,6 +23,9 @@ ip-netns \- process network namespace management
 .BR "ip netns exec "
 .I NETNSNAME command ...
 
+.ti -8
+.BR "ip netns monitor"
+
 .SH DESCRIPTION
 A network namespace is logically another copy of the network stack,
 with its own routes, firewall rules, and network devices.
@@ -54,11 +57,52 @@ bind mounting all of the per network namespace configure files into
 their traditional location in /etc.
 
 .SS ip netns list - show all of the named network namespaces
+
+This command displays all of the network namespaces in /var/run/netns
+
 .SS ip netns add NAME - create a new named network namespace
+
+If NAME is available in /var/run/netns/ this command creates a new
+network namespace and assigns NAME.
+
 .SS ip netns delete NAME - delete the name of a network namespace
+
+If NAME is present in /var/run/netns it is umounted and the mount
+point is removed.  If this is the last user of the network namespace the
+network namespace will be freed, otherwise the network namespace
+persists until it has no more users.  ip netns delete may fail if
+the mount point is in use in another mount namespace.
+
 .SS ip netns exec NAME cmd ... - Run cmd in the named network namespace
 
+This command allows applications that are network namespace unaware
+to be run in something other than the default network namespace with
+all of the configuration for the specified network namespace appearing
+in the customary global locations.  A network namespace and bind mounts
+are used to move files from their network namespace specific location
+to their default locations without affecting other processes.
+
+.SS ip netns monitor - Report as network namespace names are added and deleted
+
+This command watches network namespace name addition and deletion events
+and prints a line for each event it sees.
+
 .SH EXAMPLES
+.PP
+ip netns list
+.RS
+Shows the list of current named network namespaces
+.RE
+.PP
+ip netns add vpn
+.RS
+Creates a network namespace and names it vpn
+.RE
+.PP
+ip netns exec vpn ip link set lo up
+.RS
+Bring up the loopback interface in the vpn network namespace.
+.RE
 
 .SH SEE ALSO
 .br
-- 
1.7.5.4
