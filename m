From: Jay Vosburgh <fubar@us.ibm.com>
Subject: Re: [PATCH] fcoe: correct checking for bonding
Date: Mon, 28 Feb 2011 09:15:21 -0800
Message-ID: <8433.1298913321@death>
References: <20110228133245.GB7096@psychotron.brq.redhat.com>
Cc: linux-scsi@vger.kernel.org, devel@open-fcoe.org,
	robert.w.love@intel.com, James.Bottomley@HansenPartnership.com,
	netdev@vger.kernel.org
To: Jiri Pirko <jpirko@redhat.com>
Return-path: <linux-scsi-owner@vger.kernel.org>
In-reply-to: <20110228133245.GB7096@psychotron.brq.redhat.com>
Sender: linux-scsi-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Jiri Pirko <jpirko@redhat.com> wrote:

>Check for IFF_BONDING as this flag is set-up for all bonding devices.
>
>Signed-off-by: Jiri Pirko <jpirko@redhat.com>
>---
> drivers/scsi/fcoe/fcoe.c |    4 +---
> 1 files changed, 1 insertions(+), 3 deletions(-)
>
>diff --git a/drivers/scsi/fcoe/fcoe.c b/drivers/scsi/fcoe/fcoe.c
>index 9f9600b..67714a4 100644
>--- a/drivers/scsi/fcoe/fcoe.c
>+++ b/drivers/scsi/fcoe/fcoe.c
>@@ -285,9 +285,7 @@ static int fcoe_interface_setup(struct fcoe_interface *fcoe,
> 	}
>
> 	/* Do not support for bonding device */
>-	if ((netdev->priv_flags & IFF_MASTER_ALB) ||
>-	    (netdev->priv_flags & IFF_SLAVE_INACTIVE) ||
>-	    (netdev->priv_flags & IFF_MASTER_8023AD)) {
>+	if (netdev->priv_flags & IFF_BONDING) {
> 		FCOE_NETDEV_DBG(netdev, "Bonded interfaces not supported\n");
> 		return -EOPNOTSUPP;
> 	}

	Based on past discussions, I believe the intent of the code is
to permit FCOE over bonding only for active-backup mode, and possibly
for -xor/-rr as well.

	I'm not sure if the slave or the master is what's being tested
here, so I'm not sure what the right thing to do is.  I suspect it's the
master, as I recall discussion of one configuration involving
active-backup mode balancing FCOE traffic over both the active and
inactive slaves.  FCOE uses the "orig_dev" logic in __netif_receive_skb
to have the packets delivered even on the nominally inactive slave.

	-J

---
	-Jay Vosburgh, IBM Linux Technology Center, fubar@us.ibm.com
