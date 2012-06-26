From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] ipv4: Remove unnecessary code from rt_check_expire().
Date: Tue, 26 Jun 2012 09:39:58 +0200
Message-ID: <1340696398.10893.209.camel@edumazet-glaptop>
References: <20120626.002124.2220875506847485306.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bk0-f46.google.com ([209.85.214.46]:48073 "EHLO
	mail-bk0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753804Ab2FZHkD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 26 Jun 2012 03:40:03 -0400
Received: by bkcji2 with SMTP id ji2so3874620bkc.19
        for <netdev@vger.kernel.org>; Tue, 26 Jun 2012 00:40:02 -0700 (PDT)
In-Reply-To: <20120626.002124.2220875506847485306.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2012-06-26 at 00:21 -0700, David Miller wrote:
> IPv4 routing cache entries no longer use dst->expires, because the
> metrics, PMTU, and redirect information are stored in the inetpeer
> cache.
> 
> Signed-off-by: David S. Miller <davem@davemloft.net>
> ---
> 
> Eric, when you did commit 9f28a2fc0bd77511f649c0a788c7bf9a5fd04edb
> (ipv4: reintroduce route cache garbage collector) do you remember
> if the thing we needed was the real expiry or both the
> rt_is_expired() and the rt_may_expire() cases?
> 
> I really want to remove rt_may_expire() from this conditional because
> it results in absolutely stupid behavior.  If your system is idle
> for 5 minutes, all of your input routing cache entries are purged.

Hmm, after a DDOS, purging all those routing cache entries in 5 minutes
is good to recover some Mbytes of kernel memory.
