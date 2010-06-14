From: Changli Gao <xiaosuo@gmail.com>
Subject: Re: [PATCH] fragment: add fast path
Date: Mon, 14 Jun 2010 10:03:04 +0800
Message-ID: <AANLkTilf218t898mfK1jeIFtFBFE8OvAeoOIxQTnmEt3@mail.gmail.com>
References: <1276470995-21713-1-git-send-email-xiaosuo@gmail.com>
	<20100613.181857.189703148.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: kuznet@ms2.inr.ac.ru, pekkas@netcore.fi, jmorris@namei.org,
	yoshfuji@linux-ipv6.org, kaber@trash.net, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vw0-f46.google.com ([209.85.212.46]:62564 "EHLO
	mail-vw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755146Ab0FNCDZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 13 Jun 2010 22:03:25 -0400
Received: by vws16 with SMTP id 16so62811vws.19
        for <netdev@vger.kernel.org>; Sun, 13 Jun 2010 19:03:24 -0700 (PDT)
In-Reply-To: <20100613.181857.189703148.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Jun 14, 2010 at 9:18 AM, David Miller <davem@davemloft.net> wrote:
> From: Changli Gao <xiaosuo@gmail.com>
> Date: Mon, 14 Jun 2010 07:16:35 +0800
>
>> As the fragments are usually in order,
>
> In what universe does this happen "usually"?
>
> Linux has been outputting fragments in reverse order for more than 10
> years.
>

I have tested next-next-2.6 and darwin, and found they are both send
fragments in order:

Darwin:

Darwin localhost 9.8.0 Darwin Kernel Version 9.8.0: Wed Jul 15
16:55:01 PDT 2009; root:xnu-1228.15.4~1/RELEASE_I386 i386 i386

09:53:26.891820 IP (tos 0x0, ttl 64, id 19628, offset 0, flags [+],
proto UDP (17), length 1500) 10.13.3.10.52189 > 10.13.150.1.8888: UDP,
length 8192
09:53:26.892048 IP (tos 0x0, ttl 64, id 19628, offset 1480, flags [+],
proto UDP (17), length 1500) 10.13.3.10 > 10.13.150.1: udp
09:53:26.892229 IP (tos 0x0, ttl 64, id 19628, offset 2960, flags [+],
proto UDP (17), length 1500) 10.13.3.10 > 10.13.150.1: udp
09:53:26.892397 IP (tos 0x0, ttl 64, id 19628, offset 4440, flags [+],
proto UDP (17), length 1500) 10.13.3.10 > 10.13.150.1: udp
09:53:26.892529 IP (tos 0x0, ttl 64, id 19628, offset 5920, flags [+],
proto UDP (17), length 1500) 10.13.3.10 > 10.13.150.1: udp
09:53:26.892670 IP (tos 0x0, ttl 64, id 19628, offset 7400, flags
[none], proto UDP (17), length 820) 10.13.3.10 > 10.13.150.1: udp

Linux:

Linux localhost 2.6.35-rc1 #88 SMP Sun Jun 13 14:25:07 CST 2010 x86_64
Intel(R) Core(TM)2 Duo CPU E6550 @ 2.33GHz GenuineIntel GNU/Linux

08:01:53.730902 IP (tos 0x0, ttl 64, id 1263, offset 0, flags [+],
proto UDP (17), length 1500) 10.13.150.50.45295 > 10.13.150.1.8888:
UDP, length 8192
08:01:53.730955 IP (tos 0x0, ttl 64, id 1263, offset 1480, flags [+],
proto UDP (17), length 1500) 10.13.150.50 > 10.13.150.1: udp
08:01:53.731113 IP (tos 0x0, ttl 64, id 1263, offset 2960, flags [+],
proto UDP (17), length 1500) 10.13.150.50 > 10.13.150.1: udp
08:01:53.731139 IP (tos 0x0, ttl 64, id 1263, offset 4440, flags [+],
proto UDP (17), length 1500) 10.13.150.50 > 10.13.150.1: udp
08:01:53.731280 IP (tos 0x0, ttl 64, id 1263, offset 5920, flags [+],
proto UDP (17), length 1500) 10.13.150.50 > 10.13.150.1: udp
08:01:53.731306 IP (tos 0x0, ttl 64, id 1263, offset 7400, flags
[none], proto UDP (17), length 820) 10.13.150.50 > 10.13.150.1: udp

Later I'll test Windows.

-- 
Regards,
Changli Gao(xiaosuo@gmail.com)
