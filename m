From: =?UTF-8?Q?Maciej_=C5=BBenczykowski?= <maze@google.com>
Subject: Re: [PATCH net-next] gro: relax ID check in inet_gro_receive()
Date: Thu, 21 Mar 2013 13:47:07 -0700
Message-ID: <CANP3RGdjmgm10rH4AZAVt8Zx+MjwKkzxZ6hoJYuYmQXEz25qQg@mail.gmail.com>
References: <CAM8tLiMbSQZZW0NBPXGgdHRSJ8UqH+q=QaR+2KOqsf-gt6RHGg@mail.gmail.com>
	<20130321.145627.565133121162775865.davem@davemloft.net>
	<CANP3RGc1+n3Qt7k53NJtPO9njZw+WNVLKTLJq=ErYJmyb-Skcg@mail.gmail.com>
	<20130321.162017.605403865098695084.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Dmitry Kravkov <dkravkov@gmail.com>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Linux NetDev <netdev@vger.kernel.org>,
	Dmitry Kravkov <dmitry@broadcom.com>,
	Eilon Greenstein <eilong@broadcom.com>,
	Pravin B Shelar <pshelar@nicira.com>,
	Hsiao-keng Jerry Chu <hkchu@google.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f179.google.com ([209.85.214.179]:35984 "EHLO
	mail-ob0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752949Ab3CUUrI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 21 Mar 2013 16:47:08 -0400
Received: by mail-ob0-f179.google.com with SMTP id un3so3306854obb.24
        for <netdev@vger.kernel.org>; Thu, 21 Mar 2013 13:47:08 -0700 (PDT)
In-Reply-To: <20130321.162017.605403865098695084.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> We have very reasonable requirements for segmentation offloads

I would tend to disagree with reversibility being a reasonable requirement.
It offers extremely little benefit, and thus it's a nice to have at best.
However, I do understand why you might want it, and thus I can
understand why you might not want to accept this patch (which would
make GRO less reversible).

This logic does not apply to the GRE segmentation offload patches.
They might create non incrementing IP ID packet sequences on the wire,
and this may prevent GRO from kicking in, but it does not make TSO
non-reversible
(if anything it makes it easy to detect that it happened).

Would you perhaps be willing to take a patch which simply removes the
flag from the driver features?
But leaves the code in?
