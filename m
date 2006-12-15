From: Jiri Benc <jbenc@suse.cz>
Subject: Re: [PATCH 3/6] d80211: fix classify_1d() priority selection
Date: Fri, 15 Dec 2006 14:53:26 +0100
Message-ID: <20061215145326.46af16de@griffin.suse.cz>
References: <20061214040227.GA10661@mail.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org,
	"John W. Linville" <linville@tuxdriver.com>,
	Simon Barber <simon@devicescape.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from styx.suse.cz ([82.119.242.94]:47795 "EHLO mail.suse.cz"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1752145AbWLONw5 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 15 Dec 2006 08:52:57 -0500
To: yi.zhu@intel.com
In-Reply-To: <20061214040227.GA10661@mail.intel.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 14 Dec 2006 12:02:27 +0800, Zhu Yi wrote:
> I don't see any reason why packets with DSCP=0x40 should have lower IEEE
> 802.1D priority than packets with DSCP=0x20. Spare > Background. No?

Applied to my tree, thanks.

I also applied the following patch on top of it:

--
Subject: [PATCH] d80211: simplify classify_1d

The switch in classify_1d can be simplified to a bit operation.

Signed-off-by: Jiri Benc <jbenc@suse.cz>

---
 net/d80211/wme.c |   19 ++-----------------
 1 files changed, 2 insertions(+), 17 deletions(-)

--- dscape.orig/net/d80211/wme.c
+++ dscape/net/d80211/wme.c
@@ -129,24 +129,9 @@ static inline unsigned classify_1d(struc
 	ip = (struct iphdr *) (skb->data + offset);
 
 	dscp = ip->tos & 0xfc;
-	switch (dscp) {
-	case 0x20:
-		return 1;
-	case 0x40:
-		return 2;
-	case 0x60:
-		return 3;
-	case 0x80:
-		return 4;
-	case 0xa0:
-		return 5;
-	case 0xc0:
-		return 6;
-	case 0xe0:
-		return 7;
-	default:
+	if (dscp & 0x1c)
 		return 0;
-	}
+	return dscp >> 5;
 }
 

-- 
Jiri Benc
SUSE Labs
