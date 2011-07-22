From: Stephen Rothwell <sfr@canb.auug.org.au>
Subject: linux-next: manual merge of the trivial tree with the net tree
Date: Fri, 22 Jul 2011 14:18:42 +1000
Message-ID: <20110722141842.963b38d45ebf8cb5d0a25fcf@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: linux-next@vger.kernel.org, linux-kernel@vger.kernel.org,
	Phil Carmody <ext-phil.2.carmody@nokia.com>,
	Francois Romieu <romieu@fr.zoreil.com>,
	David Miller <davem@davemloft.net>, <netdev@vger.kernel.org>
To: Jiri Kosina <jkosina@suse.cz>
Return-path: <linux-next-owner@vger.kernel.org>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Jiri,

Today's linux-next merge of the trivial tree got a conflict in
drivers/net/r8169.c between commit b6ffd97f5bcf ("r8169: move the
firmware down into the device private data") (and others) from the net
tree and commit 497888cf69bf ("treewide: fix potentially dangerous
trailing ';' in
#defined values/expressions") from the trivial tree.

Just context changes.  I fixed it up (see below) and can carry the fix as
necessary.
-- 
Cheers,
Stephen Rothwell                    sfr@canb.auug.org.au

diff --cc drivers/net/r8169.c
index 40bcb82,6f36306..0000000
--- a/drivers/net/r8169.c
+++ b/drivers/net/r8169.c
@@@ -682,19 -666,8 +682,19 @@@ struct rtl8169_private 
  	struct rtl8169_counters counters;
  	u32 saved_wolopts;
  
 -	const struct firmware *fw;
 +	struct rtl_fw {
 +		const struct firmware *fw;
 +
 +#define RTL_VER_SIZE		32
 +
 +		char version[RTL_VER_SIZE];
 +
 +		struct rtl_fw_phy_action {
 +			__le32 *code;
 +			size_t size;
 +		} phy_action;
 +	} *rtl_fw;
- #define RTL_FIRMWARE_UNKNOWN	ERR_PTR(-EAGAIN);
+ #define RTL_FIRMWARE_UNKNOWN	ERR_PTR(-EAGAIN)
  };
  
  MODULE_AUTHOR("Realtek and the Linux r8169 crew <netdev@vger.kernel.org>");
