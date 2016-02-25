From: Arnd Bergmann <arnd@arndb.de>
Subject: Re: [PATCH 3/4] net: ipv4: tcp_probe: Replace timespec with timespec64
Date: Thu, 25 Feb 2016 16:01:13 +0100
Message-ID: <10756653.OfUfst5I70@wuerfel>
References: <1456384031-29244-1-git-send-email-deepa.kernel@gmail.com> <1456384031-29244-4-git-send-email-deepa.kernel@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7Bit
Cc: netdev@vger.kernel.org, y2038@lists.linaro.org,
	"David S. Miller" <davem@davemloft.net>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	James Morris <jmorris@namei.org>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	Patrick McHardy <kaber@trash.net>
To: Deepa Dinamani <deepa.kernel@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mout.kundenserver.de ([217.72.192.74]:51912 "EHLO
	mout.kundenserver.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1760269AbcBYPB2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 25 Feb 2016 10:01:28 -0500
In-Reply-To: <1456384031-29244-4-git-send-email-deepa.kernel@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wednesday 24 February 2016 23:07:10 Deepa Dinamani wrote:
> TCP probe log timestamps use struct timespec which is
> not y2038 safe. Even though timespec might be good enough here
> as it is used to represent delta time, the plan is to get rid
> of all uses of timespec in the kernel.
> Replace with struct timespec64 which is y2038 safe.
> 
> Prints still use unsigned long format and type.
> This is because long is 64 bit on 64 bit systems and 32 bit on
> 32 bit systems. Hence, time64_t(64 bit signed number) does not
> have a specifier that matches on both architectures.

Actually time64_t is always 'long long', but tv_sec is time_t 
(long) instead of time64_t on 64-bit architectures.

Using a %ll format string and a cast to s64 would work as well,
but as you say above, it's not important here.

> Signed-off-by: Deepa Dinamani <deepa.kernel@gmail.com>

Reviewed-by: Arnd Bergmann <arnd@arndb.de>
