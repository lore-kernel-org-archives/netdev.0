From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 0/5] [XFRM,PFKEYV2]: MIGRATE support (take 3)
Date: Thu, 08 Feb 2007 13:32:24 -0800 (PST)
Message-ID: <20070208.133224.41636066.davem@davemloft.net>
References: <20070208113221.193F.SHINTA@sfc.wide.ad.jp>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Francis.Dupont@point6.net,
	nakam@linux-ipv6.org, yoshfuji@linux-ipv6.org,
	usagi-core@linux-ipv6.org
To: shinta@sfc.wide.ad.jp
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:36764
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1423424AbXBHVcZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 8 Feb 2007 16:32:25 -0500
In-Reply-To: <20070208113221.193F.SHINTA@sfc.wide.ad.jp>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Shinta Sugimoto <shinta@sfc.wide.ad.jp>
Date: Thu, 08 Feb 2007 12:09:29 +0900

> The patch set consists of following 5 patches:
> 
> [PATCH (1/5)] [XFRM]: Extension for dynamic update of endpoint address(es)
> [PATCH (2/5)] [XFRM]: User interface for handling XFRM_MSG_MIGRATE
> [PATCH (3/5)] [XFRM]: CONFIG_XFRM_MIGRATE option
> [PATCH (4/5)] [PFKEYV2]: Extension for dynamic update of endpoint address(es)
> [PATCH (5/5)] [PFKEYV2]: CONFIG_NET_KEY_MIGRATE option
> 
> And it can also be fetched by git from following repository with
> branch name "migrate-take3".

Patch applied, but I had to add the following bug fix in
order to fix xfrm_user and af_key when built as modules.

commit e610e679dd0057403c96cd31f8739792780732ee
Author: David S. Miller <davem@sunset.davemloft.net>
Date:   Thu Feb 8 13:29:15 2007 -0800

    [XFRM]: xfrm_migrate() needs exporting to modules.
    
    Needed by xfrm_user and af_key.
    
    Signed-off-by: David S. Miller <davem@davemloft.net>

diff --git a/net/xfrm/xfrm_policy.c b/net/xfrm/xfrm_policy.c
index 825c60a..fa7ce06 100644
--- a/net/xfrm/xfrm_policy.c
+++ b/net/xfrm/xfrm_policy.c
@@ -2464,5 +2464,6 @@ restore_state:
 
 	return err;
 }
+EXPORT_SYMBOL(xfrm_migrate);
 #endif
 
