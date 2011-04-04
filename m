From: Ian Campbell <Ian.Campbell@eu.citrix.com>
Subject: Re: Signed bit field; int have_hotplug_status_watch:1
Date: Mon, 4 Apr 2011 09:26:24 +0100
Message-ID: <1301905584.23887.49.camel@zakaz.uk.xensource.com>
References: <20110403213241.GA25913@gallifrey>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "virtualization@lists.linux-foundation.org"
	<virtualization@lists.linux-foundation.org>,
	Jeremy Fitzhardinge <Jeremy.Fitzhardinge@citrix.com>,
	"konrad.wilk@oracle.com" <konrad.wilk@oracle.com>,
	netdev@vger.kernel.org, xen-devel <xen-devel@lists.xensource.com>
To: "Dr. David Alan Gilbert" <linux@treblig.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.eu.citrix.com ([62.200.22.115]:47642 "EHLO
	SMTP.EU.CITRIX.COM" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754025Ab1DDI00 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 4 Apr 2011 04:26:26 -0400
In-Reply-To: <20110403213241.GA25913@gallifrey>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, 2011-04-03 at 22:32 +0100, Dr. David Alan Gilbert wrote:
> Hi Ian,
>    I've been going through some sparse scans of the kernel and
> it threw up:
> 
>   CHECK   drivers/net/xen-netback/xenbus.c
> drivers/net/xen-netback/xenbus.c:29:40: error: dubious one-bit signed bitfield
> 
>         int have_hotplug_status_watch:1;
> 
> from your patch f942dc2552b8bfdee607be867b12a8971bb9cd85 
> 
> It does look like that should be an unsigned (given it's assigned
> 0 and 1)

I agree.

8<----------------------------------

>From 38fdb7199a0c3c5eb18ec27d2380e21116c97e29 Mon Sep 17 00:00:00 2001
From: Ian Campbell <ian.campbell@citrix.com>
Date: Mon, 4 Apr 2011 09:18:35 +0100
Subject: [PATCH] xen: netback: use unsigned type for one-bit bitfield.

Fixes error from sparse:
  CHECK   drivers/net/xen-netback/xenbus.c
drivers/net/xen-netback/xenbus.c:29:40: error: dubious one-bit signed bitfield

        int have_hotplug_status_watch:1;

Reported-by: Dr. David Alan Gilbert <linux@treblig.org>
Signed-off-by: Ian Campbell <ian.campbell@citrix.com>
Cc: netdev@vger.kernel.org
Cc: xen-devel@lists.xensource.com
---
 drivers/net/xen-netback/xenbus.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/xen-netback/xenbus.c b/drivers/net/xen-netback/xenbus.c
index 22b8c35..1ce729d 100644
--- a/drivers/net/xen-netback/xenbus.c
+++ b/drivers/net/xen-netback/xenbus.c
@@ -26,7 +26,7 @@ struct backend_info {
 	struct xenvif *vif;
 	enum xenbus_state frontend_state;
 	struct xenbus_watch hotplug_status_watch;
-	int have_hotplug_status_watch:1;
+	u8 have_hotplug_status_watch:1;
 };
 
 static int connect_rings(struct backend_info *);
-- 
1.7.2.5


