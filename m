From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next] net: add documentation for BQL helpers
Date: Fri, 06 Sep 2013 08:18:26 -0700
Message-ID: <1378480706.31445.26.camel@edumazet-glaptop>
References: <1378465119-1894-1-git-send-email-f.fainelli@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net
To: Florian Fainelli <f.fainelli@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f42.google.com ([209.85.220.42]:56722 "EHLO
	mail-pa0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753710Ab3IFPS3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 6 Sep 2013 11:18:29 -0400
Received: by mail-pa0-f42.google.com with SMTP id lj1so3485880pab.15
        for <netdev@vger.kernel.org>; Fri, 06 Sep 2013 08:18:28 -0700 (PDT)
In-Reply-To: <1378465119-1894-1-git-send-email-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2013-09-06 at 11:58 +0100, Florian Fainelli wrote:

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

Here, you should instead document that the @bytes must exactly match the
amount given in netdev_sent_queue(), or else BQL can panic.

(each queued skb accounts for X bytes on BQL, so at TX completion, same
X must be unaccounted)
