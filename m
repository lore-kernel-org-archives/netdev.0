From: Fan Du <fan.du@windriver.com>
Subject: [PATCH net-next 1/2] include/uapi/linux/xfrm.h:
	Pack struct xfrm_userpolicy_info
Date: Tue, 7 Jan 2014 14:48:58 +0800
Message-ID: <1389077339-12814-2-git-send-email-fan.du@windriver.com>
References: <1389077339-12814-1-git-send-email-fan.du@windriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: stephen@networkplumber.org, netdev@vger.kernel.org, davem@davemloft.net,
	dev@lists.strongswan.org
To: <steffen.klassert@secunet.com>
Return-path: <dev-bounces+gnvsd-dev=m.gmane.org@lists.strongswan.org>
In-Reply-To: <1389077339-12814-1-git-send-email-fan.du@windriver.com>
List-Unsubscribe: <https://lists.strongswan.org/mailman/listinfo/dev>,
	<mailto:dev-request@lists.strongswan.org?subject=unsubscribe>
List-Archive: <http://lists.strongswan.org/pipermail/dev>
List-Post: <mailto:dev@lists.strongswan.org>
List-Help: <mailto:dev-request@lists.strongswan.org?subject=help>
List-Subscribe: <https://lists.strongswan.org/mailman/listinfo/dev>,
	<mailto:dev-request@lists.strongswan.org?subject=subscribe>
Sender: dev-bounces+gnvsd-dev=m.gmane.org@lists.strongswan.org
Errors-To: dev-bounces+gnvsd-dev=m.gmane.org@lists.strongswan.org
List-Id: netdev.vger.kernel.org

Otherwise 64bits kernel has sizeof(struct xfrm_userpolicy_info) 168 bytes,
while 32bits compiled iproute2 see the same structure as 164 bytes, which
leading deficit xfrm policy, in turn broken IPsec connectivity.

Fix this by packing the structure.

Signed-off-by: Fan Du <fan.du@windriver.com>
---
 include/uapi/linux/xfrm.h |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/include/uapi/linux/xfrm.h b/include/uapi/linux/xfrm.h
index a8cd6a4..470bfae 100644
--- a/include/uapi/linux/xfrm.h
+++ b/include/uapi/linux/xfrm.h
@@ -405,7 +405,7 @@ struct xfrm_userpolicy_info {
 	/* Automatically expand selector to include matching ICMP payloads. */
 #define XFRM_POLICY_ICMP	2
 	__u8				share;
-};
+} __attribute__((packed));
 
 struct xfrm_userpolicy_id {
 	struct xfrm_selector		sel;
-- 
1.7.9.5
