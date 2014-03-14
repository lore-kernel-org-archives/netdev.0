From: Jakub Kicinski <kubakici@wp.pl>
Subject: [PATCH net-next 01/10] doc: update driver TX
	algorithm in timestamping.txt
Date: Fri, 14 Mar 2014 18:34:32 +0100
Message-ID: <1394818481-7652-2-git-send-email-kubakici@wp.pl>
References: <1394818481-7652-1-git-send-email-kubakici@wp.pl>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Jakub Kicinski <kubakici@wp.pl>, netdev@vger.kernel.org,
	linux-doc@vger.kernel.org, e1000-devel@lists.sourceforge.net
To: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Return-path: <e1000-devel-bounces@lists.sourceforge.net>
In-Reply-To: <1394818481-7652-1-git-send-email-kubakici@wp.pl>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=e1000-devel>
List-Post: <mailto:e1000-devel@lists.sourceforge.net>
List-Help: <mailto:e1000-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=subscribe>
Errors-To: e1000-devel-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

Since cd4d8fdad1f1 dev_hard_start_xmit() will not provide
software timestamps. It's a responsibility of the drivers
to call skb_tx_timestamp() at the right time.

Cc: linux-doc@vger.kernel.org
Signed-off-by: Jakub Kicinski <kubakici@wp.pl>
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


------------------------------------------------------------------------------
Learn Graph Databases - Download FREE O'Reilly Book
"Graph Databases" is the definitive new guide to graph databases and their
applications. Written by three acclaimed leaders in the field,
this first edition is now available. Download your free book today!
http://p.sf.net/sfu/13534_NeoTech
_______________________________________________
E1000-devel mailing list
E1000-devel@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/e1000-devel
To learn more about Intel&#174; Ethernet, visit http://communities.intel.com/community/wired
