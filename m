From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next] ndisc: Remove unused space at tail of skb for
 ndisc messages. (TAKE 3)
Date: Fri, 04 Jan 2013 08:00:19 -0800
Message-ID: <1357315219.1678.1461.camel@edumazet-glaptop>
References: <50E6DFEC.7080603@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev <netdev@vger.kernel.org>
To: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f43.google.com ([209.85.220.43]:37832 "EHLO
	mail-pa0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754822Ab3ADQAW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 4 Jan 2013 11:00:22 -0500
Received: by mail-pa0-f43.google.com with SMTP id fb10so9398080pad.16
        for <netdev@vger.kernel.org>; Fri, 04 Jan 2013 08:00:21 -0800 (PST)
In-Reply-To: <50E6DFEC.7080603@linux-ipv6.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2013-01-04 at 22:58 +0900, YOSHIFUJI Hideaki wrote:
> Currently, the size of skb allocated for NDISC is MAX_HEADER +
> LL_RESERVED_SPACE(dev) + packet length + dev->needed_tailroom,
> but only LL_RESERVED_SPACE(dev) bytes is "reserved" for headers.
> As a result, the skb looks like this (after construction of the
> message):
> 
> head       data                   tail                       end
> +--------------------------------------------------------------+
> +           |                      |          |                |
> +--------------------------------------------------------------+
> |<-hlen---->|<---ipv6 packet------>|<--tlen-->|<--MAX_HEADER-->|
>     =LL_                               = dev
>      RESERVED_                           ->needed_
>      SPACE(dev)                            tailroom
> 
> As the name implies, "MAX_HEADER" is used for headers, and should
> be "reserved" in prior to packet construction.  Or, if some space
> is really required at the tail of ther skb, it should be
> explicitly documented.
> 
> We have several option after construction of NDISC message:
> 
> Option 1:
> 
> head       data                   tail       end
> +---------------------------------------------+
> +           |                      |          |
> +---------------------------------------------+
> |<-hlen---->|<---ipv6 packet------>|<--tlen-->|
>    =LL_                                = dev
>     RESERVED_                           ->needed_
>     SPACE(dev)                            tailroom

Acked-by: Eric Dumazet <edumazet@google.com>

Thanks !
