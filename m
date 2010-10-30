From: Vasiliy Kulikov <segooon@gmail.com>
Subject: [PATCH] bluetooth: bnep: fix information leak to userland
Date: Sat, 30 Oct 2010 18:26:21 +0400
Message-ID: <1288448782-5582-1-git-send-email-segooon@gmail.com>
Cc: Marcel Holtmann <marcel@holtmann.org>,
	"Gustavo F. Padovan" <padovan@profusion.mobi>,
	"David S. Miller" <davem@davemloft.net>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Thadeu Lima de Souza Cascardo <cascardo@holoscopio.com>,
	Tejun Heo <tj@kernel.org>, Jiri Kosina <jkosina@suse.cz>,
	linux-bluetooth@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: kernel-janitors@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Structure bnep_conninfo is copied to userland with the field "device"
that has the last elements unitialized.  It leads to leaking of
contents of kernel stack memory.

Signed-off-by: Vasiliy Kulikov <segooon@gmail.com>
---
 Compile tested.

 net/bluetooth/bnep/core.c |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)

diff --git a/net/bluetooth/bnep/core.c b/net/bluetooth/bnep/core.c
index f10b41f..5868597 100644
--- a/net/bluetooth/bnep/core.c
+++ b/net/bluetooth/bnep/core.c
@@ -648,6 +648,7 @@ int bnep_del_connection(struct bnep_conndel_req *req)
 
 static void __bnep_copy_ci(struct bnep_conninfo *ci, struct bnep_session *s)
 {
+	memset(ci, 0, sizeof(*ci));
 	memcpy(ci->dst, s->eh.h_source, ETH_ALEN);
 	strcpy(ci->device, s->dev->name);
 	ci->flags = s->flags;
-- 
1.7.0.4
