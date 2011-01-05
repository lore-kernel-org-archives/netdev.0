From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [RFC] sched: CHOKe packet scheduler
Date: Wed, 05 Jan 2011 07:19:35 +0100
Message-ID: <1294208375.3420.46.camel@edumazet-laptop>
References: <20110104162930.6fa672e3@nehalam>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:46631 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751310Ab1AEGTk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 5 Jan 2011 01:19:40 -0500
Received: by wyb28 with SMTP id 28so15053877wyb.19
        for <netdev@vger.kernel.org>; Tue, 04 Jan 2011 22:19:39 -0800 (PST)
In-Reply-To: <20110104162930.6fa672e3@nehalam>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mardi 04 janvier 2011 =C3=A0 16:29 -0800, Stephen Hemminger a =C3=A9=
crit :
> +static struct sk_buff *skb_peek_random(struct sk_buff_head *list)
> +{
> +	struct sk_buff *skb =3D list->next;
> +	unsigned int idx =3D net_random() % list->qlen;
> +
> +	while (skb && idx-- > 0)
> +		skb =3D skb->next;
> +
> +	return skb;
> +}

You could avoid the divide op :

unsigned int idx =3D reciprocal_divide(random32(), list->qlen);



