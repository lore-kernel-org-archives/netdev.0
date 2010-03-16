From: Darren Jenkins <darrenrjenkins@gmail.com>
Subject: [PATCH] drivers/net/wimax/i2400m/fw.c fix possible double free
Date: Tue, 16 Mar 2010 22:46:28 +1100
Message-ID: <1268739988.17270.8.camel@ICE-BOX>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Cindy H Kao <cindy.h.kao@intel.com>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	wimax@linuxwimax.org, netdev@vger.kernel.org
To: Inaky Perez-Gonzalez <inaky.perez-gonzalez@intel.com>,
	linux-wimax@intel.com, Kernel Janitors <kernel-janitors@vger.kernel.org>
Return-path: <wimax-bounces@linuxwimax.org>
List-Unsubscribe: <http://lists.linuxwimax.org/options/wimax>,
	<mailto:wimax-request@linuxwimax.org?subject=unsubscribe>
List-Archive: <http://lists.linuxwimax.org/pipermail/wimax>
List-Post: <mailto:wimax@linuxwimax.org>
List-Help: <mailto:wimax-request@linuxwimax.org?subject=help>
List-Subscribe: <http://lists.linuxwimax.org/listinfo/wimax>,
	<mailto:wimax-request@linuxwimax.org?subject=subscribe>
Sender: wimax-bounces@linuxwimax.org
Errors-To: wimax-bounces@linuxwimax.org
List-Id: netdev.vger.kernel.org

i2400m_fw_check() can free i2400m->fw_hdrs if krealloc() fails causing a double free
Add a check so we don't free the memory a second time.

coverity CID: 13455

Signed-off-by: Darren Jenkins <darrenrjenkins@gmail.com>
---
 drivers/net/wimax/i2400m/fw.c |    3 ++-
 1 files changed, 2 insertions(+), 1 deletions(-)

diff --git a/drivers/net/wimax/i2400m/fw.c b/drivers/net/wimax/i2400m/fw.c
index 25c24f0..a97c413 100644
--- a/drivers/net/wimax/i2400m/fw.c
+++ b/drivers/net/wimax/i2400m/fw.c
@@ -1490,7 +1490,8 @@ int i2400m_fw_bootstrap(struct i2400m *i2400m, const struct firmware *fw,
 	if (ret < 0)
 		dev_err(dev, "%s: cannot use: %d, skipping\n",
 			i2400m->fw_name, ret);
-	kfree(i2400m->fw_hdrs);
+	if (ret != -ENOMEM)
+		kfree(i2400m->fw_hdrs);
 	i2400m->fw_hdrs = NULL;
 	d_fnend(5, dev, "(i2400m %p) = %d\n", i2400m, ret);
 	return ret;
-- 
1.6.3.3
