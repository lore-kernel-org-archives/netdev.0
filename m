From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next-2.6] sfc: Replace enum efx_fc_type with a
 'bitwise' type
Date: Tue, 17 May 2011 17:28:24 -0400 (EDT)
Message-ID: <20110517.172824.120028200915837203.davem@davemloft.net>
References: <1305666379.2848.45.camel@bwh-desktop>
	<20110517.171412.1017451005914294196.davem@davemloft.net>
	<1305667378.1722.65.camel@Joe-Laptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: bhutchings@solarflare.com, netdev@vger.kernel.org
To: joe@perches.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:35543 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932347Ab1EQV21 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 May 2011 17:28:27 -0400
In-Reply-To: <1305667378.1722.65.camel@Joe-Laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Joe Perches <joe@perches.com>
Date: Tue, 17 May 2011 14:22:58 -0700

> On Tue, 2011-05-17 at 17:14 -0400, David Miller wrote:
>> Accept that the compiler currently doesn't want to allow enums to be
>> used as bit-masks, don't paper around it.
> 
> A patch applied yesterday using enums as bitmasks:
> http://patchwork.ozlabs.org/patch/95802/

Thanks, fixed:

--------------------
ipv4: Don't use enums as bitmasks in ip_fragment.c

Noticed by Joe Perches.

Signed-off-by: David S. Miller <davem@davemloft.net>
---
 net/ipv4/ip_fragment.c |   10 ++++------
 1 files changed, 4 insertions(+), 6 deletions(-)

diff --git a/net/ipv4/ip_fragment.c b/net/ipv4/ip_fragment.c
index 9e1458d..0ad6035 100644
--- a/net/ipv4/ip_fragment.c
+++ b/net/ipv4/ip_fragment.c
@@ -81,12 +81,10 @@ struct ipq {
  * We want to check ECN values of all fragments, do detect invalid combinations.
  * In ipq->ecn, we store the OR value of each ip4_frag_ecn() fragment value.
  */
-enum {
-	IPFRAG_ECN_NOT_ECT	= 0x01, /* one frag had ECN_NOT_ECT */
-	IPFRAG_ECN_ECT_1	= 0x02, /* one frag had ECN_ECT_1 */
-	IPFRAG_ECN_ECT_0	= 0x04, /* one frag had ECN_ECT_0 */
-	IPFRAG_ECN_CE		= 0x08, /* one frag had ECN_CE */
-};
+#define	IPFRAG_ECN_NOT_ECT	0x01 /* one frag had ECN_NOT_ECT */
+#define	IPFRAG_ECN_ECT_1	0x02 /* one frag had ECN_ECT_1 */
+#define	IPFRAG_ECN_ECT_0	0x04 /* one frag had ECN_ECT_0 */
+#define	IPFRAG_ECN_CE		0x08 /* one frag had ECN_CE */
 
 static inline u8 ip4_frag_ecn(u8 tos)
 {
-- 
1.7.4.4

