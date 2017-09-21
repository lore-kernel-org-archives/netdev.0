From: Kumar Sanghvi <kumaras@chelsio.com>
Subject: Re: [PATCH net-next 3/4] cxgb4: add support to offload action vlan
Date: Thu, 21 Sep 2017 08:23:45 -0700
Message-ID: <20170921152342.GA14071@banjo.asicdesigners.com>
References: <cover.1505977744.git.rahul.lakkireddy@chelsio.com>
 <016c3bf21a7bfe45e73275d3191cf61cceffd362.1505977744.git.rahul.lakkireddy@chelsio.com>
 <20170921085508.GA2028@nanopsycho>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Rahul Lakkireddy <rahul.lakkireddy@chelsio.com>,
        netdev@vger.kernel.org, davem@davemloft.net, ganeshgr@chelsio.com,
        nirranjan@chelsio.com, indranil@chelsio.com
To: Jiri Pirko <jiri@resnulli.us>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stargate.chelsio.com ([12.32.117.8]:22025 "EHLO
        stargate.chelsio.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751787AbdIUPXy (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 21 Sep 2017 11:23:54 -0400
Content-Disposition: inline
In-Reply-To: <20170921085508.GA2028@nanopsycho>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Jiri,

On Thursday, September 09/21/17, 2017 at 10:55:08 +0200, Jiri Pirko wrote:
> Thu, Sep 21, 2017 at 09:33:36AM CEST, rahul.lakkireddy@chelsio.com wrote:
> >From: Kumar Sanghvi <kumaras@chelsio.com>
> >
> >Add support for offloading tc-flower flows having
> >vlan actions: pop, push and modify.
> >
> >Signed-off-by: Kumar Sanghvi <kumaras@chelsio.com>
> >Signed-off-by: Rahul Lakkireddy <rahul.lakkireddy@chelsio.com>
> >Signed-off-by: Ganesh Goudar <ganeshgr@chelsio.com>
> >---
> > .../net/ethernet/chelsio/cxgb4/cxgb4_tc_flower.c   | 43 ++++++++++++++++++++++
> > 1 file changed, 43 insertions(+)
> >
> >diff --git a/drivers/net/ethernet/chelsio/cxgb4/cxgb4_tc_flower.c b/drivers/net/ethernet/chelsio/cxgb4/cxgb4_tc_flower.c
> 
> [...]
> 
> 
> >+			switch (vlan_action) {
> >+			case TCA_VLAN_ACT_POP:
> >+				break;
> >+			case TCA_VLAN_ACT_PUSH:
> >+			case TCA_VLAN_ACT_MODIFY:
> >+				if (proto != ETH_P_8021Q) {
> >+					netdev_err(dev,
> >+						   "%s: Unsupp. vlan proto\n",
> 
> Don't wrap this. Also "Unsupp."vs"Unsupported". Please be consistent.

Thank you for pointing this.
I will take care of this in V2.

> 
> 
> >+						   __func__);
> >+					return -EOPNOTSUPP;
> >+				}
> >+				break;
> >+			default:
> >+				netdev_err(dev, "%s: Unsupported vlan action\n",
> >+					   __func__);
> >+				return -EOPNOTSUPP;
> >+			}
> > 		} else {
> > 			netdev_err(dev, "%s: Unsupported action\n", __func__);
> > 			return -EOPNOTSUPP;
> >-- 
> >2.14.1
> >
