From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: [PATCH RFC 6/6] skbuff: set zerocopy flag on frag destructor
Date: Tue, 8 May 2012 15:46:29 +0300
Message-ID: <20120508124628.GA17900@redhat.com>
References: <cover.1336397823.git.mst@redhat.com>
 <7e4fb863d3936baa87d318d97103689304a3923c.1336397823.git.mst@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"eric.dumazet@gmail.com" <eric.dumazet@gmail.com>
To: Ian Campbell <Ian.Campbell@citrix.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:41697 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754006Ab2EHMq3 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 8 May 2012 08:46:29 -0400
Content-Disposition: inline
In-Reply-To: <7e4fb863d3936baa87d318d97103689304a3923c.1336397823.git.mst@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, May 07, 2012 at 04:54:57PM +0300, Michael S. Tsirkin wrote:
> set tx flags when adding a frag destructor to
> force frags to be orphaned as appropriate.
> copy when copying frags between skbs.
> Note: rare false positives (where flag is set with no
> destructors) are harmless.
> 
> Signed-off-by: Michael S. Tsirkin <mst@redhat.com>

Ugh. I somehow managed to mangle this last patch and send out
a version that defines skb_copy_frag_destructor twice.
The following is needed on top (not resubmitting everything as it's an
RFC, and needs to be part of Ian's patchset anyway.  Sorry about the
noise.

Signed-off-by: Michael S. Tsirkin <mst@redhat.com>

---

diff --git a/include/linux/skbuff.h b/include/linux/skbuff.h
index 2876e4d..5fbefc3 100644
--- a/include/linux/skbuff.h
+++ b/include/linux/skbuff.h
@@ -258,13 +258,6 @@ enum {
 	SKBTX_WIFI_STATUS = 1 << 5,
 };
 
-static inline void skb_copy_frag_destructor(struct sk_buff *to,
-					    struct sk_buff *from)
-{
-	skb_shinfo(to)->tx_flags |= skb_shinfo(from)->tx_flags &
-		SKBTX_DEV_ZEROCOPY;
-}
-
 /*
  * The callback notifies userspace to release buffers when skb DMA is done in
  * lower device, the skb last reference should be 0 when calling this.
