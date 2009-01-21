From: Patrick Ohly <patrick.ohly-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
Subject: [PATCH NET-NEXT 06/12] debug: NULL pointer check in ip_output
Date: Wed, 21 Jan 2009 11:10:06 +0100
Message-ID: <1232532612-10382-6-git-send-email-patrick.ohly@intel.com>
References: <1232532457.7829.19.camel@ecld0pohly>
 <1232532612-10382-1-git-send-email-patrick.ohly@intel.com>
 <1232532612-10382-2-git-send-email-patrick.ohly@intel.com>
 <1232532612-10382-3-git-send-email-patrick.ohly@intel.com>
 <1232532612-10382-4-git-send-email-patrick.ohly@intel.com>
 <1232532612-10382-5-git-send-email-patrick.ohly@intel.com>
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	linux-api-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Patrick Ohly <patrick.ohly-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
To: linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1232532612-10382-5-git-send-email-patrick.ohly-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
Sender: linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

---
 net/ipv4/ip_output.c |   10 ++++++++--
 1 files changed, 8 insertions(+), 2 deletions(-)

diff --git a/net/ipv4/ip_output.c b/net/ipv4/ip_output.c
index ed92f0b..03a6706 100644
--- a/net/ipv4/ip_output.c
+++ b/net/ipv4/ip_output.c
@@ -950,8 +950,14 @@ alloc_new_skb:
 			skb->ip_summed = csummode;
 			skb->csum = 0;
 			skb_reserve(skb, hh_len);
-			if (ipc->shtx.flags)
-				*skb_tx(skb) = ipc->shtx;
+			if (ipc->shtx.flags) {
+				if (skb_tx(skb)) 
+					*skb_tx(skb) = ipc->shtx;
+				else
+					printk(KERN_DEBUG
+						"ERROR: skb with flags %x and no tx ptr\n",
+						ipc->shtx.flags);
+			}
 
 			/*
 			 *	Find where to start putting bytes.
-- 
1.5.5.3

--
To unsubscribe from this list: send the line "unsubscribe linux-api" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
