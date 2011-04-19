From: Michal Simek <monstr@monstr.eu>
Subject: Re: Add NAPI support to ll_temac driver
Date: Tue, 19 Apr 2011 14:48:49 +0200
Message-ID: <4DAD84B1.9020405@monstr.eu>
References: <4DAD5753.4040108@monstr.eu>	 <1303209787.3480.9.camel@edumazet-laptop> <1303215925.3464.54.camel@localhost>
Reply-To: monstr@monstr.eu
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Eric Dumazet <eric.dumazet@gmail.com>, netdev@vger.kernel.org
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f46.google.com ([209.85.161.46]:48902 "EHLO
	mail-fx0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754157Ab1DSMsw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 19 Apr 2011 08:48:52 -0400
Received: by fxm17 with SMTP id 17so3346564fxm.19
        for <netdev@vger.kernel.org>; Tue, 19 Apr 2011 05:48:51 -0700 (PDT)
In-Reply-To: <1303215925.3464.54.camel@localhost>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Ben Hutchings wrote:
> On Tue, 2011-04-19 at 12:43 +0200, Eric Dumazet wrote:
> [...]
>> One possible way to get better performance is to change driver to
>> allocate skbs only right before calling netif_rx(), so that you dont
>> have to access cold sk_buff data twice (once when allocating skb and put
>> it in ring buffer, a second time when receiving frame)
>>
>> drivers/net/niu.c is a good example for this (NAPI + netdev_alloc_skb()
>> just in time + pull in skbhead only first cache line of packet)
> [...]
> 
> If the hardware can do RX checksumming (it's not clear) then the driver
> should pass the paged buffers into GRO and that will take care of skb
> allocation as necessary.

Hardware supports RX and TX partial checksumming. I can enable it. The driver 
has also this option and from my tests there is of course some performance 
improvemetn.

Just for sure - here are links on documentation.
http://www.xilinx.com/support/documentation/ip_documentation/xps_ll_temac.pdf
or
http://www.xilinx.com/support/documentation/ip_documentation/axi_ethernet/v2_01_a/ds759_axi_ethernet.pdf

About SKB allocation. I fixed our non mainline driver to allocate skb based on 
current mtu size. Mainline driver allocate max mtu (9k). This has also impact on 
performance because Microblaze works with smaller SKBs.

Can you please be more specific about passing the paged buffers into GRO?
Or point me to any documentation or code which can help me to understand what 
that means.

Thanks,
Michal


-- 
Michal Simek, Ing. (M.Eng)
w: www.monstr.eu p: +42-0-721842854
Maintainer of Linux kernel 2.6 Microblaze Linux - http://www.monstr.eu/fdt/
Microblaze U-BOOT custodian
