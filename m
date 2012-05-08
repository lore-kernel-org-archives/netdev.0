From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: [PATCH RFC 4/6] tun: orphan frags on xmit
Date: Tue, 8 May 2012 17:36:29 +0300
Message-ID: <20120508143627.GA24335@redhat.com>
References: <cover.1336397823.git.mst@redhat.com>
 <248cee8310a8d41b58b988dfea94e75ee79c6647.1336397823.git.mst@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"eric.dumazet@gmail.com" <eric.dumazet@gmail.com>
To: Ian Campbell <Ian.Campbell@citrix.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:9480 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754857Ab2EHOg1 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 8 May 2012 10:36:27 -0400
Content-Disposition: inline
In-Reply-To: <248cee8310a8d41b58b988dfea94e75ee79c6647.1336397823.git.mst@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, May 07, 2012 at 04:54:46PM +0300, Michael S. Tsirkin wrote:
> tun xmit is actually receive of the internal tun
> socket. Orphan the frags same as we do for normal rx path.
> 
> Signed-off-by: Michael S. Tsirkin <mst@redhat.com>

If tun is built as a module, skb_copy_ubufs needs to be exported:

---->

Signed-off-by: Michael S. Tsirkin <mst@redhat.com>

---

diff --git a/net/core/skbuff.c b/net/core/skbuff.c
index 83b04d9..a809014 100644
--- a/net/core/skbuff.c
+++ b/net/core/skbuff.c
@@ -765,7 +765,7 @@ int skb_copy_ubufs(struct sk_buff *skb, gfp_t gfp_mask)
 	skb_shinfo(skb)->tx_flags &= ~SKBTX_DEV_ZEROCOPY;
 	return 0;
 }
-
+EXPORT_SYMBOL_GPL(skb_copy_ubufs);
 
 /**
  *	skb_clone	-	duplicate an sk_buff
