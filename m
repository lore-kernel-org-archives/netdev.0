From: SF Markus Elfring <elfring@users.sourceforge.net>
Subject: [PATCH 2/5] atm: Delete an error message for a failed memory
 allocation in make_entry()
Date: Sun, 21 May 2017 22:15:10 +0200
Message-ID: <d87a6c4a-c4ed-38b3-97cf-29edc3590f9b@users.sourceforge.net>
References: <49543220-93e4-781c-877b-381277837152@users.sourceforge.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: LKML <linux-kernel@vger.kernel.org>,
        kernel-janitors@vger.kernel.org
To: netdev@vger.kernel.org,
        Augusto Mecking Caringi <augustocaringi@gmail.com>,
        "David S. Miller" <davem@davemloft.net>,
        Jarod Wilson <jarod@redhat.com>,
        Javier Martinez Canillas <javier@osg.samsung.com>,
        Kees Cook <keescook@chromium.org>
Return-path: <kernel-janitors-owner@vger.kernel.org>
In-Reply-To: <49543220-93e4-781c-877b-381277837152@users.sourceforge.net>
Content-Language: en-GB
Sender: kernel-janitors-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Markus Elfring <elfring@users.sourceforge.net>
Date: Sun, 21 May 2017 21:24:45 +0200

Omit an extra message for a memory allocation failure in this function.

This issue was detected by using the Coccinelle software.

Link: http://events.linuxfoundation.org/sites/events/files/slides/LCJ16-Refactor_Strings-WSang_0.pdf
Signed-off-by: Markus Elfring <elfring@users.sourceforge.net>
---
 net/atm/lec.c | 5 ++---
 1 file changed, 2 insertions(+), 3 deletions(-)

diff --git a/net/atm/lec.c b/net/atm/lec.c
index 6ad3ca625a44..a11dbd3a5119 100644
--- a/net/atm/lec.c
+++ b/net/atm/lec.c
@@ -1556,7 +1556,6 @@ static struct lec_arp_table *make_entry(struct lec_priv *priv,
-	if (!to_return) {
-		pr_info("LEC: Arp entry kmalloc failed\n");
+	if (!to_return)
 		return NULL;
-	}
+
 	ether_addr_copy(to_return->mac_addr, mac_addr);
 	INIT_HLIST_NODE(&to_return->next);
 	setup_timer(&to_return->timer, lec_arp_expire_arp,
-- 
2.13.0

