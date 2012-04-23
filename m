From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH 2/2 net-next] tcp: sk_add_backlog() is too agressive
 for TCP
Date: Mon, 23 Apr 2012 19:23:15 +0200
Message-ID: <1335201795.5205.35.camel@edumazet-glaptop>
References: <1335173934.3293.84.camel@edumazet-glaptop>
	 <4F958DFD.7010207@hp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	Tom Herbert <therbert@google.com>,
	Neal Cardwell <ncardwell@google.com>,
	Maciej =?UTF-8?Q?=C5=BBenczykowski?= <maze@google.com>,
	Yuchung Cheng <ycheng@google.com>,
	Ilpo =?ISO-8859-1?Q?J=E4rvinen?= <ilpo.jarvinen@helsinki.fi>
To: Rick Jones <rick.jones2@hp.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bk0-f46.google.com ([209.85.214.46]:41700 "EHLO
	mail-bk0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752619Ab2DWRXy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 23 Apr 2012 13:23:54 -0400
Received: by bkcik5 with SMTP id ik5so8845859bkc.19
        for <netdev@vger.kernel.org>; Mon, 23 Apr 2012 10:23:52 -0700 (PDT)
In-Reply-To: <4F958DFD.7010207@hp.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2012-04-23 at 10:14 -0700, Rick Jones wrote:

> 
> This will increase what can be queued for arriving segments in general 
> and not for ACKs specifically yes?  (A possible issue that would have 
> come-up with my previous wondering about just increasing SO_RCVBUF as 
> SO_SNDBUF was increasing).  Perhaps only add sk->sk_sndbuf to the limit 
> if the arriving segment contains no data?

Thats the backlog limit that we tweak here.

Its not a big deal if we allow a bit more packets to come and later drop
them if we hit the real rcvbuf limit. (ACKS wont consume space, since
they are freed as soon as processed)

By the way, we used to have (sk_rcvbuf << 1) limit in the past.

Before commit c377411f2494a931ff we had :

if (sk->sk_backlog.len >= max(sk->sk_backlog.limit, sk->sk_rcvbuf << 1)) 
	return -ENOBUFS

We probably had drops in the past but didnt notice, since we lacked 
a counter for those drops.
