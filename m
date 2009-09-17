From: Xiaotian Feng <dfeng@redhat.com>
Subject: [PATCH 2/2] ipv4: make do_ip_setsockopt for IP_MULTICAST_IF support ip_mreq struct
Date: Thu, 17 Sep 2009 13:20:11 +0800
Message-ID: <1253164811-15820-1-git-send-email-dfeng@redhat.com>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Xiaotian Feng <dfeng@redhat.com>,
	Marc Milgram <mmilgram@redhat.com>
To: davem@davemloft.net, kaber@trash.net, yoshfuji@linux-ipv6.org,
	jmorris@namei.org, pekkas@netcore.fi, kuznet@ms2.inr.ac.ru
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1753666AbZIQFVX@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

ip_mreq and ip_mreqn is almost the same, and do_ip_setsockopt for IP_MULTICAST_IF
part supported ip_mreqn struct. This patch adds support for ip_mreq struct.

Signed-off-by: Marc Milgram <mmilgram@redhat.com>
Signed-off-by: Xiaotian Feng <dfeng@redhat.com>
Cc: Patrick McHardy <kaber@trash.net>
Cc: David S. Miller <davem@davemloft.net>
---
 net/ipv4/ip_sockglue.c |    7 ++++++-
 1 files changed, 6 insertions(+), 1 deletions(-)

diff --git a/net/ipv4/ip_sockglue.c b/net/ipv4/ip_sockglue.c
index 5a29dce..1e8d026 100644
--- a/net/ipv4/ip_sockglue.c
+++ b/net/ipv4/ip_sockglue.c
@@ -612,11 +612,16 @@ static int do_ip_setsockopt(struct sock *sk, int level,
 		 */
 
 		err = -EFAULT;
+		memset(&mreq, 0, sizeof(mreq));
+
 		if (optlen >= sizeof(struct ip_mreqn)) {
 			if (copy_from_user(&mreq, optval, sizeof(mreq)))
 				break;
+		} else if (optlen >= sizeof(struct ip_mreq)) {
+			if (copy_from_user(&mreq, optval,
+					   sizeof(struct ip_mreq)))
+				break;
 		} else if (optlen >= sizeof(struct in_addr)) {
-			memset(&mreq, 0, sizeof(mreq));
 			if (copy_from_user(&mreq.imr_address, optval,
 					   sizeof(struct in_addr)))
 				break;
-- 
1.6.2.5
