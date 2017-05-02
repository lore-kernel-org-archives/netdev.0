From: Dan Carpenter <dan.carpenter@oracle.com>
Subject: [PATCH] ipx: call ipxitf_put() in ioctl error path
Date: Tue, 2 May 2017 13:58:53 +0300
Message-ID: <20170502105853.yz3ny6lyso6isdvx@mwanda>
References: <143C0AFC63FC204CB0C55BB88F3A8ABB33419ED1@EX02.corp.qihoo.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8bit
Cc: netdev@vger.kernel.org,
        "security@kernel.org" <security@kernel.org>,
        "secalert@redhat.com" <secalert@redhat.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from aserp1040.oracle.com ([141.146.126.69]:18330 "EHLO
        aserp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750935AbdEBK7N (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 2 May 2017 06:59:13 -0400
Content-Disposition: inline
In-Reply-To: <143C0AFC63FC204CB0C55BB88F3A8ABB33419ED1@EX02.corp.qihoo.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

We should call ipxitf_put() if the copy_to_user() fails.

Reported-by: 李强 <liqiang6-s@360.cn>
Signed-off-by: Dan Carpenter <dan.carpenter@oracle.com>

diff --git a/net/ipx/af_ipx.c b/net/ipx/af_ipx.c
index 8a9219ff2e77..fa31ef29e3fa 100644
--- a/net/ipx/af_ipx.c
+++ b/net/ipx/af_ipx.c
@@ -1168,11 +1168,10 @@ static int ipxitf_ioctl(unsigned int cmd, void __user *arg)
 		sipx->sipx_network	= ipxif->if_netnum;
 		memcpy(sipx->sipx_node, ipxif->if_node,
 			sizeof(sipx->sipx_node));
-		rc = -EFAULT;
+		rc = 0;
 		if (copy_to_user(arg, &ifr, sizeof(ifr)))
-			break;
+			rc = -EFAULT;
 		ipxitf_put(ipxif);
-		rc = 0;
 		break;
 	}
 	case SIOCAIPXITFCRT:
