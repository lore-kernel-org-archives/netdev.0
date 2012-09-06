From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [ethtool 2/2] ethtool: allow setting MDI-X state
Date: Thu, 6 Sep 2012 19:25:23 +0100
Message-ID: <1346955923.2714.26.camel@bwh-desktop.uk.solarflarecom.com>
References: <1345538236-1636-1-git-send-email-jeffrey.t.kirsher@intel.com>
	 <1345538236-1636-2-git-send-email-jeffrey.t.kirsher@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Jesse Brandeburg <jesse.brandeburg@intel.com>,
	<netdev@vger.kernel.org>, <gospo@redhat.com>, <sassmann@redhat.com>
To: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:55894 "EHLO
	ocex02.SolarFlarecom.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S932196Ab2IFSZ0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 6 Sep 2012 14:25:26 -0400
In-Reply-To: <1345538236-1636-2-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2012-08-21 at 01:37 -0700, Jeff Kirsher wrote:
> From: Jesse Brandeburg <jesse.brandeburg@intel.com>
> 
> A bit ago ethtool added support for reading MDI-X state, this
> patch finishes the implementation, adding the complementary write
> command.
[...]

Applied.  I also commited the following changes:

---
Subject: ethtool.8: Mark-up mdix arguments properly

Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
---
 ethtool.8.in |   11 ++++++-----
 1 files changed, 6 insertions(+), 5 deletions(-)

diff --git a/ethtool.8.in b/ethtool.8.in
index 3208d38..2799e25 100644
--- a/ethtool.8.in
+++ b/ethtool.8.in
@@ -523,11 +523,12 @@ Sets full or half duplex mode.
 Selects device port.
 .TP
 .A3 mdix auto on off
-Selects MDI-X mode for port. May be used to override the automatic detection
-feature of most adapters.  Auto means automatic detection of MDI status, on
-forces MDI-X (crossover) mode, while off means MDI (straight through) mode.
-The driver should guarantee that this command takes effect immediately, and
-if necessary may reset the link to cause the change to take effect.
+Selects MDI-X mode for port. May be used to override the automatic
+detection feature of most adapters. An argument of \fBauto\fR means
+automatic detection of MDI status, \fBon\fR forces MDI-X (crossover)
+mode, while \fBoff\fR means MDI (straight through) mode.  The driver
+should guarantee that this command takes effect immediately, and if
+necessary may reset the link to cause the change to take effect.
 .TP
 .A2 autoneg on off
 Specifies whether autonegotiation should be enabled. Autonegotiation 
---
Subject: test-cmdline: Test -s mdix keyword

Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
---
 test-cmdline.c |    4 +++-
 1 files changed, 3 insertions(+), 1 deletions(-)

diff --git a/test-cmdline.c b/test-cmdline.c
index 6a60ed4..85b4ce0 100644
--- a/test-cmdline.c
+++ b/test-cmdline.c
@@ -22,12 +22,14 @@ static struct test_case {
 	{ 1, "16_char_devname!" },
 	/* Argument parsing for -s is specialised */
 	{ 0, "-s devname" },
-	{ 0, "--change devname speed 100 duplex half" },
+	{ 0, "--change devname speed 100 duplex half mdix auto" },
 	{ 1, "-s devname speed foo" },
 	{ 1, "--change devname speed" },
 	{ 0, "-s devname duplex half" },
 	{ 1, "--change devname duplex foo" },
 	{ 1, "-s devname duplex" },
+	{ 1, "--change devname mdix foo" },
+	{ 1, "-s devname mdix" },
 	{ 0, "--change devname port tp" },
 	{ 1, "-s devname port foo" },
 	{ 1, "--change devname port" },
---

Please include at least basic test cases like this for any new feature.
I did it this time because I've already kept you waiting and didn't
think it would be fair to request changes.

Ben.

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
