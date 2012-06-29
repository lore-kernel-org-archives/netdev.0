From: Jiri Pirko <jpirko@redhat.com>
Subject: [patch net-next v2 1/4] net: introduce new priv_flag indicating iface
	capable of change mac when running
Date: Fri, 29 Jun 2012 17:10:05 +0200
Message-ID: <1340982608-897-2-git-send-email-jpirko@redhat.com>
References: <1340982608-897-1-git-send-email-jpirko@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: mst@redhat.com, shimoda.hiroaki@gmail.com,
	virtualization@lists.linux-foundation.org,
	danny.kukawka@bisect.de, edumazet@google.com, davem@davemloft.net
To: netdev@vger.kernel.org
Return-path: <virtualization-bounces@lists.linux-foundation.org>
In-Reply-To: <1340982608-897-1-git-send-email-jpirko@redhat.com>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/virtualization>,
	<mailto:virtualization-request@lists.linux-foundation.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/virtualization/>
List-Post: <mailto:virtualization@lists.linux-foundation.org>
List-Help: <mailto:virtualization-request@lists.linux-foundation.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/virtualization>,
	<mailto:virtualization-request@lists.linux-foundation.org?subject=subscribe>
Sender: virtualization-bounces@lists.linux-foundation.org
Errors-To: virtualization-bounces@lists.linux-foundation.org
List-Id: netdev.vger.kernel.org

Introduce IFF_LIVE_ADDR_CHANGE priv_flag and use it to disable
netif_running() check in eth_mac_addr()

Signed-off-by: Jiri Pirko <jpirko@redhat.com>
---
 include/linux/if.h |    2 ++
 net/ethernet/eth.c |    2 +-
 2 files changed, 3 insertions(+), 1 deletion(-)

diff --git a/include/linux/if.h b/include/linux/if.h
index f995c66..1ec407b 100644
--- a/include/linux/if.h
+++ b/include/linux/if.h
@@ -81,6 +81,8 @@
 #define IFF_UNICAST_FLT	0x20000		/* Supports unicast filtering	*/
 #define IFF_TEAM_PORT	0x40000		/* device used as team port */
 #define IFF_SUPP_NOFCS	0x80000		/* device supports sending custom FCS */
+#define IFF_LIVE_ADDR_CHANGE 0x100000	/* device supports hardware address
+					 * change when it's running */
 
 
 #define IF_GET_IFACE	0x0001		/* for querying only */
diff --git a/net/ethernet/eth.c b/net/ethernet/eth.c
index 36e5880..db6a6c1 100644
--- a/net/ethernet/eth.c
+++ b/net/ethernet/eth.c
@@ -283,7 +283,7 @@ int eth_mac_addr(struct net_device *dev, void *p)
 {
 	struct sockaddr *addr = p;
 
-	if (netif_running(dev))
+	if (!(dev->priv_flags & IFF_LIVE_ADDR_CHANGE) && netif_running(dev))
 		return -EBUSY;
 	if (!is_valid_ether_addr(addr->sa_data))
 		return -EADDRNOTAVAIL;
-- 
1.7.10.4
