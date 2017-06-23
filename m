From: Dan Carpenter <dan.carpenter@oracle.com>
Subject: [PATCH net-next] net: dsa: mv88e6xxx: fix error code in
 mv88e6390_serdes_power()
Date: Fri, 23 Jun 2017 18:17:04 +0300
Message-ID: <20170623151703.stzh2ur3wizbylbi@mwanda>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Vivien Didelot <vivien.didelot@savoirfairelinux.com>,
        Florian Fainelli <f.fainelli@gmail.com>,
        netdev@vger.kernel.org, kernel-janitors@vger.kernel.org
To: Andrew Lunn <andrew@lunn.ch>
Return-path: <kernel-janitors-owner@vger.kernel.org>
Content-Disposition: inline
Sender: kernel-janitors-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

We're accidentally returning the wrong variable.  "cmode" is
uninitialized at this point so it causes a static checker warning.

Fixes: 6335e9f2446b ("net: dsa: mv88e6xxx: mv88e6390X SERDES support")
Signed-off-by: Dan Carpenter <dan.carpenter@oracle.com>

diff --git a/drivers/net/dsa/mv88e6xxx/serdes.c b/drivers/net/dsa/mv88e6xxx/serdes.c
index 411b4f522792..f3c01119b3d1 100644
--- a/drivers/net/dsa/mv88e6xxx/serdes.c
+++ b/drivers/net/dsa/mv88e6xxx/serdes.c
@@ -192,7 +192,7 @@ int mv88e6390_serdes_power(struct mv88e6xxx_chip *chip, int port, bool on)
 
 	err = mv88e6xxx_port_get_cmode(chip, port, &cmode);
 	if (err)
-		return cmode;
+		return err;
 
 	switch (port) {
 	case 2:
