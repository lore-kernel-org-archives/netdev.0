From: "Rafael J. Wysocki" <rjw@sisk.pl>
Subject: Re: [Bugme-new] [Bug 12886] New: skge wake on lan
Date: Tue, 17 Mar 2009 22:23:13 +0100
Message-ID: <200903172223.14608.rjw@sisk.pl>
References: <bug-12886-10286@http.bugzilla.kernel.org/> <200903171101.32812.rjw@sisk.pl> <9e1133f653c918ec3c19c8fe28452a9f.squirrel@ncircle.nullnet.fi>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: "Andrew Morton" <akpm@linux-foundation.org>,
	bugme-daemon@bugzilla.kernel.org, netdev@vger.kernel.org,
	"Stephen Hemminger" <shemminger@linux-foundation.org>
To: "Tomi Orava" <tomimo@ncircle.nullnet.fi>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ogre.sisk.pl ([217.79.144.158]:56653 "EHLO ogre.sisk.pl"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757158AbZCQVXZ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 17 Mar 2009 17:23:25 -0400
In-Reply-To: <9e1133f653c918ec3c19c8fe28452a9f.squirrel@ncircle.nullnet.fi>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tuesday 17 March 2009, Tomi Orava wrote:
> 
> Hi,
> 
> > Please tell me what exactly you do to set up WoL.
> 
> The only thing I do is I configure the WOL bios option
> to on ie. no OS based configuration settings are touched.

Hmm.

> The previously mentioned patch reverted the ethtool output is
> (ie. this is a working 2.6.28.7 system atm):

I wonder what it shows if that commit is not reverted (in fact it is necessary
on some other systems for things to work correctly).

Also, please check if the appended patch helps (of course, without reverting
the commit).

---
 drivers/net/skge.c |    5 +++--
 1 file changed, 3 insertions(+), 2 deletions(-)

Index: linux-2.6/drivers/net/skge.c
===================================================================
--- linux-2.6.orig/drivers/net/skge.c
+++ linux-2.6/drivers/net/skge.c
@@ -3856,8 +3856,9 @@ static struct net_device *skge_devinit(s
 	skge->speed = -1;
 	skge->advertising = skge_supported_modes(hw);
 
-	if (device_may_wakeup(&hw->pdev->dev))
-		skge->wol = wol_supported(hw) & WAKE_MAGIC;
+	skge->wol = wol_supported(hw) & WAKE_MAGIC;
+	if (skge->wol && device_can_wakeup(&hw->pdev->dev))
+		device_set_wakeup_enable(&hw->pdev->dev, true);
 
 	hw->dev[port] = dev;
 
