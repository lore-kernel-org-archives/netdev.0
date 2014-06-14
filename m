From: Alex <d77190@mail.ru>
Subject: Re: Bug 75571
Date: Sun, 15 Jun 2014 02:29:32 +0700
Message-ID: <1402774172.29664.27.camel@anpws>
References: <1401085231.1775.9.camel@anpws>
	 <CAHA+R7Oog=fAGjcfVTus2HdCt_Vv-1XDFePR3mLb0FM1N3q0ow@mail.gmail.com>
	 <1401870692.29664.1.camel@anpws>
	 <CAHA+R7N74QODqvWyvP1gHsK2dm_Zgrkq0+k8LZnqnA8EqnMOZw@mail.gmail.com>
	 <1401945732.29664.6.camel@anpws>
	 <CAHA+R7Mi-mBXWSytEtJhqEfjYQyrd9zae5GndYy3qmK=+_mk_g@mail.gmail.com>
	 <1402027981.29664.16.camel@anpws>
	 <CAHA+R7Nnm0ueWPKYYT0M1Nn8DOcKcRiDG6-Py+OcNgvvnqO2Ng@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Cong Wang <cwang@twopensource.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mxnat1.880.ru ([194.8.85.225]:34187 "EHLO stk-gw0.880.ru"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751142AbaFNT3I (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 14 Jun 2014 15:29:08 -0400
In-Reply-To: <CAHA+R7Nnm0ueWPKYYT0M1Nn8DOcKcRiDG6-Py+OcNgvvnqO2Ng@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> The best thing we can try is to fix it dynamically on rx, something
> like below (if you want to try this patch, please revert the previous one):
> 
> diff --git a/net/ipv4/ipip.c b/net/ipv4/ipip.c
> index 5dc5137..5eff109 100644
> --- a/net/ipv4/ipip.c
> +++ b/net/ipv4/ipip.c
> @@ -407,6 +407,7 @@ static int ipip_rcv(struct sk_buff *skb)
>                 tstats->rx_packets++;
>                 tstats->rx_bytes += skb->len;
> 
> +               tunnel->dev->hard_header_len = skb->data - skb_mac_header(skb);
>                 __skb_tunnel_rx(skb, tunnel->dev);
> 
>                 ipip_ecn_decapsulate(iph, skb);

Thank you! This patch works too.
But I think both patches are valid: act_mirred must not panic on
receiving bad header len and ipip tunnel should not send incorrect
header len too.
