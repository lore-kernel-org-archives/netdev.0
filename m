From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH net-next-2.6] bonding: propogate vlan_features to bonding
 master
Date: Thu, 23 Jul 2009 13:03:59 +0200
Message-ID: <4A68439F.8060305@trash.net>
References: <24949.1240530461@death.nxdomain.ibm.com> <4A2CDB16.9030000@Voltaire.com> <4A642600.2010501@voltaire.com> <3463.1248298460@death.nxdomain.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: Or Gerlitz <ogerlitz@voltaire.com>,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Jay Vosburgh <fubar@us.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:33718 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750923AbZGWLEA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 23 Jul 2009 07:04:00 -0400
In-Reply-To: <3463.1248298460@death.nxdomain.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Jay Vosburgh wrote:
> 	Propogate the vlan_features of the slave devices to the bonding
> master device, using the same logic as for regular features.
> 
> 	Tested by Or Gerlitz <ogerlitz@voltaire.com>, who also removed
> the debug logic from the original test patch.
> 
> diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
> index 3bf0cc6..5a8b882 100644
> --- a/drivers/net/bonding/bond_main.c
> +++ b/drivers/net/bonding/bond_main.c
> @@ -1354,6 +1359,7 @@ static int bond_compute_features(struct bonding *bond)
>  done:
>  	features |= (bond_dev->features & BOND_VLAN_FEATURES);
>  	bond_dev->features = netdev_fix_features(features, NULL);
> +	bond_dev->vlan_features = netdev_fix_features(vlan_features, NULL);


You need to call netdev_features_change() to make sure the VLAN
code notices the change.
