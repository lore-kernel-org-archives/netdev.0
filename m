From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next] net: implement tcp coalescing in
 tcp_queue_rcv()
Date: Thu, 03 May 2012 04:14:20 +0200
Message-ID: <1336011260.22133.754.camel@edumazet-glaptop>
References: <1335977179.22133.599.camel@edumazet-glaptop>
	 <1335981358.22133.605.camel@edumazet-glaptop>
	 <1335988709.22133.632.camel@edumazet-glaptop>
	 <20120502.211157.2201073892985382154.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: alexander.duyck@gmail.com, alexander.h.duyck@intel.com,
	netdev@vger.kernel.org, ncardwell@google.com, therbert@google.com,
	jeffrey.t.kirsher@intel.com, mchan@broadcom.com,
	mcarlson@broadcom.com, herbert@gondor.hengli.com.au,
	bhutchings@solarflare.com, ilpo.jarvinen@helsinki.fi,
	maze@google.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f178.google.com ([209.85.212.178]:48755 "EHLO
	mail-wi0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755059Ab2ECCO0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 2 May 2012 22:14:26 -0400
Received: by wibhr7 with SMTP id hr7so177553wib.1
        for <netdev@vger.kernel.org>; Wed, 02 May 2012 19:14:24 -0700 (PDT)
In-Reply-To: <20120502.211157.2201073892985382154.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2012-05-02 at 21:11 -0400, David Miller wrote:
> From: Eric Dumazet <eric.dumazet@gmail.com>
> Date: Wed, 02 May 2012 21:58:29 +0200
> 
> > From: Eric Dumazet <edumazet@google.com>
> > 
> > Extend tcp coalescing implementing it from tcp_queue_rcv(), the main
> > receiver function when application is not blocked in recvmsg().
> > 
> > Function tcp_queue_rcv() is moved a bit to allow its call from
> > tcp_data_queue()
> > 
> > This gives good results especially if GRO could not kick, and if skb
> > head is a fragment.
> > 
> > Signed-off-by: Eric Dumazet <edumazet@google.com>
> 
> Applied.

Thanks David

My next step is to provide a common helper to NAPI drivers to replace 
netdev_alloc_skb_ip_align(struct net_device *dev, unsigned int len)

by :

struct sk_buff *napi_alloc_rxskb(struct napi_struct *napi, unsigned int len)

That will manage a cache of one page, splitted in fragments as needed.
(roughly the code we added in tg3 as POC)

Because converting drivers to build_skb() is a too slow process.
