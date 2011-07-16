From: "Dmitry Kravkov" <dmitry@broadcom.com>
Subject: Re: linux-next: Tree for July 16 (net/bnx2x)
Date: Sat, 16 Jul 2011 23:24:02 +0300
Message-ID: <1310847842.2826.1.camel@lb-tlvb-dmitry>
References: <20110717000815.c83755be9598d34ac8431908@canb.auug.org.au>
 <20110716121427.11760128.rdunlap@xenotime.net>
Reply-To: dmitry@broadcom.com
Mime-Version: 1.0
Content-Type: text/plain;
 charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: "Stephen Rothwell" <sfr@canb.auug.org.au>,
	netdev <netdev@vger.kernel.org>,
	"linux-next@vger.kernel.org" <linux-next@vger.kernel.org>,
	LKML <linux-kernel@vger.kernel.org>,
	"Eilon Greenstein" <eilong@broadcom.com>
To: "Randy Dunlap" <rdunlap@xenotime.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms2.broadcom.com ([216.31.210.18]:4472 "EHLO mms2.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751948Ab1GPUYT (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 16 Jul 2011 16:24:19 -0400
In-Reply-To: <20110716121427.11760128.rdunlap@xenotime.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, 2011-07-16 at 12:14 -0700, Randy Dunlap wrote:
> On Sun, 17 Jul 2011 00:08:15 +1000 Stephen Rothwell wrote:
> 
> > Hi all,
> > 
> > Changes since 20110707:
> 
> When BCM_CNIC is not defined:
> 
> drivers/net/bnx2x/bnx2x_cmn.c:1429: error: 'bp' undeclared (first use in this function)
> 
> Full kernel config file is attached.
> 
> ---
> ~Randy
> *** Remember to use Documentation/SubmitChecklist when testing your code ***
bnx2x: Fix compilation when CNIC is not selected in config

Reported-by:  Randy Dunlap <rdunlap@xenotime.net>
Signed-off-by: Dmitry Kravkov <dmitry@broadcom.com>
---
 drivers/net/bnx2x/bnx2x_cmn.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/bnx2x/bnx2x_cmn.c
b/drivers/net/bnx2x/bnx2x_cmn.c
index e5fac62..b05ce93 100644
--- a/drivers/net/bnx2x/bnx2x_cmn.c
+++ b/drivers/net/bnx2x/bnx2x_cmn.c
@@ -1403,8 +1403,8 @@ void bnx2x_netif_stop(struct bnx2x *bp, int
disable_hw)
 
 u16 bnx2x_select_queue(struct net_device *dev, struct sk_buff *skb)
 {
-#ifdef BCM_CNIC
 	struct bnx2x *bp = netdev_priv(dev);
+#ifdef BCM_CNIC
 	if (NO_FCOE(bp))
 		return skb_tx_hash(dev, skb);
 	else {
-- 
1.7.2.2




