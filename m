From: Eugene Teo <eugeneteo@kernel.sg>
Subject: Re: OOPS, ip -f inet6 route get fec0::1, linux-2.6.26, ip6_route_output,
 rt6_fill_node+0x175
Date: Tue, 12 Aug 2008 08:41:27 +0800
Message-ID: <48A0DC37.7080209@kernel.sg>
References: <20080807203748.GA5196@martell.zuzino.mipt.ru>	<489BD227.6000209@hp.com>	<489FFAF8.3000909@redhat.com> <20080811.135003.105171324.davem@davemloft.net> <48A0D5B4.9050908@kernel.sg>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: brian.haley@hp.com, adobriyan@gmail.com, john.gumb@tandberg.com,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	parag.warudkar@gmail.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([66.187.233.31]:59484 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753341AbYHLAmR (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 11 Aug 2008 20:42:17 -0400
In-Reply-To: <48A0D5B4.9050908@kernel.sg>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Eugene Teo wrote:
> David Miller wrote:
>> From: Eugene Teo <eteo@redhat.com>
>> Date: Mon, 11 Aug 2008 16:40:24 +0800
[...]
> With the patch I posted, this is the behaviour I get:
> 
> $ ip -f inet6 route get fec0::1
> unreachable fec0::1 dev lo  table unspec  proto none  src
> fe80::214:4fff:fe0f:7332  metric -1  error -101 hoplimit 255

Ok, so there's a mistake in my patch. It should return the loopback MAC
address instead. I'm wondering if the fix should be related to
initialising rt6i_idev in addrconf_init routine like in the upstream
commit: c62dba9011b93fd88fde929848582b2a98309878. The code changed quite
a lot.

Eugene
