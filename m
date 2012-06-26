From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH v2 net-next] tcp: avoid tx starvation by SYNACK packets
Date: Tue, 26 Jun 2012 19:02:36 +0200
Message-ID: <1340730156.10893.359.camel@edumazet-glaptop>
References: <1340440962.17495.39.camel@edumazet-glaptop>
	 <1340686296.10893.115.camel@edumazet-glaptop>
	 <20120625.215537.169465424900682764.davem@davemloft.net>
	 <201206260734.33472.hans.schillstrom@ericsson.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	"subramanian.vijay@gmail.com" <subramanian.vijay@gmail.com>,
	"dave.taht@gmail.com" <dave.taht@gmail.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"ncardwell@google.com" <ncardwell@google.com>,
	"therbert@google.com" <therbert@google.com>,
	"brouer@redhat.com" <brouer@redhat.com>
To: Hans Schillstrom <hans.schillstrom@ericsson.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bk0-f46.google.com ([209.85.214.46]:46383 "EHLO
	mail-bk0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758742Ab2FZRCm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 26 Jun 2012 13:02:42 -0400
Received: by bkcji2 with SMTP id ji2so147176bkc.19
        for <netdev@vger.kernel.org>; Tue, 26 Jun 2012 10:02:41 -0700 (PDT)
In-Reply-To: <201206260734.33472.hans.schillstrom@ericsson.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2012-06-26 at 07:34 +0200, Hans Schillstrom wrote:

> This patch didn't give much in gain actually.

With a 100Mbps link it does.

With a 1Gbps link we are cpu bounded for sure.

> The big cycle consumer during a syn attack is SHA sum right now, 
> so from that perspective it's better to add aes crypto (by using AES-NI) 
> to the syn cookies instead of SHA sum. Even if only newer x86_64 can use it.

My dev machine is able to process ~280.000 SYN (and synack) per second
(tg3, mono queue), and sha_transform() takes ~10 % of the time according
to perf.

With David patch using jhash instead of SHA, I reach ~315.000 SYN per
second.
