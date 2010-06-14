From: Changli Gao <xiaosuo@gmail.com>
Subject: Re: [PATCH] fragment: add fast path
Date: Mon, 14 Jun 2010 10:55:38 +0800
Message-ID: <AANLkTiliyOrReGgqzRChwA8jKic9chAag-1UqSWs7oa9@mail.gmail.com>
References: <1276470995-21713-1-git-send-email-xiaosuo@gmail.com>
	<20100613.181857.189703148.davem@davemloft.net> <AANLkTilf218t898mfK1jeIFtFBFE8OvAeoOIxQTnmEt3@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: kuznet@ms2.inr.ac.ru, pekkas@netcore.fi, jmorris@namei.org,
	yoshfuji@linux-ipv6.org, kaber@trash.net, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vw0-f46.google.com ([209.85.212.46]:48396 "EHLO
	mail-vw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755307Ab0FNC4A (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 13 Jun 2010 22:56:00 -0400
Received: by vws16 with SMTP id 16so117347vws.19
        for <netdev@vger.kernel.org>; Sun, 13 Jun 2010 19:55:59 -0700 (PDT)
In-Reply-To: <AANLkTilf218t898mfK1jeIFtFBFE8OvAeoOIxQTnmEt3@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Jun 14, 2010 at 10:03 AM, Changli Gao <xiaosuo@gmail.com> wrote:
>
> Later I'll test Windows.
>

Windows also sends fragments in order.

10:40:29.064453 IP (tos 0x0, ttl 128, id 35511, offset 0, flags [+],
proto UDP (17), length 1452) 221.238.33.71.4194 > 202.113.29.4.8888:
UDP, length 32768
10:40:29.064453 IP (tos 0x0, ttl 128, id 35511, offset 1432, flags
[+], proto UDP (17), length 1452) 221.238.33.71 > 202.113.29.4: udp
10:40:29.064453 IP (tos 0x0, ttl 128, id 35511, offset 2864, flags
[+], proto UDP (17), length 1452) 221.238.33.71 > 202.113.29.4: udp
10:40:29.064453 IP (tos 0x0, ttl 128, id 35511, offset 4296, flags
[+], proto UDP (17), length 1452) 221.238.33.71 > 202.113.29.4: udp
10:40:29.064453 IP (tos 0x0, ttl 128, id 35511, offset 5728, flags
[+], proto UDP (17), length 1452) 221.238.33.71 > 202.113.29.4: udp
10:40:29.064453 IP (tos 0x0, ttl 128, id 35511, offset 7160, flags
[+], proto UDP (17), length 1452) 221.238.33.71 > 202.113.29.4: udp
10:40:29.064453 IP (tos 0x0, ttl 128, id 35511, offset 8592, flags
[+], proto UDP (17), length 1452) 221.238.33.71 > 202.113.29.4: udp
10:40:29.064453 IP (tos 0x0, ttl 128, id 35511, offset 10024, flags
[+], proto UDP (17), length 1452) 221.238.33.71 > 202.113.29.4: udp
10:40:29.064453 IP (tos 0x0, ttl 128, id 35511, offset 11456, flags
[+], proto UDP (17), length 1452) 221.238.33.71 > 202.113.29.4: udp
10:40:29.064453 IP (tos 0x0, ttl 128, id 35511, offset 12888, flags
[+], proto UDP (17), length 1452) 221.238.33.71 > 202.113.29.4: udp
10:40:29.064453 IP (tos 0x0, ttl 128, id 35511, offset 14320, flags
[+], proto UDP (17), length 1452) 221.238.33.71 > 202.113.29.4: udp
10:40:29.064453 IP (tos 0x0, ttl 128, id 35511, offset 15752, flags
[+], proto UDP (17), length 1452) 221.238.33.71 > 202.113.29.4: udp
10:40:29.066406 IP (tos 0x0, ttl 128, id 35511, offset 17184, flags
[+], proto UDP (17), length 1452) 221.238.33.71 > 202.113.29.4: udp
10:40:29.066406 IP (tos 0x0, ttl 128, id 35511, offset 18616, flags
[+], proto UDP (17), length 1452) 221.238.33.71 > 202.113.29.4: udp
10:40:29.066406 IP (tos 0x0, ttl 128, id 35511, offset 20048, flags
[+], proto UDP (17), length 1452) 221.238.33.71 > 202.113.29.4: udp
10:40:29.066406 IP (tos 0x0, ttl 128, id 35511, offset 21480, flags
[+], proto UDP (17), length 1452) 221.238.33.71 > 202.113.29.4: udp
10:40:29.066406 IP (tos 0x0, ttl 128, id 35511, offset 22912, flags
[+], proto UDP (17), length 1452) 221.238.33.71 > 202.113.29.4: udp
10:40:29.066406 IP (tos 0x0, ttl 128, id 35511, offset 24344, flags
[+], proto UDP (17), length 1452) 221.238.33.71 > 202.113.29.4: udp
10:40:29.066406 IP (tos 0x0, ttl 128, id 35511, offset 25776, flags
[+], proto UDP (17), length 1452) 221.238.33.71 > 202.113.29.4: udp
10:40:29.066406 IP (tos 0x0, ttl 128, id 35511, offset 27208, flags
[+], proto UDP (17), length 1452) 221.238.33.71 > 202.113.29.4: udp
10:40:29.066406 IP (tos 0x0, ttl 128, id 35511, offset 28640, flags
[+], proto UDP (17), length 1452) 221.238.33.71 > 202.113.29.4: udp
10:40:29.066406 IP (tos 0x0, ttl 128, id 35511, offset 30072, flags
[+], proto UDP (17), length 1452) 221.238.33.71 > 202.113.29.4: udp
10:40:29.066406 IP (tos 0x0, ttl 128, id 35511, offset 31504, flags
[none], proto UDP (17), length 1292) 221.238.33.71 > 202.113.29.4: udp

-- 
Regards,
Changli Gao(xiaosuo@gmail.com)
