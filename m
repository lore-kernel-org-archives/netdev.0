From: "Arce, Abraham" <x0066660@ti.com>
Subject: RE: [PATCH 2.6.34-rc6] net: Improve ks8851 snl transmit performance
Date: Fri, 7 May 2010 00:02:58 -0500
Message-ID: <27F9C60D11D683428E133F85D2BB4A53043DF7779A@dlee03.ent.ti.com>
References: <14385191E87B904DBD836449AA30269D021A64@MORGANITE.micrel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: David Miller <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"Jan, Sebastien" <s-jan@ti.com>
To: "Ha, Tristram" <Tristram.Ha@micrel.com>,
	Ben Dooks <ben@simtec.co.uk>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <14385191E87B904DBD836449AA30269D021A64@MORGANITE.micrel.com>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

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
