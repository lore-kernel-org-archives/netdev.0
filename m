From: Pieter Smith <pieter@boesman.nl>
Subject: [PATCH 55/56] net/core: support compiling out splice
Date: Thu, 13 Nov 2014 22:23:32 +0100
Message-ID: <1415913813-362-56-git-send-email-pieter@boesman.nl>
References: <pieter@boesman.nl>
 <1415913813-362-1-git-send-email-pieter@boesman.nl>
Cc: Josh Triplett <josh@joshtriplett.org>,
	"David S. Miller" <davem@davemloft.net>,
	Tom Herbert <therbert@google.com>,
	Willem de Bruijn <willemb@google.com>,
	Eric Dumazet <edumazet@google.com>,
	Daniel Borkmann <dborkman@redhat.com>,
	Florian Westphal <fw@strlen.de>,
	"Michael S. Tsirkin" <mst@redhat.com>,
	Vlad Yasevich <vyasevic@redhat.com>,
	Paul Durrant <Paul.Durrant@citrix.com>,
	Thomas Graf <tgraf@suug.ch>,
	Herbert Xu <herbert@gondor.apana.org.au>,
	Jan Beulich <JBeulich@suse.com>,
	Miklos Szeredi <mszeredi@suse.cz>,
	linux-kernel@vger.kernel.org (open list),
	netdev@vger.kernel.org (open list:NETWORKING [GENERAL])
To: pieter@boesman.nl
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1415913813-362-1-git-send-email-pieter@boesman.nl>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Compile out splice support from networking core when the splice-family of
syscalls is not supported by the system (i.e. CONFIG_SYSCALL_SPLICE is
undefined).

Signed-off-by: Pieter Smith <pieter@boesman.nl>
---
 include/linux/skbuff.h | 2 ++
 net/core/skbuff.c      | 2 ++
 2 files changed, 4 insertions(+)

diff --git a/include/linux/skbuff.h b/include/linux/skbuff.h
index abde271..5a67427 100644
--- a/include/linux/skbuff.h
+++ b/include/linux/skbuff.h
@@ -2543,9 +2543,11 @@ int skb_copy_bits(const struct sk_buff *skb, int offset, void *to, int len);
 int skb_store_bits(struct sk_buff *skb, int offset, const void *from, int len);
 __wsum skb_copy_and_csum_bits(const struct sk_buff *skb, int offset, u8 *to,
 			      int len, __wsum csum);
+#ifdef CONFIG_SYSCALL_SPLICE
 int skb_splice_bits(struct sk_buff *skb, unsigned int offset,
 		    struct pipe_inode_info *pipe, unsigned int len,
 		    unsigned int flags);
+#endif /* #ifdef CONFIG_SYSCALL_SPLICE */
 void skb_copy_and_csum_dev(const struct sk_buff *skb, u8 *to);
 unsigned int skb_zerocopy_headlen(const struct sk_buff *from);
 int skb_zerocopy(struct sk_buff *to, struct sk_buff *from,
diff --git a/net/core/skbuff.c b/net/core/skbuff.c
index 163b673..5610904 100644
--- a/net/core/skbuff.c
+++ b/net/core/skbuff.c
@@ -1649,6 +1649,7 @@ fault:
 }
 EXPORT_SYMBOL(skb_copy_bits);
 
+#ifdef CONFIG_SYSCALL_SPLICE
 /*
  * Callback from splice_to_pipe(), if we need to release some pages
  * at the end of the spd in case we error'ed out in filling the pipe.
@@ -1851,6 +1852,7 @@ done:
 
 	return ret;
 }
+#endif /* #ifdef CONFIG_SYSCALL_SPLICE */
 
 /**
  *	skb_store_bits - store bits from kernel buffer to skb
-- 
1.9.1
