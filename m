From: Patrick McHardy <kaber@trash.net>
Subject: Re: IPSec broken in 2.6.18-rc4-mm3
Date: Sat, 09 Sep 2006 18:22:52 +0200
Message-ID: <4502EA5C.5020101@trash.net>
References: <fa4052ef0609080926j5bbae070mccb9699f0e5eb1fb@mail.gmail.com>	 <4501CA01.3050904@trash.net>	 <fa4052ef0609081332l3c4d25a3xe5e315482884e1a8@mail.gmail.com>	 <4502C81E.600@trash.net> <fa4052ef0609090735o6e17da23y75bd6f742a8a29be@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:25563 "EHLO
	stinky.trash.net") by vger.kernel.org with ESMTP id S964798AbWIIQWc
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 9 Sep 2006 12:22:32 -0400
To: Gnome42 <gnome42@gmail.com>
In-Reply-To: <fa4052ef0609090735o6e17da23y75bd6f742a8a29be@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Gnome42 wrote:
> src 34.34.36.1 dst 34.34.36.6
>        proto esp spi 0x0dc3aba4(230927268) reqid 0(0x00000000) mode tunnel
>        replay-window 4 seq 0x00000001 flag  (0x00000000)
>        auth hmac(md5) 0xfea9e3e8d324265d8b7e17ec42d69b15 (128 bits)
>        enc cbc(aes) 0x21ca0a9677ff0225acd0d3f4a9bdcf61 (128 bits)
>        lifetime config:
>          limit: soft (INF)(bytes), hard (INF)(bytes)
>          limit: soft (INF)(packets), hard (INF)(packets)
>          expire add: soft 23040(sec), hard 28800(sec)
>          expire use: soft 0(sec), hard 0(sec)
>        lifetime current:
>          4560(bytes), 30(packets)
>          add 2006-09-09 10:21:41 use 2006-09-09 10:21:46
>        stats:
>          replay-window 0 replay 0 failed 0

> src 34.34.36.1 dst 34.34.36.6
>        proto esp spi 0x0dc3aba4(230927268) reqid 0(0x00000000) mode tunnel
>        replay-window 4 seq 0x991250886 flag  (0x00000000)
>        auth md5 0xfea9e3e8d324265d8b7e17ec42d69b15 (128 bits)
>        enc aes 0x21ca0a9677ff0225acd0d3f4a9bdcf61 (128 bits)
>        lifetime config:
>          limit: soft (INF)(bytes), hard (INF)(bytes)
>          limit: soft (INF)(packets), hard (INF)(packets)
>          expire add: soft 23040(sec), hard 28800(sec)
>          expire use: soft 0(sec), hard 0(sec)
>        lifetime current:
>          0(bytes), 0(packets)
>          add 2006-09-09 10:21:41 use 2006-09-09 10:21:46
>        stats:
>          replay-window 0 replay 0 failed 30

                                           ^^
This seems to be the problem, the sequence-numbers are outside the valid
window. I can't find anything that would cause this, please post a
tcpdump of the packets so we can see which values get used.

