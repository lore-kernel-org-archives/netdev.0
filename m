From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [PATCH net-next 3/4] cxgb4: add support to offload action vlan
Date: Thu, 21 Sep 2017 10:55:08 +0200
Message-ID: <20170921085508.GA2028@nanopsycho>
References: <cover.1505977744.git.rahul.lakkireddy@chelsio.com>
 <016c3bf21a7bfe45e73275d3191cf61cceffd362.1505977744.git.rahul.lakkireddy@chelsio.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, davem@davemloft.net, kumaras@chelsio.com,
        ganeshgr@chelsio.com, nirranjan@chelsio.com, indranil@chelsio.com
To: Rahul Lakkireddy <rahul.lakkireddy@chelsio.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f66.google.com ([74.125.82.66]:33569 "EHLO
        mail-wm0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751528AbdIUIzK (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 21 Sep 2017 04:55:10 -0400
Received: by mail-wm0-f66.google.com with SMTP id m127so4592116wmm.0
        for <netdev@vger.kernel.org>; Thu, 21 Sep 2017 01:55:10 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <016c3bf21a7bfe45e73275d3191cf61cceffd362.1505977744.git.rahul.lakkireddy@chelsio.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Thu, Sep 21, 2017 at 09:33:36AM CEST, rahul.lakkireddy@chelsio.com wrote:
>From: Kumar Sanghvi <kumaras@chelsio.com>
>
>Add support for offloading tc-flower flows having
>vlan actions: pop, push and modify.
>
>Signed-off-by: Kumar Sanghvi <kumaras@chelsio.com>
>Signed-off-by: Rahul Lakkireddy <rahul.lakkireddy@chelsio.com>
>Signed-off-by: Ganesh Goudar <ganeshgr@chelsio.com>
>---
> .../net/ethernet/chelsio/cxgb4/cxgb4_tc_flower.c   | 43 ++++++++++++++++++++++
> 1 file changed, 43 insertions(+)
>
>diff --git a/drivers/net/ethernet/chelsio/cxgb4/cxgb4_tc_flower.c b/drivers/net/ethernet/chelsio/cxgb4/cxgb4_tc_flower.c

[...]


>+			switch (vlan_action) {
>+			case TCA_VLAN_ACT_POP:
>+				break;
>+			case TCA_VLAN_ACT_PUSH:
>+			case TCA_VLAN_ACT_MODIFY:
>+				if (proto != ETH_P_8021Q) {
>+					netdev_err(dev,
>+						   "%s: Unsupp. vlan proto\n",

Don't wrap this. Also "Unsupp."vs"Unsupported". Please be consistent.


>+						   __func__);
>+					return -EOPNOTSUPP;
>+				}
>+				break;
>+			default:
>+				netdev_err(dev, "%s: Unsupported vlan action\n",
>+					   __func__);
>+				return -EOPNOTSUPP;
>+			}
> 		} else {
> 			netdev_err(dev, "%s: Unsupported action\n", __func__);
> 			return -EOPNOTSUPP;
>-- 
>2.14.1
>
