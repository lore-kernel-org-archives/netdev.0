From: Stephan Gatzka <stephan.gatzka@gmail.com>
Subject: Re: [RFC PATCH 6/6] ipv6: IPv6 over IEEE1394 (RFC3146) support.
Date: Sat, 12 Jan 2013 17:37:32 +0100
Message-ID: <50F1914C.70605@gmail.com>
References: <50F17178.3090705@linux-ipv6.org> <20130112164741.1a0ab7bb@stein>
Reply-To: stephan.gatzka@gmail.com
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>,
	netdev@vger.kernel.org, linux1394-devel@lists.sourceforge.net
To: Stefan Richter <stefanr@s5r6.in-berlin.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ea0-f181.google.com ([209.85.215.181]:65014 "EHLO
	mail-ea0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753736Ab3ALQhf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 12 Jan 2013 11:37:35 -0500
Received: by mail-ea0-f181.google.com with SMTP id k14so1090050eaa.12
        for <netdev@vger.kernel.org>; Sat, 12 Jan 2013 08:37:34 -0800 (PST)
In-Reply-To: <20130112164741.1a0ab7bb@stein>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


> Dito, please do not solve this with an EXPORT from drivers/firewire/net.c.
Again, I totally agree from the architectural point of view.

>
> Either a new driver callback is required, and the function pointer to this
> callback needs to be reachable indirectly via the skb pointer.

How I understand the whole ndisc code, ndisc just copes with struct 
net_devices. So to break the dependency to the firewire net driver an 
optional callback routine in struct net_device might be the easiest way.

> Or drivers/firewire/net.c needs to be aware that it just received an NDP
> packet, and then call a parser function in net/ipv6/ndisc.c which returns
> the data that drivers/firewire/net.c wants to know.

I think that is definitely to late. All cryptographic stuff (IPSEC) will 
be done and I don't think we want to recalculate that afterwards.
