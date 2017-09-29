From: Stephen Rothwell <sfr@canb.auug.org.au>
Subject: linux-next: build failure after merge of the net-next tree
Date: Fri, 29 Sep 2017 11:36:35 +1000
Message-ID: <20170929113635.3337c026@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Linux-Next Mailing List <linux-next@vger.kernel.org>,
        Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
        Vivien Didelot <vivien.didelot@savoirfairelinux.com>,
        Florian Fainelli <f.fainelli@gmail.com>
To: David Miller <davem@davemloft.net>,
        Networking <netdev@vger.kernel.org>
Return-path: <linux-next-owner@vger.kernel.org>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi all,

After merging the net-next tree, today's linux-next build (arm
multi_v7_defconfig) failed like this:

net/dsa/slave.c: In function 'dsa_slave_create':
net/dsa/slave.c:1191:18: error: 'struct dsa_slave_priv' has no member named 'phy'
  phy_disconnect(p->phy);
                  ^

Caused by commit

  0115dcd1787d ("net: dsa: use slave device phydev")

Interacting with commit

  e804441cfe0b ("net: dsa: Fix network device registration order")

from the net tree.

I applied the following merge fix patch (which I am not sure about):

From: Stephen Rothwell <sfr@canb.auug.org.au>
Date: Fri, 29 Sep 2017 11:28:45 +1000
Subject: [PATCH] net: dsa: merge fix patch for removal of phy

Signed-off-by: Stephen Rothwell <sfr@canb.auug.org.au>
---
 net/dsa/slave.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/dsa/slave.c b/net/dsa/slave.c
index 8869954485db..9191c929c6c8 100644
--- a/net/dsa/slave.c
+++ b/net/dsa/slave.c
@@ -1188,7 +1188,7 @@ int dsa_slave_create(struct dsa_port *port, const char *name)
 	return 0;
 
 out_phy:
-	phy_disconnect(p->phy);
+	phy_disconnect(slave_dev->phydev);
 	if (of_phy_is_fixed_link(p->dp->dn))
 		of_phy_deregister_fixed_link(p->dp->dn);
 out_free:
-- 
2.14.1

-- 
Cheers,
Stephen Rothwell
