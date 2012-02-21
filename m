From: Danny Kukawka <danny.kukawka@bisect.de>
Subject: [PATCH 4/4] br_device: unify return value of
	.ndo_set_mac_address if address is invalid
Date: Tue, 21 Feb 2012 13:07:52 +0100
Message-ID: <1329826072-14689-5-git-send-email-danny.kukawka@bisect.de>
References: <1329826072-14689-1-git-send-email-danny.kukawka@bisect.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, bridge@lists.linux-foundation.org,
	Danny Kukawka <dkukawka@suse.de>, "David S. Miller" <davem@davemloft.net>,
	linux-kernel@vger.kernel.org
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <bridge-bounces@lists.linux-foundation.org>
In-Reply-To: <1329826072-14689-1-git-send-email-danny.kukawka@bisect.de>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/bridge>,
	<mailto:bridge-request@lists.linux-foundation.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/bridge/>
List-Post: <mailto:bridge@lists.linux-foundation.org>
List-Help: <mailto:bridge-request@lists.linux-foundation.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/bridge>,
	<mailto:bridge-request@lists.linux-foundation.org?subject=subscribe>
Sender: bridge-bounces@lists.linux-foundation.org
Errors-To: bridge-bounces@lists.linux-foundation.org
List-Id: netdev.vger.kernel.org

Unify return value of .ndo_set_mac_address if the given address
isn't valid. Return -EADDRNOTAVAIL as eth_mac_addr() already does
if is_valid_ether_addr() fails.

Signed-off-by: Danny Kukawka <danny.kukawka@bisect.de>
---
 net/bridge/br_device.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/net/bridge/br_device.c b/net/bridge/br_device.c
index a157bf8..ba829de 100644
--- a/net/bridge/br_device.c
+++ b/net/bridge/br_device.c
@@ -167,7 +167,7 @@ static int br_set_mac_address(struct net_device *dev, void *p)
 	struct sockaddr *addr = p;
 
 	if (!is_valid_ether_addr(addr->sa_data))
-		return -EINVAL;
+		return -EADDRNOTAVAIL;
 
 	spin_lock_bh(&br->lock);
 	if (compare_ether_addr(dev->dev_addr, addr->sa_data)) {
-- 
1.7.8.3
