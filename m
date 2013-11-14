From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH iproute2] htb: support 64bit rates
Date: Thu, 14 Nov 2013 06:32:58 -0800
Message-ID: <1384439578.28458.149.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1384295647.28458.31.camel@edumazet-glaptop2.roam.corp.google.com>
		 <52834248.3040103@huawei.com>
	 <1384352510.28458.105.camel@edumazet-glaptop2.roam.corp.google.com>
	 <528483CE.6050100@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Stephen Hemminger <stephen@networkplumber.org>,
	netdev <netdev@vger.kernel.org>
To: Yang Yingliang <yangyingliang@huawei.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f182.google.com ([209.85.192.182]:56530 "EHLO
	mail-pd0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753628Ab3KNOdA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 14 Nov 2013 09:33:00 -0500
Received: by mail-pd0-f182.google.com with SMTP id y13so2070341pdi.27
        for <netdev@vger.kernel.org>; Thu, 14 Nov 2013 06:32:59 -0800 (PST)
In-Reply-To: <528483CE.6050100@huawei.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2013-11-14 at 16:03 +0800, Yang Yingliang wrote:
> On 2013/11/13 22:21, Eric Dumazet wrote:
> > On Wed, 2013-11-13 at 17:11 +0800, Yang Yingliang wrote:
> >>> -	if (!buffer) buffer = opt.rate.rate / get_hz() + mtu;
> >>> -	if (!cbuffer) cbuffer = opt.ceil.rate / get_hz() + mtu;
> >>> +	if (!buffer)
> >>> +		buffer = rate64 / get_hz() + mtu;
> >>> +	if (!cbuffer)
> >>> +		cbuffer = ceil64 / get_hz() + mtu;
> >>
> >> Hi,
> >> It may overflow here if rate64 and mtu are big enough.
> > 
> > Not really.
> > 
> > get_hz() on current kernels is really huge : 1000000000
> 
> Yeah, in normal condition, it won't happen.
> If user make a wrong input, such as "rate 0x800000000Gbit",
> Overflow happens. Although it has no impact on the value of the "opt.buffer".
> If it's better to have a judgement of the buffer's value. :)

Oh well, I can see you never really used HTB on high rates.

I'll send a v2 so that you can feel better ;)
