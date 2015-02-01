From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v2 0/6] net: Add STT support.
Date: Sat, 31 Jan 2015 17:40:37 -0800 (PST)
Message-ID: <20150131.174037.1176748996497876060.davem@davemloft.net>
References: <1422574156-1831-1-git-send-email-pshelar@nicira.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: pshelar@nicira.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:32900 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752974AbbBABki (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 31 Jan 2015 20:40:38 -0500
In-Reply-To: <1422574156-1831-1-git-send-email-pshelar@nicira.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Pravin B Shelar <pshelar@nicira.com>
Date: Thu, 29 Jan 2015 15:29:16 -0800

> Following patch series adds support for Stateless Transport
> Tunneling protocol.
> STT uses TCP segmentation offload available in most of NIC. On
> packet xmit STT driver appends STT header along with TCP header
> to the packet. For GSO packet GSO parameters are set according
> to tunnel configuration and packet is handed over to networking
> stack. This allows use of segmentation offload available in NICs

I don't like this at all.

Routers _absolutely_ depend upon the ability to make TCP flows back
off by dropping packets in various ways (tail drop, RED random drops,
etc.).  STT violates this completely.

It's _NOT_ TCP, you can't put lipstick on a pig and pretend it's not a
pig.  You need to use something that indicates it's flow properties,
a datagram protocol.  Either via an existing one or by creating a new
one.

I know you want to do this mass TCP behavioral violation because of
TSO.  But that's too bad.  The ends do not justify the means.

I also don't buy the argument that "people can put arbitrary changes
into their kernel to do stuff like that".

They can't do it to the stack I'm willing to maintain, and that's what
matters for %99 of systems out there.
