From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH 6/7] mlx4_en: Adding rxhash support
Date: Wed, 19 Oct 2011 15:57:08 +0100
Message-ID: <1319036228.2829.14.camel@bwh-desktop>
References: <4E9C8D8B.90606@mellanox.co.il>
	 <1318902525.2571.24.camel@edumazet-laptop>
	 <953B660C027164448AE903364AC447D2235EEB65@MTLDAG01.mtl.com>
	 <1318926870.2657.5.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
	 <953B660C027164448AE903364AC447D2235EEC80@MTLDAG01.mtl.com>
	 <20111018083606.6367ff50@nehalam.linuxnetplumber.net>
	 <1318966500.2783.124.camel@bwh-desktop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Yevgeny Petrilin <yevgenyp@mellanox.co.il>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	"davem@davemloft.net" <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.solarflare.com ([216.237.3.220]:2242 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755010Ab1JSO5M (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 19 Oct 2011 10:57:12 -0400
In-Reply-To: <1318966500.2783.124.camel@bwh-desktop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2011-10-18 at 20:35 +0100, Ben Hutchings wrote:
[...]
> There was also a proposal a while back that we should try to make the
> hash symmetric w.r.t. RX and TX addresses, so that both directions of a
> flow through a router/bridge are aligned.  I think this was to be done
> by repeating a 16-bit pattern across the key.  Not sure whether that's
> worthwhile.

That also makes it relatively cheap to calculate in software, which
DragonflyBSD does:

http://gitweb.dragonflybsd.org/dragonfly.git/blob/master:/sys/net/toeplitz.c
http://gitweb.dragonflybsd.org/dragonfly.git/blob/master:/sys/net/toeplitz2.h

(the latter file appears to assume that in_addr_t/in_port_t are byte-
swapped i.e. the host is little-endian).

Ben.

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
