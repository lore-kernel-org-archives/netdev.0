From: Mathias Krause <minipli@googlemail.com>
Subject: [PATCH 01/14] atm: fix info leak in getsockopt(SO_ATMPVC)
Date: Wed, 15 Aug 2012 23:31:44 +0200
Message-ID: <1345066317-22512-2-git-send-email-minipli@googlemail.com>
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
 net/atm/common.c |    1 +
 1 file changed, 1 insertion(+)

diff --git a/net/atm/common.c b/net/atm/common.c
index b4b44db..0c0ad93 100644
--- a/net/atm/common.c
+++ b/net/atm/common.c
@@ -812,6 +812,7 @@ int vcc_getsockopt(struct socket *sock, int level, int optname,
 
 		if (!vcc->dev || !test_bit(ATM_VF_ADDR, &vcc->flags))
 			return -ENOTCONN;
+		memset(&pvc, 0, sizeof(pvc));
 		pvc.sap_family = AF_ATMPVC;
 		pvc.sap_addr.itf = vcc->dev->number;
 		pvc.sap_addr.vpi = vcc->vpi;
-- 
1.7.10.4
