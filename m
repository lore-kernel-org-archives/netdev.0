From: Robert Love <robert.w.love@intel.com>
Subject: Re: fcoe: correct checking for bonding
Date: Wed, 02 Mar 2011 17:09:18 -0800
Message-ID: <1299114558.1688.5.camel@fritz>
References: <20110302060535.GA2829@psychotron.redhat.com>
	 <20110302095550.GA2858@psychotron.brq.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "linux-scsi@vger.kernel.org" <linux-scsi@vger.kernel.org>,
	"davem@davemloft.net" <davem@davemloft.net>,
	"devel@open-fcoe.org" <devel@open-fcoe.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"fubar@us.ibm.com" <fubar@us.ibm.com>,
	"joe.eykholt@gmail.com" <joe.eykholt@gmail.com>
To: James.Bottomley@suse.de, Jiri Pirko <jpirko@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:34078 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752391Ab1CCBJT (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 2 Mar 2011 20:09:19 -0500
In-Reply-To: <20110302095550.GA2858@psychotron.brq.redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2011-03-02 at 01:55 -0800, Jiri Pirko wrote:
> Or perhaps this should be applied to net-next?
> 
I think this should go through scsi-misc as all the other
libfc/libfcoe/fcoe patches do.

> Wed, Mar 02, 2011 at 07:05:35AM CET, jpirko@redhat.com wrote:
> >Check for bonding master and refuse to use that.
> >
> >Signed-off-by: Jiri Pirko <jpirko@redhat.com>
> >---
> > drivers/scsi/fcoe/fcoe.c |    4 +---
> > 1 files changed, 1 insertions(+), 3 deletions(-)
> >
> >diff --git a/drivers/scsi/fcoe/fcoe.c b/drivers/scsi/fcoe/fcoe.c
> >index 9f9600b..3becc6a 100644
> >--- a/drivers/scsi/fcoe/fcoe.c
> >+++ b/drivers/scsi/fcoe/fcoe.c
> >@@ -285,9 +285,7 @@ static int fcoe_interface_setup(struct fcoe_interface *fcoe,
> > 	}
> > 
> > 	/* Do not support for bonding device */
> >-	if ((netdev->priv_flags & IFF_MASTER_ALB) ||
> >-	    (netdev->priv_flags & IFF_SLAVE_INACTIVE) ||
> >-	    (netdev->priv_flags & IFF_MASTER_8023AD)) {
> >+	if (netdev->priv_flags & IFF_BONDING && netdev->flags & IFF_MASTER) {
> > 		FCOE_NETDEV_DBG(netdev, "Bonded interfaces not supported\n");
> > 		return -EOPNOTSUPP;
> > 	}
> >-- 
> >1.7.3.4
> >

James, feel free to pick up this patch. I don't have anything in my fcoe
tree right now that it would conflict with. I'll also put it in my tree
and resend if you don't put it into scsi-misc directly.

Acked-by: Robert Love <robert.w.love@intel.com>

