From: Zhu Yi <yi.zhu@intel.com>
Subject: Re: ipw2200: Driver lockup
Date: Thu, 20 Jul 2006 13:22:34 +0800
Message-ID: <1153372954.3485.7.camel@debian.sh.intel.com>
References: <20060719142833.GA21345@linux-mips.org>
	 <1153356597.2542.7.camel@localhost.localdomain>
	 <20060720025810.GA5901@tuxdriver.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Dan Williams <dcbw@redhat.com>, Ralf Baechle <ralf@linux-mips.org>,
	netdev@vger.kernel.org, Stefan Rompf <stefan@loplof.de>,
	James Ketrenos <jketreno@linux.intel.com>,
	Patrick McHardy <kaber@trash.net>, jamal <hadi@cyberus.ca>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:62290 "EHLO
	orsmga101-1.jf.intel.com") by vger.kernel.org with ESMTP
	id S1030247AbWGTFia (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 20 Jul 2006 01:38:30 -0400
To: "John W. Linville" <linville@tuxdriver.com>
In-Reply-To: <20060720025810.GA5901@tuxdriver.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 2006-07-19 at 22:58 -0400, John W. Linville wrote:
> For what it is worth, there was a patch for this posted back
> in January.  It stirred-up a kerfluffle, so it never got merged.
> FWIW, it touches on 802.11e QoS and multiple TX queues -- my personal
> favorite wireless subject...NOT!
> 
> The thread is available here (first post not connected to follow-up
> thread for some reason):
> 
> 	http://marc.theaimsgroup.com/?l=linux-netdev&m=113809246102858&w=2
> 	http://marc.theaimsgroup.com/?l=linux-netdev&m=113814103024576&w=2
> 
> Given that half a year has passed, does anyone have any better ideas
> now?  Should I merge the patch?  Or is the cure worse than the disease?

The patch from Stefan Rompf in the second link has already been merged.
The first one was already merged (with slightly difference). We can just
remove the ieee80211 warning now.

[PATCH] ieee80211: remove ieee80211_tx() is_queue_full warning

Signed-off-by: Zhu Yi <yi.zhu@intel.com>
---

--- a/net/ieee80211/ieee80211_tx.c
+++ b/net/ieee80211/ieee80211_tx.c
@@ -533,13 +533,6 @@ int ieee80211_xmit(struct sk_buff *skb, 
 			return 0;
 		}
 
-		if (ret == NETDEV_TX_BUSY) {
-			printk(KERN_ERR "%s: NETDEV_TX_BUSY returned; "
-			       "driver should report queue full via "
-			       "ieee_device->is_queue_full.\n",
-			       ieee->dev->name);
-		}
-
 		ieee80211_txb_free(txb);
 	}
 
