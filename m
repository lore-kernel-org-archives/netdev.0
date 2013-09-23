From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next] xen-netfront: convert to GRO API and advertise
 this feature
Date: Sun, 22 Sep 2013 22:58:27 -0700
Message-ID: <1379915907.3165.5.camel@edumazet-glaptop>
References: <1379779543-27122-1-git-send-email-wei.liu2@citrix.com>
	 <1379861723.3431.10.camel@edumazet-glaptop>
	 <D310C490-3B7D-4937-95DC-AFC1682B60BE@juniper.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Wei Liu <wei.liu2@citrix.com>,
	"<netdev@vger.kernel.org>" <netdev@vger.kernel.org>,
	"<xen-devel@lists.xen.org>" <xen-devel@lists.xen.org>,
	Ian Campbell <ian.campbell@citrix.com>
To: Anirban Chakraborty <abchak@juniper.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f175.google.com ([209.85.192.175]:39639 "EHLO
	mail-pd0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751944Ab3IWF63 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 23 Sep 2013 01:58:29 -0400
Received: by mail-pd0-f175.google.com with SMTP id q10so2798691pdj.34
        for <netdev@vger.kernel.org>; Sun, 22 Sep 2013 22:58:29 -0700 (PDT)
In-Reply-To: <D310C490-3B7D-4937-95DC-AFC1682B60BE@juniper.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, 2013-09-22 at 23:09 +0000, Anirban Chakraborty wrote:
> On Sep 22, 2013, at 7:55 AM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
> 
> > On Sat, 2013-09-21 at 17:05 +0100, Wei Liu wrote:
> >> Anirban was seeing netfront received MTU size packets, which downgraded
> >> throughput. The following patch makes netfront use GRO API which
> >> improves throughput for that case.
> > 
> >> -	netdev->hw_features	= NETIF_F_IP_CSUM | NETIF_F_SG | NETIF_F_TSO;
> >> +	netdev->hw_features	= NETIF_F_IP_CSUM | NETIF_F_SG | NETIF_F_TSO |
> >> +				  NETIF_F_GRO;
> > 
> > 
> > This part is not needed.
> 
> Shouldn't the flag be set? In dev_gro_receive() we do check if this flag is set or not:
> 
>         if (!(skb->dev->features & NETIF_F_GRO) || netpoll_rx_on(skb))
>                goto normal;

Drivers do not set NETIF_F_GRO themselves, they do not need to.

Look at other drivers which are GRO ready : NETIF_F_GRO is enabled by
default by core networking stack, in register_netdevice()


dev->hw_features |= NETIF_F_SOFT_FEATURES;
dev->features |= NETIF_F_SOFT_FEATURES;
