From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next] soreuseport: pass skb to secondary UDP socket
 lookup
Date: Tue, 05 Jan 2016 13:58:10 -0800
Message-ID: <1452031090.8255.120.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1452024487-2909-1-git-send-email-kraigatgoog@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, David Miller <davem@davemloft.net>
To: Craig Gallek <kraigatgoog@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f47.google.com ([209.85.220.47]:35201 "EHLO
	mail-pa0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751864AbcAEV6N (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 Jan 2016 16:58:13 -0500
Received: by mail-pa0-f47.google.com with SMTP id do7so2775709pab.2
        for <netdev@vger.kernel.org>; Tue, 05 Jan 2016 13:58:12 -0800 (PST)
In-Reply-To: <1452024487-2909-1-git-send-email-kraigatgoog@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2016-01-05 at 15:08 -0500, Craig Gallek wrote:
> From: Craig Gallek <kraig@google.com>
> 
> This socket-lookup path did not pass along the skb in question
> in my original BPF-based socket selection patch.  The skb in the
> udpN_lib_lookup2 path can be used for BPF-based socket selection just
> like it is in the 'traditional' udpN_lib_lookup path.
> 
> udpN_lib_lookup2 kicks in when there are greater than 10 sockets in
> the same hlist slot.  Coincidentally, I chose 10 sockets per
> reuseport group in my functional test, so the lookup2 path was not
> excersised. This adds an additional set of tests with 20 sockets.
> 
> Fixes: 538950a1b752 ("soreuseport: setsockopt SO_ATTACH_REUSEPORT_[CE]BPF")
> Fixes: 3ca8e4029969 ("soreuseport: BPF selection functional test")
> Suggested-by: Eric Dumazet <eric.dumazet@gmail.com>
> Signed-off-by: Craig Gallek <kraig@google.com>
> ---

Great. I'll send the patch to fix udp_dump_one() so that we can remove
the test against skb in fast path.

Acked-by: Eric Dumazet <edumazet@google.com>
