From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: RE: [PATCH v2 net-next] af_unix: fix a fatal race with bit fields
Date: Wed, 01 May 2013 09:00:59 -0700
Message-ID: <1367424059.11020.61.camel@edumazet-glaptop>
References: <1367370761.11020.22.camel@edumazet-glaptop>
	 <1367372393.22115.6.camel@pasglop>
	 <20130501.033650.703182794549888825.davem@davemloft.net>
	 <1367421843.11020.43.camel@edumazet-glaptop>
	 <AE90C24D6B3A694183C094C60CF0A2F6026B721C@saturn3.aculab.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, benh@kernel.crashing.org,
	netdev@vger.kernel.org, paulus@samba.org, ambrose@google.com,
	linuxppc-dev@lists.ozlabs.org
To: David Laight <David.Laight@ACULAB.COM>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-da0-f44.google.com ([209.85.210.44]:49899 "EHLO
	mail-da0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932361Ab3EAQBE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 1 May 2013 12:01:04 -0400
Received: by mail-da0-f44.google.com with SMTP id z20so722673dae.3
        for <netdev@vger.kernel.org>; Wed, 01 May 2013 09:01:03 -0700 (PDT)
In-Reply-To: <AE90C24D6B3A694183C094C60CF0A2F6026B721C@saturn3.aculab.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2013-05-01 at 16:53 +0100, David Laight wrote:
> Why not just change gc_candidate and gc_maybe_cycle to
> unsigned char?
> It might reduce the number of pad bytes somewhat.

You didn't quite follow the discussion.

I used bytes on V1, and we are not 100% sure its safe on all arches.

unsigned long is guaranteed to be safe. We absolutely rely on this.

Better use more bytes on a socket (with no impact on real memory use),
than spending hours to debug some strange issues.
