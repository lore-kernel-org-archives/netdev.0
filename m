From: Veaceslav Falico <vfalico@gmail.com>
Subject: Re: [patch net-next] bonding: allow to add vlans on top of empty bond
Date: Sat, 28 Jun 2014 09:30:15 +0200
Message-ID: <20140628073015.GA16141@mikrodark.usersys.redhat.com>
References: <1403878392-10004-1-git-send-email-jiri@resnulli.us>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Cc: netdev@vger.kernel.org, davem@davemloft.net, j.vosburgh@gmail.com,
	andy@greyhouse.net
To: Jiri Pirko <jiri@resnulli.us>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f171.google.com ([209.85.212.171]:37351 "EHLO
	mail-wi0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751079AbaF1HbD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 28 Jun 2014 03:31:03 -0400
Received: by mail-wi0-f171.google.com with SMTP id n15so3827073wiw.10
        for <netdev@vger.kernel.org>; Sat, 28 Jun 2014 00:31:01 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <1403878392-10004-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Jun 27, 2014 at 04:13:12PM +0200, Jiri Pirko wrote:
>This limitation maybe had some reason in the past, but now there is not
>one -> removing this.

Yeah, purely legacy stuff.

>
>Signed-off-by: Jiri Pirko <jiri@resnulli.us>

For the patch:

Acked-by: Veaceslav Falico <vfalico@gmail.com>

It would be also nice if you could have time to follow up with Jay's
remarks :).

>---
> drivers/net/bonding/bond_main.c | 13 -------------
> 1 file changed, 13 deletions(-)
>
>diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
>index 3a451b6..ffefb70 100644
>--- a/drivers/net/bonding/bond_main.c
>+++ b/drivers/net/bonding/bond_main.c
>@@ -1001,12 +1001,6 @@ static netdev_features_t bond_fix_features(struct net_device *dev,
> 	netdev_features_t mask;
> 	struct slave *slave;
>
>-	if (!bond_has_slaves(bond)) {
>-		/* Disable adding VLANs to empty bond. But why? --mq */
>-		features |= NETIF_F_VLAN_CHALLENGED;
>-		return features;
>-	}
>-
> 	mask = features;
> 	features &= ~NETIF_F_ONE_FOR_ALL;
> 	features |= NETIF_F_ALL_FOR_ALL;
>@@ -3956,13 +3950,6 @@ void bond_setup(struct net_device *bond_dev)
> 	bond_dev->priv_flags |= IFF_BONDING | IFF_UNICAST_FLT;
> 	bond_dev->priv_flags &= ~(IFF_XMIT_DST_RELEASE | IFF_TX_SKB_SHARING);
>
>-	/* At first, we block adding VLANs. That's the only way to
>-	 * prevent problems that occur when adding VLANs over an
>-	 * empty bond. The block will be removed once non-challenged
>-	 * slaves are enslaved.
>-	 */
>-	bond_dev->features |= NETIF_F_VLAN_CHALLENGED;
>-
> 	/* don't acquire bond device's netif_tx_lock when
> 	 * transmitting */
> 	bond_dev->features |= NETIF_F_LLTX;
>-- 
>1.9.0
>
