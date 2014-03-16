From: Jakub Kicinski <kubakici@wp.pl>
Subject: [PATCH v2 net-next] doc: update driver TX algorithm in timestamping.txt
Date: Sun, 16 Mar 2014 20:32:48 +0100
Message-ID: <1394998368-6907-1-git-send-email-kubakici@wp.pl>
Cc: Jakub Kicinski <kubakici@wp.pl>, netdev@vger.kernel.org,
	Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>,
	linux-doc@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <linux-doc-owner@vger.kernel.org>
Sender: linux-doc-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Since cd4d8fdad1f1 ("net: kernel panic in dev_hard_start_xmit:
remove faulty software TX time stamping") dev_hard_start_xmit()
will not provide software timestamps. It's a responsibility of
the drivers to call skb_tx_timestamp() at the right time.

Cc: linux-doc@vger.kernel.org
Signed-off-by: Jakub Kicinski <kubakici@wp.pl>
---
v1 -> v2: fix commit message, thanks Sergei!
---
 Documentation/networking/timestamping.txt | 6 +++---
 1 file changed, 3 insertions(+), 3 deletions(-)

diff --git a/Documentation/networking/timestamping.txt b/Documentation/networking/timestamping.txt
index 661d3c3..e0f259c 100644
--- a/Documentation/networking/timestamping.txt
+++ b/Documentation/networking/timestamping.txt
@@ -190,6 +190,9 @@ Time stamps for outgoing packets are to be generated as follows:
   and not free the skb. A driver not supporting hardware time stamping doesn't
   do that. A driver must never touch sk_buff::tstamp! It is used to store
   software generated time stamps by the network subsystem.
+- Driver should call skb_tx_timestamp() as close to passing sk_buff to hardware
+  as possible. skb_tx_timestamp() provides a software time stamp if requested
+  and hardware timestamping is not possible (SKBTX_IN_PROGRESS not set).
 - As soon as the driver has sent the packet and/or obtained a
   hardware time stamp for it, it passes the time stamp back by
   calling skb_hwtstamp_tx() with the original skb, the raw
@@ -200,6 +203,3 @@ Time stamps for outgoing packets are to be generated as follows:
   this would occur at a later time in the processing pipeline than other
   software time stamping and therefore could lead to unexpected deltas
   between time stamps.
-- If the driver did not set the SKBTX_IN_PROGRESS flag (see above), then
-  dev_hard_start_xmit() checks whether software time stamping
-  is wanted as fallback and potentially generates the time stamp.
-- 
1.8.5.3

