From: Wang Chen <wangchen@cn.fujitsu.com>
Subject: [PATCH] RAW6: Do not allow set IPV6_CHECKSUM for ICMPv6 socket
Date: Fri, 18 Apr 2008 18:32:46 +0800
Message-ID: <480878CE.5040904@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
To: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>,
	"David S. Miller" <davem@davemloft.net>,
	NETDEV <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:58947 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1750958AbYDRKeW (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 18 Apr 2008 06:34:22 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

As RFC3542 mentions: An attempt to set IPV6_CHECKSUM for an
ICMPv6 socket will fail.
Add a check for that in do_rawv6_setsockopt().

Signed-off-by: Wang Chen <wangchen@cn.fujitsu.com>
---
 net/ipv6/raw.c |    5 +++++
 1 files changed, 5 insertions(+), 0 deletions(-)

diff --git a/net/ipv6/raw.c b/net/ipv6/raw.c
index 0a6fbc1..c4cc1f9 100644
--- a/net/ipv6/raw.c
+++ b/net/ipv6/raw.c
@@ -994,6 +994,11 @@ static int do_rawv6_setsockopt(struct sock *sk, int level, int optname,
 
 	switch (optname) {
 		case IPV6_CHECKSUM:
+			/* RFC3542: An attempt to set IPV6_CHECKSUM for an
+			 * ICMPv6 socket will fail.
+			 */
+			if (inet_sk(sk)->num == IPPROTO_ICMPV6)
+				return(-EINVAL);
 			/* You may get strange result with a positive odd offset;
 			   RFC2292bis agrees with me. */
 			if (val > 0 && (val&1))
-- 
1.5.4

