From: Pavel Emelyanov <xemul@parallels.com>
Subject: [PATCH 4/5] ss: Get udp sockets info via sock-diag
Date: Thu, 25 Oct 2012 17:24:58 +0400
Message-ID: <50893DAA.3010909@parallels.com>
References: <50893BAF.7030500@parallels.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
To: Stephen Hemminger <shemminger@vyatta.com>,
	Linux Netdev List <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailhub.sw.ru ([195.214.232.25]:28655 "EHLO relay.sw.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S935157Ab2JYNY7 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 25 Oct 2012 09:24:59 -0400
In-Reply-To: <50893BAF.7030500@parallels.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Now everything is prepared for it, so the patch is straightforward.

Signed-off-by: Pavel Emelyanov <xemul@parallels.com>

---
 misc/ss.c |    7 +++++++
 1 files changed, 7 insertions(+), 0 deletions(-)

diff --git a/misc/ss.c b/misc/ss.c
index 1ceb026..a0ab2e9 100644
--- a/misc/ss.c
+++ b/misc/ss.c
@@ -1508,6 +1508,9 @@ static int tcpdiag_send(int fd, int protocol, struct filter *f)
 	struct rtattr rta;
 	struct iovec iov[3];
 
+	if (protocol == IPPROTO_UDP)
+		return -1;
+
 	memset(&nladdr, 0, sizeof(nladdr));
 	nladdr.nl_family = AF_NETLINK;
 
@@ -1976,6 +1979,10 @@ int udp_show(struct filter *f)
 {
 	FILE *fp = NULL;
 
+	if (!getenv("PROC_NET_UDP") && !getenv("PROC_ROOT")
+	    && inet_show_netlink(f, NULL, IPPROTO_UDP) == 0)
+		return 0;
+
 	dg_proto = UDP_PROTO;
 
 	if (f->families&(1<<AF_INET)) {
-- 
1.7.1
