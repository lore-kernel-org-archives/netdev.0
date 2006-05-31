From: Manfred Spraul <manfred@colorfullife.com>
Subject: Re: [PATCH-2.4] forcedeth update to 0.50
Date: Wed, 31 May 2006 21:50:38 +0200
Message-ID: <447DF38E.3020409@colorfullife.com>
References: <20060530220319.GA6945@w.ods.org> <447D2EA8.8020001@colorfullife.com> <20060531055438.GA9142@w.ods.org> <20060531180545.GA30797@dmt>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------010604090908050001060806"
Cc: Willy Tarreau <willy@w.ods.org>, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, Ayaz Abdulla <aabdulla@nvidia.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from dbl.q-ag.de ([213.172.117.3]:52900 "EHLO dbl.q-ag.de")
	by vger.kernel.org with ESMTP id S1751788AbWEaTuv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 31 May 2006 15:50:51 -0400
To: Marcelo Tosatti <marcelo@kvack.org>
In-Reply-To: <20060531180545.GA30797@dmt>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------010604090908050001060806
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit

Marcelo Tosatti wrote:

>Since v2.4.33 should be out RSN, my opinion is that applying the one-liner 
>to fix the bringup problem for now is more prudent..
>
>  
>
It's attached. Untested, but it should work. Just the relevant hunk from 
the 0.42 patch.

But I would disagree with waiting for 2.3.34 for a full backport:
0.30 basically doesn't work, thus the update to 0.50 would be a big step 
forward - it can't be worse that 0.30.

--
    Manfred


--------------010604090908050001060806
Content-Type: text/plain;
 name="patch-forcedeth-minimal"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="patch-forcedeth-minimal"

--- 2.6/drivers/net/forcedeth.c	2005-08-14 11:17:03.000000000 +0200
+++ build-2.6/drivers/net/forcedeth.c	2005-08-14 11:16:53.000000000 +0200
@@ -2178,6 +2180,9 @@
 		writel(NVREG_MIISTAT_MASK, base + NvRegMIIStatus);
 		dprintk(KERN_INFO "startup: got 0x%08x.\n", miistat);
 	}
+	/* set linkspeed to invalid value, thus force nv_update_linkspeed
+	 * to init hw */
+	np->linkspeed = 0;
 	ret = nv_update_linkspeed(dev);
 	nv_start_rx(dev);
 	nv_start_tx(dev);

--------------010604090908050001060806--
