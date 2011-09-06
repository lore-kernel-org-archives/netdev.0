From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCH net-next 2/4] ethtool: Explicitly state that RX NFC rule
 locations are priorities
Date: Wed, 07 Sep 2011 00:48:56 +0100
Message-ID: <1315352936.12033.1.camel@bwh-desktop>
References: <1315352693.2788.20.camel@bwh-desktop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org,
	Alexander Duyck <alexander.h.duyck@intel.com>,
	Sebastian Poehn <sebastian.poehn@belden.com>,
	Santwona Behera <santwona.behera@sun.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exchange.solarflare.com ([216.237.3.220]:45567 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755299Ab1IFXs7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 6 Sep 2011 19:48:59 -0400
In-Reply-To: <1315352693.2788.20.camel@bwh-desktop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The location of an RX flow classification rule is needed to identify
it for retrieval, replacement or deletion.  However it also defines
the priority of the rule in the case that a flow is matched by
multiple rules.  This is what I intended to imply by referring to the
use of a TCAM, commonly used to implement that behaviour.

However there are other ways this can be done, and it is better to
specify this explicitly.  Further, I want to add the option for
automatic selection of rule locations.

Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
---
I hope we're all in agreement that this is how locations are supposed to
be numbered.

Ben.

 include/linux/ethtool.h |    7 +++----
 1 files changed, 3 insertions(+), 4 deletions(-)

diff --git a/include/linux/ethtool.h b/include/linux/ethtool.h
index dffab51..58407e3 100644
--- a/include/linux/ethtool.h
+++ b/include/linux/ethtool.h
@@ -456,7 +456,9 @@ struct ethtool_flow_ext {
  *	includes the %FLOW_EXT flag.
  * @ring_cookie: RX ring/queue index to deliver to, or %RX_CLS_FLOW_DISC
  *	if packets should be discarded
- * @location: Location of rule in the table
+ * @location: Location of rule in the table.  Locations must be
+ *	numbered such that a flow matching multiple rules will be
+ *	classified according to the first (lowest numbered) rule.
  */
 struct ethtool_rx_flow_spec {
 	__u32		flow_type;
@@ -502,9 +504,6 @@ struct ethtool_rx_flow_spec {
  *
  * For %ETHTOOL_SRXCLSRLDEL, @fs.@location specifies the location of an
  * existing rule on entry.
- *
- * Implementation of indexed classification rules generally requires a
- * TCAM.
  */
 struct ethtool_rxnfc {
 	__u32				cmd;
-- 
1.7.4.4



-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
