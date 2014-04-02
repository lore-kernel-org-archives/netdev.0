From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH v3 1/5] bonding: Changed hashing function to just
 provide hash
Date: Wed, 02 Apr 2014 03:50:15 -0700
Message-ID: <1396435815.3989.23.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1396422007-31930-1-git-send-email-maheshb@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Jay Vosburgh <fubar@us.ibm.com>,
	Veaceslav Falico <vfalico@redhat.com>,
	Andy Gospodarek <andy@greyhouse.net>,
	David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	Eric Dumazet <edumazet@google.com>,
	Maciej Zenczykowski <maze@google.com>
To: Mahesh Bandewar <maheshb@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f44.google.com ([209.85.160.44]:65012 "EHLO
	mail-pb0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758283AbaDBKuS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 2 Apr 2014 06:50:18 -0400
Received: by mail-pb0-f44.google.com with SMTP id rp16so4686pbb.17
        for <netdev@vger.kernel.org>; Wed, 02 Apr 2014 03:50:17 -0700 (PDT)
In-Reply-To: <1396422007-31930-1-git-send-email-maheshb@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2014-04-02 at 00:00 -0700, Mahesh Bandewar wrote:
> Modified the hash function to return just hash separating from the
> modulo operation that can be performed by the caller. This is to
> make way for the tlb mode to use the same hashing policies that
> are used in the 802.3ad and Xor mode.
> 
> Change-Id: I276609e87e0ca213c4d1b17b79c5e0b0f3d0dd6f
> Signed-off-by: Mahesh Bandewar <maheshb@google.com>
> ---
> v2:
>   Change the return type of bond_xmit_hash() from int to u32
> v3:
>   Rebase.
> 
>  drivers/net/bonding/bond_3ad.c  |  3 ++-
>  drivers/net/bonding/bond_main.c | 10 ++++------
>  drivers/net/bonding/bonding.h   |  2 +-
>  3 files changed, 7 insertions(+), 8 deletions(-)
> 
> diff --git a/drivers/net/bonding/bond_3ad.c b/drivers/net/bonding/bond_3ad.c
> index b667a51ed215..ccf2639e916f 100644
> --- a/drivers/net/bonding/bond_3ad.c
> +++ b/drivers/net/bonding/bond_3ad.c
> @@ -30,6 +30,7 @@
>  #include <linux/etherdevice.h>
>  #include <linux/if_bonding.h>
>  #include <linux/pkt_sched.h>
> +#include <net/sock.h>

Not sure why you added this include ?

>  #include <net/net_namespace.h>
>  #include "bonding.h"
>  #include "bond_3ad.h"
> @@ -2440,7 +2441,7 @@ int bond_3ad_xmit_xor(struct sk_buff *skb, struct net_device *dev)
>  		goto err_free;
>  	}
>  
> -	slave_agg_no = bond_xmit_hash(bond, skb, slaves_in_agg);
> +	slave_agg_no = bond_xmit_hash(bond, skb) % slaves_in_agg;
>  	first_ok_slave = NULL;
>  
>  	bond_for_each_slave_rcu(bond, slave, iter) {
> diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c

Otherwise, seems fine to me

Acked-by: Eric Dumazet <edumazet@google.com>
