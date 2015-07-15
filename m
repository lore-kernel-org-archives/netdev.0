From: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
Subject: Re: [PATCH net] bonding: fix bond dev flags after convert to arphrd_ether
Date: Wed, 15 Jul 2015 22:55:55 +0200
Message-ID: <55A6C8DB.30904@cumulusnetworks.com>
References: <1436990983-1406-1-git-send-email-razor@blackwall.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: monis@voltaire.com, j.vosburgh@gmail.com,
	gospo@cumulusnetworks.com, vfalico@gmail.com, davem@davemloft.net
To: Nikolay Aleksandrov <razor@blackwall.org>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f169.google.com ([209.85.212.169]:35439 "EHLO
	mail-wi0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753239AbbGOUz6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 15 Jul 2015 16:55:58 -0400
Received: by wiga1 with SMTP id a1so11134054wig.0
        for <netdev@vger.kernel.org>; Wed, 15 Jul 2015 13:55:57 -0700 (PDT)
In-Reply-To: <1436990983-1406-1-git-send-email-razor@blackwall.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 07/15/2015 10:09 PM, Nikolay Aleksandrov wrote:
> From: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
> 
> If a bonding device enslaves devices != arphrd_ether it'll change types
> and if later these devices are released, it can enslave an arphrd_ether
> device and switch back calling ether_setup() which resets dev->flags to
> IFF_BROADCAST|IFF_MULTICAST and clears IFF_MASTER which then could lead
> to many different bugs. This bug seems to have been there since the
> introduction of ether_setup() in bond_enslave().
> 
> Signed-off-by: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
> Fixes: e36b9d16c6a6 ("bonding: clean muticast addresses when device changes type")
> ---
>  drivers/net/bonding/bond_main.c | 1 +
>  1 file changed, 1 insertion(+)
> 
> diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
> index 317a49480475..8ba119896e55 100644
> --- a/drivers/net/bonding/bond_main.c
> +++ b/drivers/net/bonding/bond_main.c
> @@ -1368,6 +1368,7 @@ int bond_enslave(struct net_device *bond_dev, struct net_device *slave_dev)
>  				bond_setup_by_slave(bond_dev, slave_dev);
>  			else {
>  				ether_setup(bond_dev);
> +				bond_dev->flags |= IFF_MASTER;
>  				bond_dev->priv_flags &= ~IFF_TX_SKB_SHARING;
>  			}
>  
> 

Dave please ignore this patch, I'll send a better fix.

Thanks,
 Nik
