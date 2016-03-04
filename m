From: David Howells <dhowells@redhat.com>
Subject: [PATCH 13/13] rxrpc: Don't try to map ICMP to error as the lower
 layer already did that
Date: Fri, 04 Mar 2016 16:38:35 +0000
Message-ID: <20160304163835.31057.4926.stgit@warthog.procyon.org.uk>
References: <20160304163705.31057.60831.stgit@warthog.procyon.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: dhowells@redhat.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: linux-afs@lists.infradead.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:35235 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932216AbcCDQih (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 4 Mar 2016 11:38:37 -0500
In-Reply-To: <20160304163705.31057.60831.stgit@warthog.procyon.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In the ICMP message processing code, don't try to map ICMP codes to UNIX
error codes as the caller (IPv4/IPv6) already did that for us (ee_errno).

Signed-off-by: David Howells <dhowells@redhat.com>
---

 net/rxrpc/ar-error.c |   10 ----------
 1 file changed, 10 deletions(-)

diff --git a/net/rxrpc/ar-error.c b/net/rxrpc/ar-error.c
index 5948191bf4eb..3e82d6f0313c 100644
--- a/net/rxrpc/ar-error.c
+++ b/net/rxrpc/ar-error.c
@@ -151,28 +151,18 @@ void rxrpc_UDP_error_handler(struct work_struct *work)
 			switch (ee->ee_code) {
 			case ICMP_NET_UNREACH:
 				_net("Rx Received ICMP Network Unreachable");
-				err = ENETUNREACH;
 				break;
 			case ICMP_HOST_UNREACH:
 				_net("Rx Received ICMP Host Unreachable");
-				err = EHOSTUNREACH;
 				break;
 			case ICMP_PORT_UNREACH:
 				_net("Rx Received ICMP Port Unreachable");
-				err = ECONNREFUSED;
-				break;
-			case ICMP_FRAG_NEEDED:
-				_net("Rx Received ICMP Fragmentation Needed (%d)",
-				     ee->ee_info);
-				err = 0; /* dealt with elsewhere */
 				break;
 			case ICMP_NET_UNKNOWN:
 				_net("Rx Received ICMP Unknown Network");
-				err = ENETUNREACH;
 				break;
 			case ICMP_HOST_UNKNOWN:
 				_net("Rx Received ICMP Unknown Host");
-				err = EHOSTUNREACH;
 				break;
 			default:
 				_net("Rx Received ICMP DestUnreach code=%u",
