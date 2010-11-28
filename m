From: Joe Perches <joe@perches.com>
Subject: [PATCH V2 4/4] zd1211rw: document need for kmalloc cast
Date: Sun, 28 Nov 2010 02:02:59 -0800
Message-ID: <1290938579.16349.19.camel@Joe-Laptop>
References: <cover.1290934782.git.joe@perches.com>
	 <704bdd89d630b364043ac7a9ec0a110d311a17a2.1290934782.git.joe@perches.com>
	 <1290935566.3467.0.camel@jlt3.sipsolutions.net>
	 <1290936047.16349.13.camel@Joe-Laptop>
	 <1290936606.3467.2.camel@jlt3.sipsolutions.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Daniel Drake <dsd@gentoo.org>, Ulrich Kunitz <kune@deine-taler.de>,
	linux-wireless@vger.kernel.org,
	"John W. Linville" <linville@tuxdriver.com>,
	linux-kernel@vger.kernel.org, netdev <netdev@vger.kernel.org>
To: Johannes Berg <johannes@sipsolutions.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1290936606.3467.2.camel@jlt3.sipsolutions.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Signed-off-by: Joe Perches <joe@perches.com>
---

V2: Just document the need for the cast

diff --git a/drivers/net/wireless/zd1211rw/zd_chip.c b/drivers/net/wireless/zd1211rw/zd_chip.c
index 87a95bc..dd0bb0c 100644
--- a/drivers/net/wireless/zd1211rw/zd_chip.c
+++ b/drivers/net/wireless/zd1211rw/zd_chip.c
@@ -117,6 +117,7 @@ int zd_ioread32v_locked(struct zd_chip *chip, u32 *values, const zd_addr_t *addr
 
 	/* Allocate a single memory block for values and addresses. */
 	count16 = 2*count;
+	/* zd_addr_t is __nocast, so the kmalloc needs an explicit cast */
 	a16 = (zd_addr_t *) kmalloc(count16 * (sizeof(zd_addr_t) + sizeof(u16)),
 		                   GFP_KERNEL);
 	if (!a16) {
