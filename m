From: Patrick McHardy <kaber@trash.net>
Subject: Re: 2.6.20.3-rc1 / iproute2 hoplimit 2^32-1 vs 2^8-1
Date: Mon, 19 Mar 2007 16:27:29 +0100
Message-ID: <45FEABE1.9050003@trash.net>
References: <Pine.LNX.4.64.0703191706530.3331@netcore.fi> <45FEAA3E.20601@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Pekka Savola <pekkas@netcore.fi>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:59186 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1030196AbXCSP1f (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 19 Mar 2007 11:27:35 -0400
In-Reply-To: <45FEAA3E.20601@trash.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Patrick McHardy wrote:
> Pekka Savola wrote:
> 
>>On kernel based on 2.6.20.3-rc1 (FC6), 'ip -6 r l' shows:
>>
>>default via fe80::212:f0ff:fe5f:c4ec dev eth1  proto kernel  metric
>>1024  expires 7191sec mtu 1500 advmss 1440 hoplimit 4294967295
>>
>>(this is the same with iproute2-ss061214 and iproute2-ss070313.)
>>
>>So, it seems that the data length for hoplimit is not quite right, or
>>it's reported as 2^32-1 instead of 2^8-1...
> 
> 
> 
> Does this fix it?


Mhh actually this looks intentional:

icmpv6_send and some other output functions do:
	int hlimit;
...
        if (hlimit < 0)
                hlimit = dst_metric(dst, RTAX_HOPLIMIT);
        if (hlimit < 0)
                hlimit = ipv6_get_hoplimit(dst->dev);

