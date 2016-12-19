From: Julian Anastasov <ja@ssi.bg>
Subject: Re: [PATCH RFC net-next 2/7] net: add dst_pending_confirm flag to
 skbuff
Date: Mon, 19 Dec 2016 22:37:50 +0200 (EET)
Message-ID: <alpine.LFD.2.11.1612192203480.3105@ja.home.ssi.bg>
References: <1482094596-26046-1-git-send-email-ja@ssi.bg>  <1482094596-26046-3-git-send-email-ja@ssi.bg> <1482164252.1521.7.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev@vger.kernel.org, linux-sctp@vger.kernel.org,
        YueHaibing <yuehaibing@huawei.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ja.ssi.bg ([178.16.129.10]:56848 "EHLO ja.ssi.bg"
        rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
        id S1753134AbcLSUiJ (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 19 Dec 2016 15:38:09 -0500
In-Reply-To: <1482164252.1521.7.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


	Hello,

On Mon, 19 Dec 2016, Eric Dumazet wrote:

> I am still digesting this awesome patch series ;)

	Thanks. I don't feel quite comfortable with some
of the changes (mostly XFRM, dst_confirm usage in CXGB) and
I hope the discussion can provide adequate solution.

> Not sure why you used an unlikely() here. TCP for example would hit this
> path quite often.

	I was not sure, may be because ACKs can come with lower
rate than the sent packets. Also because non-TCP rarely uses
MSG_CONFIRM. If you still think it is better without unlikely,
I'll remove it.

> So considering sk_dst_pending_confirm might be dirtied quite often,
> 
> I am not sure why you placed it in the cache line that contains
> sk_rx_dst (in 1st patch)

	I saw your recent changes and was worried if the
sk_dst_confirm() calling on RX can cause unwanted dirtying of
additional cache line. My preliminary analyze pointed
sk_omem_alloc as good candidate for moving to next cache
line. I know how critical is to properly place the new flags,
so I really need recommendations about this.

Regards
