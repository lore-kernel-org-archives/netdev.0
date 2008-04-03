From: Patrick McHardy <kaber@trash.net>
Subject: Re: 2.6.25-rc8 regression with openswan
Date: Thu, 03 Apr 2008 14:06:11 +0200
Message-ID: <47F4C833.1020607@trash.net>
References: <BAY103-DAV8D067EC595CECC2C4281CB2F70@phx.gbl> <47F4BD3F.30703@trash.net> <BAY103-DAV6A19A7FE52B2CD3AD1B0EB2F70@phx.gbl>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Marco Berizzi <pupilla@hotmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:65052 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756090AbYDCMGP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 Apr 2008 08:06:15 -0400
In-Reply-To: <BAY103-DAV6A19A7FE52B2CD3AD1B0EB2F70@phx.gbl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Marco Berizzi wrote:
> Patrick McHardy wrote:
> 
>>> openswan 2.4.12 doesn't work anymore
>>> with 2.6.25-rc8: quick mode is failing
>>> with this error:
>>>
>>> ERROR: netlink response for Add SA esp.8a56fa21@1.1.1.1 included
> errno
>>> 93: Protocol not supported
>>>
>>> I have tried both with des3 and aes but
>>> I get always the same error.
>> What does your policy look like?
> 
> Here is output from ip -s x s and ip -s x p
> 
> root@Calimero:/var/log# ip -s x s
> src 85.36.106.213 dst 85.36.106.210
>         proto esp spi 0xabbf0fe3(2881425379) reqid 16401(0x00004011)
> mode tunnel
>         replay-window 0 seq 0x00000000 flag  (0x00000000)
>         sel src 85.36.106.213/32 dst 85.36.106.210/32 uid 0
>         lifetime config:
>           limit: soft (INF)(bytes), hard (INF)(bytes)
>           limit: soft (INF)(packets), hard (INF)(packets)
>           expire add: soft 0(sec), hard 30(sec)
>           expire use: soft 0(sec), hard 0(sec)
>         lifetime current:
>           0(bytes), 0(packets)
>           add 2008-04-03 13:48:46 use -
>         stats:
>           replay-window 0 replay 0 failed 0
> 
> root@Calimero:/var/log# ip -s x p
> src 0.0.0.0/0 dst 0.0.0.0/0 uid 0
>         dir in action allow index 755 priority 0 share any flag
> (0x00000000)


I'm not seeing any policies that actually specify IPsec. I'm
guessing that is something openswan-specific. Anyway, there
haven't been much patches in this area since -rc4, does
reverting commit df9dcb458 help?


