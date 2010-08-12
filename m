From: =?UTF-8?Q?Maciej_=C5=BBenczykowski?= <zenczykowski@gmail.com>
Subject: Re: sky2 driver fails to handle "rx length error: status 0x5d60100
 length 2982" gracefully
Date: Thu, 12 Aug 2010 09:58:01 -0700
Message-ID: <AANLkTinM2m-dK2FYw5VBi3eBAhBRrrzZ+vH5aCtDoDVS@mail.gmail.com>
References: <AANLkTinMK7n51v4uBPYChYV7KOye8WEvdCFDanfd2mVL@mail.gmail.com>
	<20100811215932.26414efe@s6510>
	<AANLkTikDOerA4g+-=v+wM8cmysnemCTqEx0ncCCERLY6@mail.gmail.com>
	<20100812120044.5b1880ad@s6510>
	<20100812121600.2e971e66@s6510>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Stephen Hemminger <shemminger@linux-foundation.org>,
	Linux NetDev <netdev@vger.kernel.org>
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:38749 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1760411Ab0HLQ6D (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 12 Aug 2010 12:58:03 -0400
Received: by wwj40 with SMTP id 40so1788729wwj.1
        for <netdev@vger.kernel.org>; Thu, 12 Aug 2010 09:58:02 -0700 (PDT)
In-Reply-To: <20100812121600.2e971e66@s6510>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I'm not sure if there is a known good kernel.  It seems to be getting
worse over time (as I upgrade kernels), but maybe the hardware is
aging and the situation is becoming more likely.  When it first
started happening it was like once every 2-3 months or even rarer.
Now it has happened again since the last time I posted to this
thread...

Aug 12 08:29:08 nike kernel: sky2 0000:0c:00.0: eth0: rx length error:
status 0x5e50100 length 3013

> Are you trying to run with Jumbo >1500 MTU?

No, normal 1500 MTU network, with ipv4 and ipv6 native traffic.  Not a
huge amount of traffic either.
And indeed the problem seems to happen just as easily (if not easier)
when the machine (and thus the network) is close(r) to idle (ie.
overnight, etc) - although that might just be a matter of more time
passing.

Are you sure there is nothing the driver could do on seeing such an error?
It seems like since "ip link set eth0 down && ip link set eth0 up"
fixes it, what it should do is some sort of partial reset...

I will try to verify if 'ethtool -K eth0 rx off && ethtool -K eth0 rx
on' is enough to fix the problem (when it happens once again).
Afterwards I'll turn of rx csum (ethtool -K eth0 rx off) and will see
if it happens again.
