From: William Allen Simpson <william.allen.simpson@gmail.com>
Subject: Re: [PATCH v4] tcp: harmonize tcp_vx_rcv header length assumptions
Date: Thu, 14 Jan 2010 10:02:03 -0500
Message-ID: <4B4F31EB.1000004@gmail.com>
References: <4B49D001.4000302@gmail.com> <4B4DA4F4.6060007@gmail.com>	 <20100113115617.GA24818@basil.fritz.box> <4B4DE887.6030602@gmail.com>	 <20100113155323.GB24818@basil.fritz.box> <4B4E23E0.4000007@gmail.com>	 <4B4E378A.7040506@gmail.com> <1263430990.1966.12.camel@Joe-Laptop.home> <4B4ED830.4040407@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Joe Perches <joe@perches.com>, Andi Kleen <andi@firstfloor.org>,
	Linux Kernel Developers <linux-kernel@vger.kernel.org>,
	Linux Kernel Network Developers <netdev@vger.kernel.org>,
	=?ISO-8859-15?Q?Ilpo_J=E4rvinen?= <ilpo.jarvinen@helsinki.fi>,
	Eric Dumazet <eric.dumazet@gmail.com>
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-iw0-f194.google.com ([209.85.223.194]:56322 "EHLO
	mail-iw0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756837Ab0ANPCG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 14 Jan 2010 10:02:06 -0500
In-Reply-To: <4B4ED830.4040407@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Patrick McHardy wrote:
> In IPv6 it is released in ip6_input.c before the packet is handed to
> the protocol handler.
> 
Thanks, I made a note of it.

Thanks to Andi, I've been using his suggestion to compare the IPv4 and
IPv6 generated code.  Another minor difference between them was IPv4
stored *iph.

So, I added *ip6h, and discovered that it made the code longer.  Later
inline function invocations had also calculated it, so adding it merely
calculated it earlier and stored it.  The code thrashes registers
making room for the additional variable.  I'm guessing that the IPv6
folks had already looked at the issue....  Good work!

So, I tried removing *iph, and that shrunk the IPv4 code some, too.

Thanks to everybody for their comments and review.
