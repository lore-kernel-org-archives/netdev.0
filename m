From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?=
	<yoshfuji@linux-ipv6.org>
Subject: Re: [PATCH 1 of 2] IPv6: only update the lifetime of the relevant
 temporary address
Date: Wed, 02 Apr 2008 08:48:36 +0900 (JST)
Message-ID: <20080402.084836.12035236.yoshfuji@linux-ipv6.org>
References: <patchbomb.1207091339@pirzuine>
	<0c33481968e0b6b8efd7.1207091340@pirzuine>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, pekkas@netcore.fi
To: benoit.boissinot@ens-lyon.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from yue.linux-ipv6.org ([203.178.140.15]:59674 "EHLO
	yue.st-paulia.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755939AbYDAXrB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 1 Apr 2008 19:47:01 -0400
In-Reply-To: <0c33481968e0b6b8efd7.1207091340@pirzuine>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In article <0c33481968e0b6b8efd7.1207091340@pirzuine> (at Wed, 02 Apr 2008 01:09:00 +0200), Benoit Boissinot <benoit.boissinot@ens-lyon.org> says:

> IPv6: only update the lifetime of the relevant temporary address
> 
> When receiving a prefix information from a routeur, only update the lifetimes
> of the temporary address associated with that prefix.
> Otherwise if one deprecated prefix is advertized, all your temporary addresses
> will become deprecated.
> 
> Signed-off-by: Benoit Boissinot <benoit.boissinot@ens-lyon.org>

Acked-by: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>

> 
> diff -r a3c03e70c69f -r 0c33481968e0 net/ipv6/addrconf.c
> --- a/net/ipv6/addrconf.c	Wed Apr 02 00:45:29 2008 +0200
> +++ b/net/ipv6/addrconf.c	Sat Mar 22 00:41:39 2008 +0100
> @@ -1831,6 +1831,9 @@
>  				 * lifetimes of an existing temporary address
>  				 * when processing a Prefix Information Option.
>  				 */
> +				if (ifp != ift->ifpub)
> +					continue;
> +
>  				spin_lock(&ift->lock);
>  				flags = ift->flags;
>  				if (ift->valid_lft > valid_lft &&
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
