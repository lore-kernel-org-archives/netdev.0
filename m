From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH net-next 01/10] net: etherdevice: add address inherit
 helper
Date: Fri, 23 Aug 2013 12:24:04 -0700
Message-ID: <20130823122404.7aebb2c8@nehalam.linuxnetplumber.net>
References: <1377250513-3662-1-git-send-email-bjorn@mork.no>
	<1377250513-3662-2-git-send-email-bjorn@mork.no>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: =?ISO-8859-1?B?Qmr4cm4=?= Mork <bjorn@mork.no>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f177.google.com ([209.85.192.177]:51804 "EHLO
	mail-pd0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754084Ab3HWTYI convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 23 Aug 2013 15:24:08 -0400
Received: by mail-pd0-f177.google.com with SMTP id y10so1039395pdj.22
        for <netdev@vger.kernel.org>; Fri, 23 Aug 2013 12:24:07 -0700 (PDT)
In-Reply-To: <1377250513-3662-2-git-send-email-bjorn@mork.no>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 23 Aug 2013 11:35:04 +0200
Bj=F8rn Mork <bjorn@mork.no> wrote:

>  /**
> + * eth_hw_addr_inherit - Copy dev_addr from another net_device
> + * @dst: pointer to net_device to copy dev_addr to
> + * @src: pointer to net_device to copy dev_addr from
> + *
> + * Copy the Ethernet address from one net_device to another along wi=
th
> + * the addr_assign_type.
> + */
> +static inline int eth_hw_addr_inherit(struct net_device *dst,
> +				      struct net_device *src)
> +{
> +	if (dst->addr_len !=3D src->addr_len)
> +		return -EINVAL;
> +
> +	dst->addr_assign_type =3D src->addr_assign_type;
> +	memcpy(dst->dev_addr, src->dev_addr, dst->addr_len);
> +	return 0;
> +}
> +

Since all the other code in this file assumes addr_len =3D=3D ETH_ALEN
why does this code need to handle variable addresses. Trivial but
then the memcpy is fixed size and can be optimized.
