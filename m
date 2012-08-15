From: Mathias Krause <minipli@googlemail.com>
Subject: [PATCH 02/14] atm: fix info leak via getsockname()
Date: Wed, 15 Aug 2012 23:31:45 +0200
Message-ID: <1345066317-22512-3-git-send-email-minipli@googlemail.com>
References: <1345066317-22512-1-git-send-email-minipli@googlemail.com>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Mathias Krause <minipli@googlemail.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1345066317-22512-1-git-send-email-minipli@googlemail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The ATM code fails to initialize the two padding bytes of struct
sockaddr_atmpvc inserted for alignment. Add an explicit memset(0)
before filling the structure to avoid the info leak.

Signed-off-by: Mathias Krause <minipli@googlemail.com>
---
 net/atm/pvc.c |    1 +
 1 file changed, 1 insertion(+)

diff --git a/net/atm/pvc.c b/net/atm/pvc.c
index 3a73491..ae03240 100644
--- a/net/atm/pvc.c
+++ b/net/atm/pvc.c
@@ -95,6 +95,7 @@ static int pvc_getname(struct socket *sock, struct sockaddr *sockaddr,
 		return -ENOTCONN;
 	*sockaddr_len = sizeof(struct sockaddr_atmpvc);
 	addr = (struct sockaddr_atmpvc *)sockaddr;
+	memset(addr, 0, sizeof(*addr));
 	addr->sap_family = AF_ATMPVC;
 	addr->sap_addr.itf = vcc->dev->number;
 	addr->sap_addr.vpi = vcc->vpi;
-- 
1.7.10.4
