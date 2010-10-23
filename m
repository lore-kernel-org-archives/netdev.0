From: Stephen Rothwell <sfr@canb.auug.org.au>
Subject: Re: linux-next: manual merge of the bkl-llseek tree with the
 wireless tree
Date: Sat, 23 Oct 2010 14:23:12 +1100
Message-ID: <20101023142312.533f6a42.sfr@canb.auug.org.au>
References: <20101018173543.c33530e9.sfr@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: linux-next@vger.kernel.org, linux-kernel@vger.kernel.org,
	Arnd Bergmann <arnd@arndb.de>, Felix Fietkau <nbd@openwrt.org>,
	Linus <torvalds@linux-foundation.org>
To: "John W. Linville" <linville@tuxdriver.com>,
	David Miller <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <linux-next-owner@vger.kernel.org>
In-Reply-To: <20101018173543.c33530e9.sfr@canb.auug.org.au>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi John, Dave,

On Mon, 18 Oct 2010 17:35:43 +1100 Stephen Rothwell <sfr@canb.auug.org.au> wrote:
>
> Today's linux-next merge of the bkl-llseek tree got a conflict in
> drivers/net/wireless/ath/ath9k/debug.c between commit
> 772d5515635fef5bc7a9d0efee785b58b0181ee5 ("ath9k: make rate control
> debugfs stats per station") from the wireless tree and commit
> 6038f373a3dc1f1c26496e60b6c40b164716f07e ("llseek: automatically
> add .llseek fop") from the bkl-llseek tree.
> 
> The former moved some of the code modified by the latter to another file.
> 
> I added this merge fix patch:

This patch (reproduced below) will now be needed if the wireless or net
tree is merged with Linus' tree.  I also think I have missed a similar
needed fix in drivers/net/wireless/ath/ath5k/debug.c ...

-- 
Cheers,
Stephen Rothwell                    sfr@canb.auug.org.au
http://www.canb.auug.org.au/~sfr/

From: Stephen Rothwell <sfr@canb.auug.org.au>
Date: Mon, 18 Oct 2010 17:33:25 +1100
Subject: [PATCH] ath9k: fix up for .llseek fop change

Signed-off-by: Stephen Rothwell <sfr@canb.auug.org.au>
---
 drivers/net/wireless/ath/ath9k/rc.c |    3 ++-
 1 files changed, 2 insertions(+), 1 deletions(-)

diff --git a/drivers/net/wireless/ath/ath9k/rc.c b/drivers/net/wireless/ath/ath9k/rc.c
index 0cee90c..e4c1ea3 100644
--- a/drivers/net/wireless/ath/ath9k/rc.c
+++ b/drivers/net/wireless/ath/ath9k/rc.c
@@ -1582,7 +1582,8 @@ static ssize_t read_file_rcstat(struct file *file, char __user *user_buf,
 static const struct file_operations fops_rcstat = {
 	.read = read_file_rcstat,
 	.open = ath9k_debugfs_open,
-	.owner = THIS_MODULE
+	.owner = THIS_MODULE,
+	.llseek = default_llseek,
 };
 
 static void ath_rate_add_sta_debugfs(void *priv, void *priv_sta,
-- 
1.7.1
