From: Jiri Pirko <jpirko@redhat.com>
Subject: Re: fcoe: correct checking for bonding
Date: Mon, 14 Mar 2011 20:22:02 +0100
Message-ID: <20110314192201.GA2873@psychotron.redhat.com>
References: <20110302095550.GA2858@psychotron.brq.redhat.com>
 <1299114558.1688.5.camel@fritz>
 <20110312120109.GA2899@psychotron.redhat.com>
 <20110312.105944.193725929.davem@davemloft.net>
 <1300129447.19083.258.camel@fritz>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>,
	"James.Bottomley@suse.de" <James.Bottomley@suse.de>,
	"linux-scsi@vger.kernel.org" <linux-scsi@vger.kernel.org>,
	"devel@open-fcoe.org" <devel@open-fcoe.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"fubar@us.ibm.com" <fubar@us.ibm.com>,
	"joe.eykholt@gmail.com" <joe.eykholt@gmail.com>
To: Robert Love <robert.w.love@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:3931 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755286Ab1CNTWM (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 14 Mar 2011 15:22:12 -0400
Content-Disposition: inline
In-Reply-To: <1300129447.19083.258.camel@fritz>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Mon, Mar 14, 2011 at 08:04:07PM CET, robert.w.love@intel.com wrote:
>On Sat, 2011-03-12 at 10:59 -0800, David Miller wrote:
>> From: Jiri Pirko <jpirko@redhat.com>
>> Date: Sat, 12 Mar 2011 13:01:10 +0100
>> 
>> > Thu, Mar 03, 2011 at 02:09:18AM CET, robert.w.love@intel.com wrote:
>> >>On Wed, 2011-03-02 at 01:55 -0800, Jiri Pirko wrote:
>> >>> Or perhaps this should be applied to net-next?
>> >>> 
>> >>I think this should go through scsi-misc as all the other
>> >>libfc/libfcoe/fcoe patches do.
>> >>
>> >>> Wed, Mar 02, 2011 at 07:05:35AM CET, jpirko@redhat.com wrote:
>> >>> >Check for bonding master and refuse to use that.
>> >>> >
>> >>> >Signed-off-by: Jiri Pirko <jpirko@redhat.com>
>> >>> >---
>> >>> > drivers/scsi/fcoe/fcoe.c |    4 +---
>> >>> > 1 files changed, 1 insertions(+), 3 deletions(-)
>> >>> >
>> >>> >diff --git a/drivers/scsi/fcoe/fcoe.c b/drivers/scsi/fcoe/fcoe.c
>> >>> >index 9f9600b..3becc6a 100644
>> >>> >--- a/drivers/scsi/fcoe/fcoe.c
>> >>> >+++ b/drivers/scsi/fcoe/fcoe.c
>> >>> >@@ -285,9 +285,7 @@ static int fcoe_interface_setup(struct fcoe_interface *fcoe,
>> >>> > 	}
>> >>> > 
>> >>> > 	/* Do not support for bonding device */
>> >>> >-	if ((netdev->priv_flags & IFF_MASTER_ALB) ||
>> >>> >-	    (netdev->priv_flags & IFF_SLAVE_INACTIVE) ||
>> >>> >-	    (netdev->priv_flags & IFF_MASTER_8023AD)) {
>> >>> >+	if (netdev->priv_flags & IFF_BONDING && netdev->flags & IFF_MASTER) {
>> >>> > 		FCOE_NETDEV_DBG(netdev, "Bonded interfaces not supported\n");
>> >>> > 		return -EOPNOTSUPP;
>> >>> > 	}
>> >>> >-- 
>> >>> >1.7.3.4
>> >>> >
>> >>
>> >>James, feel free to pick up this patch. I don't have anything in my fcoe
>> >>tree right now that it would conflict with. I'll also put it in my tree
>> >>and resend if you don't put it into scsi-misc directly.
>> > 
>> > What's the status of this? Maybe this should rather go thru net-next
>> 
>> Sure, I can take this.  I'll look at it later.
>
>Hi Dave,
>
>   I'd rather have this patch go through scsi-misc. Most, if not all,
>libfc, libfcoe and fcoe patches have taken this path. The way it has
>been working is that I have been collecting fcoe patches and re-posting
>them to scsi-misc after I have reviewed them and done some basic
>testing.
>
>   Taking a patch like this through net{-next} could cause a merge
>problem at Linus' level if a later patch makes it though the normal
>process and conflicts. This is what I want to avoid.
>
>   This patch, although appreciated, isn't critical. I have collected it
>into my tree and will re-post it to scsi-misc. I see no reason to treat
>this patch differently from other patches.

Well I have another set of patches dependent on this one :(
>
>   Ultimately I just want things to go smoothly, so I'll leave it up to
>James and you to figure out what to do.
>
>Thanks, //Rob
>
