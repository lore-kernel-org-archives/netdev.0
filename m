From: Andy Gospodarek <andy@greyhouse.net>
Subject: Re: [PATCH] bonding: update docs to correctly reflect
	arp_ip_target behavior
Date: Wed, 22 Oct 2008 17:19:48 -0400
Message-ID: <20081022211938.GA11129@gospo.rdu.redhat.com>
References: <20081022200639.GA10873@gospo.rdu.redhat.com> <1473.1224707425@death.nxdomain.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Andy Gospodarek <andy@greyhouse.net>, netdev@vger.kernel.org
To: Jay Vosburgh <fubar@us.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx2.redhat.com ([66.187.237.31]:40794 "EHLO mx2.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751564AbYJVV0Q (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 22 Oct 2008 17:26:16 -0400
Content-Disposition: inline
In-Reply-To: <1473.1224707425@death.nxdomain.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Oct 22, 2008 at 01:30:25PM -0700, Jay Vosburgh wrote:
> Andy Gospodarek <andy@greyhouse.net> wrote:
> 
> >The latest version of Red Hat Enterprise Linux 5 doesn't need '+' in
> >front of each IP address listed as an arp_ip_target, and correctly
> >supports a comma separated list of IP addresses using the current
> >version of initscripts.  This patch drops all references to the need for
> >a '+' before each IP address and the description now matches the
> >behavior.
> 
> 	Don't the prior versions of RHEL 5 (initscripts, really) still
> need the "+"?  If so, I'd prefer to have this say "for initscripts
> versions X - Y (RHEL A.B, Fedora Q.Y), do it this way; for versions
> since Y (RHEL A.C, Fedora Q.Z), do it this other way."
> 
> 	I'm not keen on removing information that isn't tied directly to
> the bonding driver itself.  I just know somebody will run the latest
> mainline kernel on their RHEL 5.mumble and then the documentation will
> steer them down the wrong road.
> 
> 	-J


Good point, Jay.  I didn't include them originally since I didn't think
the in-kernel documentation needed to have enough detail to seem like a
Red Hat release note.

This documentation patch hopes to clarify that the '+' was only needed
for Fedora 7 and Red Hat Enterprise Linux 5.0 and 5.1.  After that the
IP addreses could be added as a comma separated list just like the
module option.

Signed-off-by: Andy Gospodarek <andy@greyhouse.net>
---

 bonding.txt |   16 +++++++++-------
 1 file changed, 9 insertions(+), 7 deletions(-)

diff --git a/Documentation/networking/bonding.txt b/Documentation/networking/bonding.txt
index 688dfe1..d733a42 100644
--- a/Documentation/networking/bonding.txt
+++ b/Documentation/networking/bonding.txt
@@ -922,17 +922,19 @@ USERCTL=no
 NETMASK, NETWORK and BROADCAST) to match your network configuration.
 
 	For later versions of initscripts, such as that found with Fedora
-7 and Red Hat Enterprise Linux version 5 (or later), it is possible, and,
-indeed, preferable, to specify the bonding options in the ifcfg-bond0
+7 (or later) and Red Hat Enterprise Linux version 5 (or later), it is possible,
+and, indeed, preferable, to specify the bonding options in the ifcfg-bond0
 file, e.g. a line of the format:
 
-BONDING_OPTS="mode=active-backup arp_interval=60 arp_ip_target=+192.168.1.254"
+BONDING_OPTS="mode=active-backup arp_interval=60 arp_ip_target=192.168.1.254"
 
 	will configure the bond with the specified options.  The options
 specified in BONDING_OPTS are identical to the bonding module parameters
-except for the arp_ip_target field.  Each target should be included as a
-separate option and should be preceded by a '+' to indicate it should be
-added to the list of queried targets, e.g.,
+except for the arp_ip_target field when using versions of initscripts older
+than and 8.57 (Fedora 8) and 8.45.19 (Red Hat Enterprise Linux 5.2).  When
+using older versions each target should be included as a separate option and
+should be preceded by a '+' to indicate it should be added to the list of
+queried targets, e.g.,
 
 	arp_ip_target=+192.168.1.1 arp_ip_target=+192.168.1.2
 
@@ -940,7 +942,7 @@ added to the list of queried targets, e.g.,
 options via BONDING_OPTS, it is not necessary to edit /etc/modules.conf or
 /etc/modprobe.conf.
 
-	For older versions of initscripts that do not support
+	For even older versions of initscripts that do not support
 BONDING_OPTS, it is necessary to edit /etc/modules.conf (or
 /etc/modprobe.conf, depending upon your distro) to load the bonding module
 with your desired options when the bond0 interface is brought up.  The
