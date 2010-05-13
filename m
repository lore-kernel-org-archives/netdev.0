From: "Ha, Tristram" <Tristram.Ha@Micrel.Com>
Subject: RE: [PATCH 2.6.34-rc6] net: Improve ks8851 snl transmit performance
Date: Wed, 12 May 2010 22:38:35 -0700
Message-ID: <14385191E87B904DBD836449AA30269D021A66@MORGANITE.micrel.com>
References: <14385191E87B904DBD836449AA30269D021A64@MORGANITE.micrel.com> <27F9C60D11D683428E133F85D2BB4A53043DF7779A@dlee03.ent.ti.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7BIT
Cc: "David Miller" <davem@davemloft.net>, <netdev@vger.kernel.org>,
	<linux-kernel@vger.kernel.org>, "Jan, Sebastien" <s-jan@ti.com>
To: "Arce, Abraham" <x0066660@ti.com>, "Ben Dooks" <ben@simtec.co.uk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from p01c12o141.mxlogic.net ([208.65.145.64]:38025 "EHLO
	p01c12o141.mxlogic.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752309Ab0EMFrn convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 13 May 2010 01:47:43 -0400
Content-class: urn:content-classes:message
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I use a web browser to send patches through my company's e-mail system.  The message is composed by cut and paste, so it may not conform to Linux standard.

The latest nuttcp default size for UDP is 1500 bytes, rather than 8192 bytes.  In my case, the transmit performance improves from 10 Mbps to 11.  Have you tried TCP?


-----Original Message-----
From: Arce, Abraham [mailto:x0066660@ti.com]
Sent: Thu 5/6/2010 10:02 PM
To: Ha, Tristram; Ben Dooks
Cc: David Miller; netdev@vger.kernel.org; linux-kernel@vger.kernel.org; Jan, Sebastien
Subject: RE: [PATCH 2.6.34-rc6] net: Improve ks8851 snl transmit performance
 
Hi,

[snip]

> There is a driver option no_tx_opt so that the driver can revert to original
> implementation.  This allows user to verify if the transmit performance
> actually improves.

Should we limit patch description to 80 characters also?

> Signed-off-by: Tristram Ha <Tristram.Ha@micrel.com>
> ---
> This replaces the [patch 01/13] patch I submitted and was objected by David.
> 
> Other users with Micrel KSZ8851 SNL chip please verify the transmit
> performance does improve or not.

Tested-by: Abraham Arce <x0066660@ti.com>

Executing some nuttcp scenarios:

- Without Patch -

# /testsuites/ethernet/bin/nuttcp -u -i -Ri50m <serverip>
 1.2676 MB /   1.00 sec =   10.6330 Mbps     0 /  1298 ~drop/pkt  0.00 ~%loss
 1.2705 MB /   1.00 sec =   10.6579 Mbps     0 /  1301 ~drop/pkt  0.00 ~%loss
 1.2686 MB /   1.00 sec =   10.6414 Mbps     0 /  1299 ~drop/pkt  0.00 ~%loss
 1.2695 MB /   1.00 sec =   10.6496 Mbps     0 /  1300 ~drop/pkt  0.00 ~%loss
 1.2695 MB /   1.00 sec =   10.6496 Mbps     0 /  1300 ~drop/pkt  0.00 ~%loss
 1.2686 MB /   1.00 sec =   10.6414 Mbps     0 /  1299 ~drop/pkt  0.00 ~%loss
 1.2686 MB /   1.00 sec =   10.6414 Mbps     0 /  1299 ~drop/pkt  0.00 ~%loss
 1.2646 MB /   1.00 sec =   10.6086 Mbps     0 /  1295 ~drop/pkt  0.00 ~%loss
 1.2686 MB /   1.00 sec =   10.6412 Mbps     0 /  1299 ~drop/pkt  0.00 ~%loss
 1.2695 MB /   1.00 sec =   10.6498 Mbps     0 /  1300 ~drop/pkt  0.00 ~%loss

12.7314 MB /  10.02 sec =   10.6637 Mbps 4 %TX 0 %RX 0 / 13037 drop/pkt 0.00 %loss

- With Patch -

# /testsuites/ethernet/bin/nuttcp -u -i -Ri50m 10.87.231.229
    1.2891 MB /   1.00 sec =   10.8133 Mbps     0 /  1320 ~drop/pkt  0.00 ~%loss
    1.2900 MB /   1.00 sec =   10.8217 Mbps     0 /  1321 ~drop/pkt  0.00 ~%loss
    1.2900 MB /   1.00 sec =   10.8217 Mbps     0 /  1321 ~drop/pkt  0.00 ~%loss
    1.2910 MB /   1.00 sec =   10.8298 Mbps     0 /  1322 ~drop/pkt  0.00 ~%loss
    1.2910 MB /   1.00 sec =   10.8299 Mbps     0 /  1322 ~drop/pkt  0.00 ~%loss
    1.2900 MB /   1.00 sec =   10.8216 Mbps     0 /  1321 ~drop/pkt  0.00 ~%loss
    1.2900 MB /   1.00 sec =   10.8216 Mbps     0 /  1321 ~drop/pkt  0.00 ~%loss
    1.2891 MB /   1.00 sec =   10.8135 Mbps     0 /  1320 ~drop/pkt  0.00 ~%loss
    1.2900 MB /   1.00 sec =   10.8216 Mbps     0 /  1321 ~drop/pkt  0.00 ~%loss
    1.2910 MB /   1.00 sec =   10.8298 Mbps     0 /  1322 ~drop/pkt  0.00 ~%loss

   12.9492 MB /  10.02 sec =   10.8461 Mbps 4 %TX 0 %RX 0 / 13260 drop/pkt 0.00
%loss

Also simulated heavy transmission consisting of 40 processes executed in parallel:

 - 20 ping instances using packet size of 32768
 - 20 dd instances creating a 50MB file each under the nfs rootfs

If any specific test scenario/application is required please do let me know...

Best Regards
Abraham

