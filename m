From: "David S. Miller" <davem@davemloft.net>
Subject: Re: [PATCH 2.6.10] tg3: Fix TSO for 5750
Date: Mon, 24 Jan 2005 14:41:00 -0800
Message-ID: <20050124144100.58a3fb54.davem@davemloft.net>
References: <B1508D50A0692F42B217C22C02D84972020F3D42@NT-IRVA-0741.brcm.ad.broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "Michael Chan" <mchan@broadcom.com>
In-Reply-To: <B1508D50A0692F42B217C22C02D84972020F3D42@NT-IRVA-0741.brcm.ad.broadcom.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Mon, 24 Jan 2005 13:51:36 -0800
"Michael Chan" <mchan@broadcom.com> wrote:

> - Fix TSO for 5750 chips by setting tcp checksum field to 0 for TSO packets
> - Add TG3_FLG2_HW_TSO flag for 5750 and newer chips that use the same TSO
> scheme

If we've created this new TG3_FLG2_HW_TSO flag, we should eliminate
all 5750 tests which are just checking for that.

For example, this patch leaves the following test:

-		if (GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5705) {
+		if ((tp->tg3_flags2 & TG3_FLG2_HW_TSO) ||
+		    (GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5705)) {

Here, just checking the TG3_FLG3_HW_TSO flag would suffice.
