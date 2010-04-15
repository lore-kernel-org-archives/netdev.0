From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: NULL pointer dereference panic in stable (2.6.33.2), amd64
Date: Thu, 15 Apr 2010 22:46:15 +0200
Message-ID: <1271364375.16881.3099.camel@edumazet-laptop>
References: <1271318553.16881.2161.camel@edumazet-laptop>
	 <20100415.012607.15449571.davem@davemloft.net>
	 <1271321507.16881.2244.camel@edumazet-laptop>
	 <20100415.020619.00349859.davem@davemloft.net>
	 <1271363432.16881.3080.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: krkumar2@in.ibm.com, netdev@vger.kernel.org,
	nuclearcat@nuclearcat.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f225.google.com ([209.85.218.225]:63776 "EHLO
	mail-bw0-f225.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756539Ab0DOUqZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 15 Apr 2010 16:46:25 -0400
Received: by bwz25 with SMTP id 25so2155829bwz.28
        for <netdev@vger.kernel.org>; Thu, 15 Apr 2010 13:46:24 -0700 (PDT)
In-Reply-To: <1271363432.16881.3080.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le jeudi 15 avril 2010 =C3=A0 22:30 +0200, Eric Dumazet a =C3=A9crit :
> =20
> @@ -1938,6 +1928,8 @@ gso:
>  		if (dev->priv_flags & IFF_XMIT_DST_RELEASE)
>  			skb_dst_drop(nskb);
> =20
> +		skb_orphan(nskb);
> +
>  		rc =3D ops->ndo_start_xmit(nskb, dev);
>  		if (unlikely(rc !=3D NETDEV_TX_OK)) {
>  			if (rc & ~NETDEV_TX_MASK)

Well, might need to test if skb is not shared before orphaning it

	if (!skb_shared(skb))
		skb_orphan(nskb);



