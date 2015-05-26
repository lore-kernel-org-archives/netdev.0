From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH v2 net-next 1/3] net: Add cache alignment in sock_common
 for socket lookup fields
Date: Tue, 26 May 2015 10:54:43 -0700
Message-ID: <1432662883.4060.279.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1432658049-3400132-1-git-send-email-tom@herbertland.com>
	 <1432658049-3400132-2-git-send-email-tom@herbertland.com>
	 <1432660758.4060.276.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: Tom Herbert <tom@herbertland.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f169.google.com ([209.85.223.169]:34655 "EHLO
	mail-ie0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752852AbbEZRyp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 26 May 2015 13:54:45 -0400
Received: by ieczm2 with SMTP id zm2so98191481iec.1
        for <netdev@vger.kernel.org>; Tue, 26 May 2015 10:54:44 -0700 (PDT)
In-Reply-To: <1432660758.4060.276.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2015-05-26 at 10:19 -0700, Eric Dumazet wrote:

> No, we do not want to increase the size of sock_common with such a
> hammer.

Current sizeof(struct sock_common) is 0x78 bytes.

So moving 2 read_mostly pointers into this structure would be enough to
make 2 first cache lines read mostly.

One candidate would be sk_rx_dst, as it is used in early demux.
