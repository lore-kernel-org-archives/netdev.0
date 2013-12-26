From: Timo Teras <timo.teras@iki.fi>
Subject: net: Loosen constraints for recalculating checksum in skb_segment()
Date: Thu, 26 Dec 2013 09:18:51 +0200
Message-ID: <20131226091851.463bd189@vostro>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Simon Horman <horms@verge.net.au>, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-la0-f41.google.com ([209.85.215.41]:42817 "EHLO
	mail-la0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751353Ab3LZHSt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 26 Dec 2013 02:18:49 -0500
Received: by mail-la0-f41.google.com with SMTP id eo20so3634200lab.0
        for <netdev@vger.kernel.org>; Wed, 25 Dec 2013 23:18:48 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

commit 1cdbcb7957cf9e5f841dbcde9b38fd18a804208b
Author: Simon Horman <horms@verge.net.au>
Date:   Sun May 19 15:46:49 2013 +0000

> net: Loosen constraints for recalculating checksum in skb_segment()
>
> This is a generic solution to resolve a specific problem that I have
> observed.
> 
> If the encapsulation of an skb changes then ability to offload
> checksums may also change. In particular it may be necessary to
> perform checksumming in software.
> 
> An example of such a case is where a non-GRE packet is received but
> is to be encapsulated and transmitted as GRE.

Dave, can you queue this for 3.10-stable.

It was around 3.9 when ip_gre got gso support. This added the bug that
forwarding non-gre to gre with gro+gso+tx offloads enabled does not
work properly - the TCP checksums are not calculated properly without
this patch.

Thanks,
 Timo
