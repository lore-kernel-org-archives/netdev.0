From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH v3] rfs: Receive Flow Steering
Date: Fri, 09 Apr 2010 09:31:35 +0200
Message-ID: <1270798295.2623.29.camel@edumazet-laptop>
References: <alpine.DEB.1.00.1004082331250.19688@pokey.mtv.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: Tom Herbert <therbert@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f209.google.com ([209.85.218.209]:63652 "EHLO
	mail-bw0-f209.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754142Ab0DIHbj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 9 Apr 2010 03:31:39 -0400
Received: by bwz1 with SMTP id 1so2314581bwz.21
        for <netdev@vger.kernel.org>; Fri, 09 Apr 2010 00:31:38 -0700 (PDT)
In-Reply-To: <alpine.DEB.1.00.1004082331250.19688@pokey.mtv.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le jeudi 08 avril 2010 =C3=A0 23:33 -0700, Tom Herbert a =C3=A9crit :

> @@ -1257,8 +1258,12 @@ EXPORT_SYMBOL(udp_lib_unhash);
> =20
>  static int __udp_queue_rcv_skb(struct sock *sk, struct sk_buff *skb)
>  {
> -	int rc =3D sock_queue_rcv_skb(sk, skb);
> +	int rc;
> +
> +	if (inet_sk(sk)->inet_daddr)
> +		inet_rps_save_rxhash(sk, skb->rxhash);
> =20
> +	 rc =3D sock_queue_rcv_skb(sk, skb);
>  	if (rc < 0) {
>  		int is_udplite =3D IS_UDPLITE(sk);
> =20

There is an extra space before "rc =3D sock_queue_rcv_skb(sk, skb);"


