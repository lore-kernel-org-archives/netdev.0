From: David Miller <davem@davemloft.net>
Subject: Re: fcoe: correct checking for bonding
Date: Sat, 12 Mar 2011 10:59:44 -0800 (PST)
Message-ID: <20110312.105944.193725929.davem@davemloft.net>
References: <20110302095550.GA2858@psychotron.brq.redhat.com>
	<1299114558.1688.5.camel@fritz>
	<20110312120109.GA2899@psychotron.redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: robert.w.love@intel.com, James.Bottomley@suse.de,
	linux-scsi@vger.kernel.org, devel@open-fcoe.org,
	netdev@vger.kernel.org, fubar@us.ibm.com, joe.eykholt@gmail.com
To: jpirko@redhat.com
Return-path: <linux-scsi-owner@vger.kernel.org>
In-Reply-To: <20110312120109.GA2899@psychotron.redhat.com>
Sender: linux-scsi-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Jiri Pirko <jpirko@redhat.com>
Date: Sat, 12 Mar 2011 13:01:10 +0100

> Thu, Mar 03, 2011 at 02:09:18AM CET, robert.w.love@intel.com wrote:
>>On Wed, 2011-03-02 at 01:55 -0800, Jiri Pirko wrote:
>>> Or perhaps this should be applied to net-next?
>>> 
>>I think this should go through scsi-misc as all the other
>>libfc/libfcoe/fcoe patches do.
>>
>>> Wed, Mar 02, 2011 at 07:05:35AM CET, jpirko@redhat.com wrote:
>>> >Check for bonding master and refuse to use that.
>>> >
>>> >Signed-off-by: Jiri Pirko <jpirko@redhat.com>
>>> >---
>>> > drivers/scsi/fcoe/fcoe.c |    4 +---
>>> > 1 files changed, 1 insertions(+), 3 deletions(-)
>>> >
>>> >diff --git a/drivers/scsi/fcoe/fcoe.c b/drivers/scsi/fcoe/fcoe.c
>>> >index 9f9600b..3becc6a 100644
>>> >--- a/drivers/scsi/fcoe/fcoe.c
>>> >+++ b/drivers/scsi/fcoe/fcoe.c
>>> >@@ -285,9 +285,7 @@ static int fcoe_interface_setup(struct fcoe_interface *fcoe,
>>> > 	}
>>> > 
>>> > 	/* Do not support for bonding device */
>>> >-	if ((netdev->priv_flags & IFF_MASTER_ALB) ||
>>> >-	    (netdev->priv_flags & IFF_SLAVE_INACTIVE) ||
>>> >-	    (netdev->priv_flags & IFF_MASTER_8023AD)) {
>>> >+	if (netdev->priv_flags & IFF_BONDING && netdev->flags & IFF_MASTER) {
>>> > 		FCOE_NETDEV_DBG(netdev, "Bonded interfaces not supported\n");
>>> > 		return -EOPNOTSUPP;
>>> > 	}
>>> >-- 
>>> >1.7.3.4
>>> >
>>
>>James, feel free to pick up this patch. I don't have anything in my fcoe
>>tree right now that it would conflict with. I'll also put it in my tree
>>and resend if you don't put it into scsi-misc directly.
> 
> What's the status of this? Maybe this should rather go thru net-next

Sure, I can take this.  I'll look at it later.
