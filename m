From: Tom Herbert <therbert@google.com>
Subject: Re: BUG: using smp_processor_id() in preemptible [00000000] code:
	avahi-daemon: caller is netif_rx
Date: Mon, 12 Apr 2010 13:54:28 -0700
Message-ID: <m2m65634d661004121354ta0189542l80473b82911e43f4@mail.gmail.com>
References: <1271100042.9831.20.camel@localhost>
	 <1271101251.16881.135.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Eric Paris <eparis@redhat.com>, netdev@vger.kernel.org,
	David Miller <davem@davemloft.net>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out.google.com ([74.125.121.35]:15402 "EHLO
	smtp-out.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753633Ab0DLUyc convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 12 Apr 2010 16:54:32 -0400
Received: from wpaz9.hot.corp.google.com (wpaz9.hot.corp.google.com [172.24.198.73])
	by smtp-out.google.com with ESMTP id o3CKsUdC006165
	for <netdev@vger.kernel.org>; Mon, 12 Apr 2010 22:54:30 +0200
Received: from pzk31 (pzk31.prod.google.com [10.243.19.159])
	by wpaz9.hot.corp.google.com with ESMTP id o3CKsSYQ004560
	for <netdev@vger.kernel.org>; Mon, 12 Apr 2010 13:54:29 -0700
Received: by pzk31 with SMTP id 31so2101918pzk.33
        for <netdev@vger.kernel.org>; Mon, 12 Apr 2010 13:54:28 -0700 (PDT)
In-Reply-To: <1271101251.16881.135.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> I would change ip_dev_loopback_xmit() to call netif_rx_ni() instead..=
=2E
>
> David, Tom ?
>

Would it be better to disable preemption in netif_rx?  Also note that
with RFS we would be taking rcu_read_lock in netif_rx anyway and that
could cover all the instances of smp_processor_id().

> diff --git a/net/ipv4/ip_output.c b/net/ipv4/ip_output.c
> index c65f18e..d1bcc9f 100644
> --- a/net/ipv4/ip_output.c
> +++ b/net/ipv4/ip_output.c
> @@ -120,7 +120,7 @@ static int ip_dev_loopback_xmit(struct sk_buff *n=
ewskb)
> =A0 =A0 =A0 =A0newskb->pkt_type =3D PACKET_LOOPBACK;
> =A0 =A0 =A0 =A0newskb->ip_summed =3D CHECKSUM_UNNECESSARY;
> =A0 =A0 =A0 =A0WARN_ON(!skb_dst(newskb));
> - =A0 =A0 =A0 netif_rx(newskb);
> + =A0 =A0 =A0 netif_rx_ni(newskb);
> =A0 =A0 =A0 =A0return 0;
> =A0}
>
>
>
>
>
