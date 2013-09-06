From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next] net: add documentation for BQL helpers
Date: Fri, 06 Sep 2013 06:03:25 -0700
Message-ID: <1378472605.31445.18.camel@edumazet-glaptop>
References: <1378465119-1894-1-git-send-email-f.fainelli@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net
To: Florian Fainelli <f.fainelli@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f50.google.com ([209.85.220.50]:37238 "EHLO
	mail-pa0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751199Ab3IFND0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 6 Sep 2013 09:03:26 -0400
Received: by mail-pa0-f50.google.com with SMTP id fb10so3332627pad.9
        for <netdev@vger.kernel.org>; Fri, 06 Sep 2013 06:03:26 -0700 (PDT)
In-Reply-To: <1378465119-1894-1-git-send-email-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2013-09-06 at 11:58 +0100, Florian Fainelli wrote:
> Provide a kernel-doc comment documentation for the BQL helpers:
> - netdev_sent_queue
> - netdev_completed_queue
> - netdev_reset_queue
> 
> Similarly to how it is done for the other functions, the documentation
> only covers the function operating on struct net_device and not struct
> netdev_queue.
> 
> Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>
> ---
>  include/linux/netdevice.h | 27 +++++++++++++++++++++++++++
>  1 file changed, 27 insertions(+)
> 
> diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
> index 8ed4ae9..ac36629 100644
> --- a/include/linux/netdevice.h
> +++ b/include/linux/netdevice.h
> @@ -2101,6 +2101,16 @@ static inline void netdev_tx_sent_queue(struct netdev_queue *dev_queue,
>  #endif
>  }
>  
> +/**
> + * 	netdev_sent_queue - report the number of bytes queued to hardware
> + * 	@dev: network device
> + * 	@bytes: number of bytes queued to the hardware device queue
> + *
> + * 	Report the number of bytes queued for sending/completion to the network
> + * 	device hardware queue. @bytes should specify the number of bytes which
> + * 	will be sent over the physical medium (without prepended/appended
> + * 	control blocks, FCS...)

There is no such requirement.

@bytes should be a good approximation, and should match
netdev_completed_queue() @bytes


If you think of TSO, we know that skb->len does not exactly matches
number of bytes on physical medium ( check qdisc_pkt_len_init() to see
how Qdisc layer tries to get better estimation )


> + */
>  static inline void netdev_sent_queue(struct net_device *dev, unsigned int bytes)
>  {
>  	netdev_tx_sent_queue(netdev_get_tx_queue(dev, 0), bytes);
> @@ -2130,6 +2140,16 @@ static inline void netdev_tx_completed_queue(struct netdev_queue *dev_queue,
>  #endif
>  }
>  
> +/**
> + * 	netdev_completed_queue - report bytes and packets completed by device
> + * 	@dev: network device
> + * 	@pkts: actual number of packets sent over the medium
> + * 	@bytes: actual number of bytes sent over the medium
> + *
> + * 	Report the number of bytes and packets transmitted by the network device
> + * 	hardware queue over the physical medium (without prepended/appended
> + * 	control blocks, FCS...)
> + */
