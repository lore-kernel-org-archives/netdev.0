From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next] ipv6: optimize ipv6 addresses compares
Date: Wed, 11 Jul 2012 06:07:58 +0200
Message-ID: <1341979678.3265.6660.camel@edumazet-glaptop>
References: <1341978558.3265.6609.camel@edumazet-glaptop>
	 <20120710.210221.559183284956265274.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, joe@perches.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-we0-f174.google.com ([74.125.82.174]:47805 "EHLO
	mail-we0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751289Ab2GKEID (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 11 Jul 2012 00:08:03 -0400
Received: by weyx8 with SMTP id x8so562571wey.19
        for <netdev@vger.kernel.org>; Tue, 10 Jul 2012 21:08:01 -0700 (PDT)
In-Reply-To: <20120710.210221.559183284956265274.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2012-07-10 at 21:02 -0700, David Miller wrote:
> From: Eric Dumazet <eric.dumazet@gmail.com>
> Date: Wed, 11 Jul 2012 05:49:18 +0200
> 
> > From: Eric Dumazet <edumazet@google.com>
> > 
> > On 64 bit arches having efficient unaligned accesses (eg x86_64) we can
> > use long words to reduce number of instructions for free.
> > 
> > Signed-off-by: Eric Dumazet <edumazet@google.com>
> > Cc: Joe Perches <joe@perches.com>
> 
> Maybe we can even be sure that they are 64-bit aligned too?
> 
> If there's an embedded u64 in the in6_addr union, they really should
> be.
> 
> It can't even be an issue in the protocol headers, because in the
> socket demux we read the two 32-bit ipv4 addresses in the packet
> header as one 64-bit chunk already.

I dont think this 8bytes alignment is possible with ip6tables.
