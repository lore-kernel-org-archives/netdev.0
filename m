From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH 0/3] bonding: 3 fixes for 2.6.24
Date: Wed, 09 Jan 2008 17:08:32 +1100
Message-ID: <E1JCU76-00077z-00@gondolin.me.apana.org.au>
References: <20080108191706.GD8728@gospo.usersys.redhat.com>
Cc: olel@ans.pl, fubar@us.ibm.com, netdev@vger.kernel.org,
	jgarzik@pobox.com, davem@davemloft.net, andy@greyhouse.net
To: andy@greyhouse.net (Andy Gospodarek)
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:2570 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1750903AbYAIGI4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 9 Jan 2008 01:08:56 -0500
In-Reply-To: <20080108191706.GD8728@gospo.usersys.redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Andy Gospodarek <andy@greyhouse.net> wrote:
> 
> Jay's patches will not fix this issue.  I think something like this did
> it for me, but as I mentioned to Jay in the last thread, I'm not
> convinced it doesn't violate some of the locking expectations we have.
> 
> diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
> index 423298c..3c6619a 100644
> --- a/drivers/net/bonding/bond_main.c
> +++ b/drivers/net/bonding/bond_main.c
> @@ -3915,7 +3915,7 @@ static void bond_set_multicast_list(struct net_device *bond_dev)
>        struct bonding *bond = bond_dev->priv;
>        struct dev_mc_list *dmi;
> 
> -       write_lock_bh(&bond->lock);
> +       read_lock(&bond->lock);

This is wrong.  As I said before, the correct fix (until set_multicast
no longer gets called from BH context) is to change all you process
context read_lock's to read_lock_bh.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
