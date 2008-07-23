From: Ingo Oeser <netdev@axxeo.de>
Subject: Re: [PATCH 1/2] ipmr: delete redundant variable
Date: Wed, 23 Jul 2008 10:03:05 +0200
Message-ID: <200807231003.05848.netdev@axxeo.de>
References: <48868D54.6050701@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
	NETDEV <netdev@vger.kernel.org>
To: Wang Chen <wangchen@cn.fujitsu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.axxeo.de ([82.100.226.146]:42466 "EHLO mail.axxeo.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750915AbYGWIwU (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 23 Jul 2008 04:52:20 -0400
In-Reply-To: <48868D54.6050701@cn.fujitsu.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Wang Chen,

Wang Chen schrieb:
> *v can be removed as this patch showing.

You are right, but did you check the resulting asm?
 
> Signed-off-by: Wang Chen <wangchen@cn.fujitsu.com>
> ---
> diff --git a/net/ipv4/ipmr.c b/net/ipv4/ipmr.c
> index c519b8d..6e715c7 100644
> --- a/net/ipv4/ipmr.c
> +++ b/net/ipv4/ipmr.c
> @@ -1129,9 +1128,9 @@ static int ipmr_device_event(struct notifier_block *this, unsigned long event, v
>  
>  	if (event != NETDEV_UNREGISTER)
>  		return NOTIFY_DONE;
> -	v=&vif_table[0];
> -	for (ct=0;ct<maxvif;ct++,v++) {
> -		if (v->dev==dev)

This is ptr += sizeof(vif_table[0])

> +
> +	for (ct = 0; ct < maxvif; ct++) {
> +		if (vif_table[ct].dev == dev)

This is ptr + ct * sizeof(vif_table[0])

On architectures, where the second address variant is
not supported, it spills a register with the multiply/shift.

But the second variant could be easily auto vectorized, 
if we had no if.

So just check the asm on a CISC and a RISC architecture 
with a cross compile, before you transform these patterns.

Maybe GCC even transform one into the other these days :-)


Best Regards

Ingo Oeser
