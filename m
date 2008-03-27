From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?=
	<yoshfuji@linux-ipv6.org>
Subject: Re: [PATCH 2 of 5] IPv6: only update the lifetime of the relevant
 temporary address
Date: Fri, 28 Mar 2008 03:31:44 +0900 (JST)
Message-ID: <20080328.033144.21651958.yoshfuji@linux-ipv6.org>
References: <patchbomb.1206305168@pirzuine>
	<5e50b19fbb757f080905.1206305170@pirzuine>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, pekkas@netcore.fi, yoshfuji@linux-ipv6.org
To: benoit.boissinot@ens-lyon.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from yue.linux-ipv6.org ([203.178.140.15]:55366 "EHLO
	yue.st-paulia.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756344AbYC0SaP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 27 Mar 2008 14:30:15 -0400
In-Reply-To: <5e50b19fbb757f080905.1206305170@pirzuine>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In article <5e50b19fbb757f080905.1206305170@pirzuine> (at Sun, 23 Mar 2008 21:46:10 +0100), Benoit Boissinot <benoit.boissinot@ens-lyon.org> says:

> IPv6: only update the lifetime of the relevant temporary address
> 
> When receiving a prefix information from a routeur, only update the lifetimes
> of the temporary address associated with that prefix.
> Otherwise if one deprecated prefix is advertized, all your temporary addresses
> will become deprecated.
> 
> Signed-off-by: Benoit Boissinot <benoit.boissinot@ens-lyon.org>

I generally agree.

> diff -r dd125a7f8696 -r 5e50b19fbb75 net/ipv6/addrconf.c
> --- a/net/ipv6/addrconf.c	Sat Mar 22 00:50:21 2008 +0100
> +++ b/net/ipv6/addrconf.c	Sat Mar 22 00:41:39 2008 +0100
> @@ -1832,6 +1832,10 @@
>  				 * when processing a Prefix Information Option.
>  				 */
>  				spin_lock(&ift->lock);
> +				if (ifp != ift->ifpub) {
> +					spin_unlock(&ift->lock);
> +					continue;
> +				}
>  				flags = ift->flags;
>  				if (ift->valid_lft > valid_lft &&
>  				    ift->valid_lft - valid_lft > (jiffies - ift->tstamp) / HZ)

I think you can compare ift->ifpub outside the lock here.

--yoshfuji
