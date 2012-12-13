From: Richard Cochran <richardcochran@gmail.com>
Subject: Re: [RFC] net : add tx timestamp to packet mmap.
Date: Thu, 13 Dec 2012 14:29:16 +0100
Message-ID: <20121213132916.GB10703@netboy.at.omicron.at>
References: <1355326165-12277-1-git-send-email-paul.chavent@onera.fr>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, edumazet@google.com,
	daniel.borkmann@tik.ee.ethz.ch, xemul@parallels.com,
	ebiederm@xmission.com, netdev@vger.kernel.org
To: Paul Chavent <Paul.Chavent@onera.fr>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bk0-f46.google.com ([209.85.214.46]:42823 "EHLO
	mail-bk0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753417Ab2LMN33 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 13 Dec 2012 08:29:29 -0500
Received: by mail-bk0-f46.google.com with SMTP id q16so1056251bkw.19
        for <netdev@vger.kernel.org>; Thu, 13 Dec 2012 05:29:27 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <1355326165-12277-1-git-send-email-paul.chavent@onera.fr>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Dec 12, 2012 at 04:29:25PM +0100, Paul Chavent wrote:
> This patch allow to generate tx timestamps of packets sent by the packet mmap interface.
> 
> Actually, you can't get tx timestamps with the sample code below.
> 
> I wonder if my current implementation is good. And if not, how should i get the timestamps ?

In order for time stamps to appear, somebody has to call
skb_tx_timestamp() ...

> diff --git a/net/packet/af_packet.c b/net/packet/af_packet.c
> index e639645..948748b 100644
> --- a/net/packet/af_packet.c
> +++ b/net/packet/af_packet.c
> @@ -1857,6 +1857,10 @@ static int tpacket_fill_skb(struct packet_sock *po, struct sk_buff *skb,
>  	void *data;
>  	int err;
>  
> +	err = sock_tx_timestamp(&po->sk, &skb_shinfo(skb)->tx_flags);

and this call is only setting some flags.

HTH,
Richard
