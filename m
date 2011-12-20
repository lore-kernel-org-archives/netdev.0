From: Gerlando Falauto <gerlando.falauto@keymile.com>
Subject: [PATCH] net: have ipconfig not wait if no dev is available
Date: Tue, 20 Dec 2011 09:58:04 +0100
Message-ID: <1324371484-24082-1-git-send-email-gerlando.falauto@keymile.com>
Cc: Gerlando Falauto <gerlando.falauto@keymile.com>,
	Micha Nelissen <micha@neli.hopto.org>,
	Holger Brunck <holger.brunck@keymile.com>,
	"David S. Miller" <davem@davemloft.net> (maintainer:NETWORKING
	[IPv4/...),
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru> (maintainer:NETWORKING
	[IPv4/...),
	"Pekka Savola (ipv6)" <pekkas@netcore.fi> (maintainer:NETWORKING
	[IPv4/...),
	James Morris <jmorris@namei.org> (maintainer:NETWORKING [IPv4/...),
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org> (maintainer:NETWORKING
	[IPv4/...),
	Patrick McHardy <kaber@trash.net> (maintainer:NETWORKING [IPv4/...),
	netdev@vger.kernel.org (open list:NETWORKING [IPv4/...),
	linux-kernel@vger.kernel.org (open list)
To: unlisted-recipients:; (no To-header on input)
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

previous commit 3fb72f1e6e6165c5f495e8dc11c5bbd14c73385c
makes IP-Config wait for carrier on at least one network device.

Before waiting (predefined value 120s), check that at least one device
was successfully brought up. Otherwise (e.g. buggy bootloader
which does not set the MAC address) there is no point in waiting
for carrier.

Cc: Micha Nelissen <micha@neli.hopto.org>
Cc: Holger Brunck <holger.brunck@keymile.com>
Signed-off-by: Gerlando Falauto <gerlando.falauto@keymile.com>
---
 net/ipv4/ipconfig.c |    4 ++++
 1 files changed, 4 insertions(+), 0 deletions(-)

diff --git a/net/ipv4/ipconfig.c b/net/ipv4/ipconfig.c
index ab7e554..7fbcaba 100644
--- a/net/ipv4/ipconfig.c
+++ b/net/ipv4/ipconfig.c
@@ -252,6 +252,10 @@ static int __init ic_open_devs(void)
 		}
 	}
 
+	/* no point in waiting if we could not bring up at least one device */
+	if (!ic_first_dev)
+		goto have_carrier;
+
 	/* wait for a carrier on at least one device */
 	start = jiffies;
 	while (jiffies - start < msecs_to_jiffies(CONF_CARRIER_TIMEOUT)) {
-- 
1.7.1
