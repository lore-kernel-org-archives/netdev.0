From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next 1/2] random32: add prandom_u32_lt_N and convert
 "misuses" of reciprocal_divide
Date: Wed, 15 Jan 2014 19:14:10 -0800
Message-ID: <1389842050.31367.396.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1389828228-30312-1-git-send-email-dborkman@redhat.com>
	 <1389828228-30312-2-git-send-email-dborkman@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org,
	Jakub Zawadzki <darkjames-ws@darkjames.pl>,
	Hannes Frederic Sowa <hannes@stressinduktion.org>
To: Daniel Borkmann <dborkman@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f52.google.com ([209.85.220.52]:38191 "EHLO
	mail-pa0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751325AbaAPDOM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 15 Jan 2014 22:14:12 -0500
In-Reply-To: <1389828228-30312-2-git-send-email-dborkman@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2014-01-16 at 00:23 +0100, Daniel Borkmann wrote:

> @@ -1220,7 +1219,7 @@ static unsigned int fanout_demux_hash(struct packet_fanout *f,
>  				      struct sk_buff *skb,
>  				      unsigned int num)
>  {
> -	return reciprocal_divide(skb->rxhash, num);
> +	return (u32)(((u64) skb->rxhash * num) >> 32);
>  }
>  

This is unfortunate.

(This reverts one of your patch : f55d112e529386 )

Please add a helper to explain what's going on here, and on many other
spots we do this computation (as in get_rps_cpu()).
Few people really understand this.

Or keep reciprocal_divide() as is, and introduce a new set of functions
for people really wanting the precise divides.
