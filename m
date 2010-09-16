From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH NEXT 1/5] qlcnic: support vlan rx accleration
Date: Thu, 16 Sep 2010 15:26:10 +0200
Message-ID: <1284643570.3352.29.camel@edumazet-laptop>
References: <1284642872-27832-1-git-send-email-amit.salecha@qlogic.com>
	 <1284642872-27832-2-git-send-email-amit.salecha@qlogic.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	ameen.rahman@qlogic.com, anirban.chakraborty@qlogic.com
To: Amit Kumar Salecha <amit.salecha@qlogic.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f46.google.com ([209.85.214.46]:62763 "EHLO
	mail-bw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751456Ab0IPN0R (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 16 Sep 2010 09:26:17 -0400
Received: by bwz11 with SMTP id 11so1564619bwz.19
        for <netdev@vger.kernel.org>; Thu, 16 Sep 2010 06:26:15 -0700 (PDT)
In-Reply-To: <1284642872-27832-2-git-send-email-amit.salecha@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le jeudi 16 septembre 2010 =C3=A0 06:14 -0700, Amit Kumar Salecha a =C3=
=A9crit :

>  	skb->protocol =3D eth_type_trans(skb, netdev);
> =20
> -	napi_gro_receive(&sds_ring->napi, skb);
> +	if ((vid !=3D 0xffff) && adapter->vlgrp)
> +		vlan_hwaccel_receive_skb(skb, adapter->vlgrp, vid);
> +	else
> +		napi_gro_receive(&sds_ring->napi, skb);

This seems very strange to use GRO only on non tagged trafic.

I understand you want to have a separate patch (2/5) for GRO & vlans,
but this seems a bit convoluted.



