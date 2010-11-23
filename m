From: Dan Rosenberg <drosenberg@vsecurity.com>
Subject: [PATCH] DECnet: don't leak uninitialized stack byte
Date: Tue, 23 Nov 2010 16:02:13 -0500
Message-ID: <1290546133.2276.10.camel@dan>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.vsecurity.com ([209.67.252.12]:59723 "EHLO
	mx1.vsecurity.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750917Ab0KWVCT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 23 Nov 2010 16:02:19 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

A single uninitialized padding byte is leaked to userspace.

Signed-off-by: Dan Rosenberg <drosenberg@vsecurity.com>
CC: stable <stable@kernel.org>
---

 net/decnet/af_decnet.c |    2 ++
 1 files changed, 2 insertions(+), 0 deletions(-)

diff --git a/net/decnet/af_decnet.c b/net/decnet/af_decnet.c
index d6b93d1..cf38f52 100644
--- a/net/decnet/af_decnet.c
+++ b/net/decnet/af_decnet.c
@@ -1556,6 +1556,8 @@ static int __dn_getsockopt(struct socket *sock, int level,int optname, char __us
 			if (r_len > sizeof(struct linkinfo_dn))
 				r_len = sizeof(struct linkinfo_dn);
 
+			memset(&link, 0, sizeof(link));
+
 			switch(sock->state) {
 				case SS_CONNECTING:
 					link.idn_linkstate = LL_CONNECTING;


