From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [net-next PATCH V2 1/9] net: frag evictor, avoid killing warm
 frag queues
Date: Thu, 29 Nov 2012 15:01:40 -0800
Message-ID: <1354230100.3299.40.camel@edumazet-glaptop>
References: <20121129161019.17754.29670.stgit@dragon>
	 <20121129161052.17754.85017.stgit@dragon>
	 <20121129.124427.1093031685966728935.davem@davemloft.net>
	 <1354227470.11754.348.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, fw@strlen.de,
	netdev@vger.kernel.org, pablo@netfilter.org, tgraf@suug.ch,
	amwang@redhat.com, kaber@trash.net, paulmck@linux.vnet.ibm.com,
	herbert@gondor.hengli.com.au
To: Jesper Dangaard Brouer <brouer@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f46.google.com ([209.85.220.46]:59641 "EHLO
	mail-pa0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753217Ab2K2XBn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 29 Nov 2012 18:01:43 -0500
Received: by mail-pa0-f46.google.com with SMTP id bh2so7969150pad.19
        for <netdev@vger.kernel.org>; Thu, 29 Nov 2012 15:01:43 -0800 (PST)
In-Reply-To: <1354227470.11754.348.camel@localhost>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2012-11-29 at 23:17 +0100, Jesper Dangaard Brouer wrote:

> For example lets give a threshold of 2000 MBytes:
> 
> [root@dragon ~]# sysctl -w net/ipv4/ipfrag_high_thresh=$(((1024**2*2000)))
> net.ipv4.ipfrag_high_thresh = 2097152000
> 
> [root@dragon ~]# sysctl -w net/ipv4/ipfrag_low_thresh=$(((1024**2*2000)-655350))
> net.ipv4.ipfrag_low_thresh = 2096496650
> 
> 4x10 Netperf adjusted output:
>  Socket  Message  Elapsed      Messages
>  Size    Size     Time         Okay Errors   Throughput
>  bytes   bytes    secs            #      #   10^6bits/sec
> 
>  229376   65507   20.00      298685      0    7826.35
>  212992           20.00          27              0.71
> 
>  229376   65507   20.00      366668      0    9607.71
>  212992           20.00          13              0.34
> 
>  229376   65507   20.00      254790      0    6676.20
>  212992           20.00          14              0.37
> 
>  229376   65507   20.00      309293      0    8104.33
>  212992           20.00          15              0.39
> 
> Can we agree that the current evictor strategy is broken?

Not really, you drop packets because of another limit.
