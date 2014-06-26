From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] pktgen: Fill the payload optionally with a
 pattern
Date: Wed, 25 Jun 2014 17:54:17 -0700 (PDT)
Message-ID: <20140625.175417.231387590142784357.davem@davemloft.net>
References: <1403642415-9560-1-git-send-email-zoltan.kiss@citrix.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: steffen.klassert@secunet.com, minipli@googlemail.com,
	dborkman@redhat.com, tgraf@suug.ch, joe@perches.com,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	xen-devel@lists.xenproject.org
To: zoltan.kiss@citrix.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:39696 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753356AbaFZAyS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 25 Jun 2014 20:54:18 -0400
In-Reply-To: <1403642415-9560-1-git-send-email-zoltan.kiss@citrix.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Zoltan Kiss <zoltan.kiss@citrix.com>
Date: Tue, 24 Jun 2014 21:40:15 +0100

> Introduces a new flag called PATTERN, which puts a non-periodic, predicatble
> pattern into the payload. This was useful to reproduce an otherwise intermittent
> bug in xen-netback [1], where checksum checking doesn't help.
> The pattern is a repetition of " %lu", a series of increasing numbers divided by
> space. The value of the number is the size of the preceding payload area. E.g.
> " 1 3 5"..." 1000 1005 1010"
> If the pattern is used, every frag will have its own page, unlike before, so it
> needs more memory.
> 
> [1] 5837574: xen-netback: Fix grant ref resolution in RX path
> 
> Signed-off-by: Zoltan Kiss <zoltan.kiss@citrix.com>

You are changing the page allocation strategy regardless of the pattern
setting, this is undesirable.

It may be significantly faster to use the same page for all the frags,
and this is absolutely critical for pktgen usage where every nanosecond
of performance counts.
