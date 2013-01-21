From: Stephan Gatzka <stephan.gatzka@gmail.com>
Subject: Re: [RFC:] struct net_device_ops: Add function pointer to fill device
 specific ndisc information
Date: Mon, 21 Jan 2013 07:25:33 +0100
Message-ID: <50FCDF5D.3060300@gmail.com>
References: <50FC2EE4.3080705@gmail.com> <50FC3BB1.4070005@linux-ipv6.org> <50FC6068.3020302@gmail.com> <50FCA825.7070609@linux-ipv6.org>
Reply-To: stephan.gatzka@gmail.com
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: linux1394-devel@lists.sourceforge.net,
	netdev <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>
To: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ee0-f46.google.com ([74.125.83.46]:37605 "EHLO
	mail-ee0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751273Ab3AUGZh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 21 Jan 2013 01:25:37 -0500
Received: by mail-ee0-f46.google.com with SMTP id e49so2628568eek.5
        for <netdev@vger.kernel.org>; Sun, 20 Jan 2013 22:25:35 -0800 (PST)
In-Reply-To: <50FCA825.7070609@linux-ipv6.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> We could have multiple "net_device"s per single physical
> interface at the same time, then.

Of course, but I would avoid it if it's not necessary. What's the 
problem with introducing a function pointer in struct net_device or 
struct net_device_ops?

>
> Multicast is a big issue.  Because IPv6 is fan of
> multicast, and it uses link-local multicast as its
> core infrastructure.  Without infrastructure to
> support it, I'm not going to agree.

firewire net supports multicast and we use it very often. My patch to 
support IPv6 does not change it. In fact, because I can communicate via 
IPv6  between two firewire nodes, multicast _is_ running. The driver 
does not do lot's of special things with multicast packets. But 
multicast packets are recognized because they have to be sent somehow 
different (GASP).

>
> And, firewire driver does not seem to support zerocopy
> (fragmented skb) support.  It help performance.

O.k., good point. I will have a look into that. But I suggest to not mix 
up this issue with the IPv6 over firewire enhancement. That should be a 
separate patch.

Stephan
