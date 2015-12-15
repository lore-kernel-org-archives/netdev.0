From: Manoil Claudiu <claudiu.manoil@freescale.com>
Subject: RE: [PATCH] gianfar: Don't enable RX Filer if not supported
Date: Tue, 15 Dec 2015 10:12:36 +0000
Message-ID: <SN1PR0301MB2046E539353A8295C56340E79CEE0@SN1PR0301MB2046.namprd03.prod.outlook.com>
References: <1450142090-10411-1-git-send-email-hamish.martin@alliedtelesis.co.nz>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>
To: Hamish Martin <hamish.martin@alliedtelesis.co.nz>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bn1bon0130.outbound.protection.outlook.com ([157.56.111.130]:28448
	"EHLO na01-bn1-obe.outbound.protection.outlook.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S964834AbbLOKMj convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 15 Dec 2015 05:12:39 -0500
In-Reply-To: <1450142090-10411-1-git-send-email-hamish.martin@alliedtelesis.co.nz>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

>-----Original Message-----
>From: Hamish Martin [mailto:hamish.martin@alliedtelesis.co.nz]
>Sent: Tuesday, December 15, 2015 3:15 AM
>To: Manoil Claudiu-B08782 <claudiu.manoil@freescale.com>
>Cc: netdev@vger.kernel.org; Hamish Martin
><hamish.martin@alliedtelesis.co.nz>
>Subject: [PATCH] gianfar: Don't enable RX Filer if not supported
>
>After commit 15bf176db1fb ("gianfar: Don't enable the Filer w/o the
>Parser"), 'TSEC' model controllers (for example as seen on MPC8541E)
>always have 8 bytes stripped from the front of received frames.
>Only 'eTSEC' gianfar controllers have the RX Filer capability (amongst
>other enhancements). Previously this was treated as always enabled
>for both 'TSEC' and 'eTSEC' controllers.
>In commit 15bf176db1fb ("gianfar: Don't enable the Filer w/o the Parser")
>a subtle change was made to the setting of 'uses_rxfcb' to effectively
>always set it (since 'rx_filer_enable' was always true). This had the
>side-effect of always stripping 8 bytes from the front of received frames
>on 'TSEC' type controllers.
>
>We now only enable the RX Filer capability on controller types that
>support it, thereby avoiding the issue for 'TSEC' type controllers.
>


Reviewed-by: Claudiu Manoil <claudiu.manoil@freescale.com>

Thanks.
This should be applied on net. (I checked it applies w/o conflicts)

The usecase covered by rx_filer_enable was lost to me, yet I didn't remove
rx_filer_enable.  Turns out it's for TSEC, unfortunately I don't have a TSEC
board for testing yet.  With this patch, rx_filer_enable makes a lot more sense now.

Just out of curiosity, I had a look at the rx_filer_enable history. It looks that
its meaning got lost back in 2011 with
commit 4aa3a715551c93eda32d79bd52042ce500bd5383
(gianfar v5: implement nfc)

Where following change occurred:
-       /* enable filer if using multiple RX queues*/
-       if(priv->num_rx_queues > 1)
-               priv->rx_filer_enable = 1;
+       /* always enable rx filer*/
+       priv->rx_filer_enable = 1;

Back then, apparently the number of Rx queues was used to differentiate
between eTSEC and the older TSEC controllers (with just 1 RxQ).
