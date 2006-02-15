From: Patrick McHardy <kaber@trash.net>
Subject: [NETFILTER]: Don't invoke okfn in CONFIG_NETFILTER=n variant of
	nf_hook()
Date: Wed, 15 Feb 2006 18:25:44 +0100
Message-ID: <43F36418.1050107@trash.net>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="------------070304080500010107020206"
Cc: Kernel Netdev Mailing List <netdev@vger.kernel.org>,
	Netfilter Development Mailinglist <netfilter-devel@lists.netfilter.org>,
	Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netfilter-devel-bounces@lists.netfilter.org>
To: "David S. Miller" <davem@davemloft.net>
List-Unsubscribe: <https://lists.netfilter.org/mailman/listinfo/netfilter-devel>,
	<mailto:netfilter-devel-request@lists.netfilter.org?subject=unsubscribe>
List-Archive: </pipermail/netfilter-devel>
List-Post: <mailto:netfilter-devel@lists.netfilter.org>
List-Help: <mailto:netfilter-devel-request@lists.netfilter.org?subject=help>
List-Subscribe: <https://lists.netfilter.org/mailman/listinfo/netfilter-devel>,
	<mailto:netfilter-devel-request@lists.netfilter.org?subject=subscribe>
Sender: netfilter-devel-bounces@lists.netfilter.org
Errors-To: netfilter-devel-bounces@lists.netfilter.org
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------070304080500010107020206
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit

Another fix related to the netfilter IPsec patches.


--------------070304080500010107020206
Content-Type: text/x-patch;
 name="02.diff"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="02.diff"

[NETFILTER]: Don't invoke okfn in CONFIG_NETFILTER=n variant of nf_hook()

nf_hook() is supposed to call the netfilter hook and return control of the
packet back to the caller in case it may pass, the okfn is only used for
queueing.

Signed-off-by: Patrick McHardy <kaber@trash.net>

---
commit 4611d14cc145cb244634920a7c4b0082f3c08eda
tree 84c175affb78b77e78d908ea8baef43d9dba698a
parent a31ab06c99e45232b742803677e88363cda2fb85
author Patrick McHardy <kaber@trash.net> Wed, 15 Feb 2006 17:39:55 +0100
committer Patrick McHardy <kaber@trash.net> Wed, 15 Feb 2006 17:39:55 +0100

 include/linux/netfilter.h |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/include/linux/netfilter.h b/include/linux/netfilter.h
index 5deacda..aa7bb93 100644
--- a/include/linux/netfilter.h
+++ b/include/linux/netfilter.h
@@ -318,7 +318,7 @@ static inline int nf_hook(int pf, unsign
 			  struct net_device *indev, struct net_device *outdev,
 			  int (*okfn)(struct sk_buff *))
 {
-	return okfn(*pskb);
+	return 1;
 }
 static inline void nf_ct_attach(struct sk_buff *new, struct sk_buff *skb) {}
 struct flowi;

--------------070304080500010107020206--
