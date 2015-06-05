From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [RFC PATCH net] tcp: Update pcount after skb_pull() during mtu
 probing
Date: Fri, 05 Jun 2015 14:23:55 -0700
Message-ID: <1433539435.1895.60.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1433521014-2465771-1-git-send-email-kafai@fb.com>
	 <CANn89iLd1bqCOxbALcDNzi--Hn8A970HmvM2__ryzjwSbOwZ6Q@mail.gmail.com>
	 <20150605180254.GC2951343@devbig242.prn2.facebook.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Eric Dumazet <edumazet@google.com>,
	netdev <netdev@vger.kernel.org>,
	Kernel Team <kernel-team@fb.com>,
	Neal Cardwell <ncardwell@google.com>,
	Yuchung Cheng <ycheng@google.com>
To: Martin KaFai Lau <kafai@fb.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f182.google.com ([209.85.213.182]:34177 "EHLO
	mail-ig0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752626AbbFEVX5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 5 Jun 2015 17:23:57 -0400
Received: by igbhj9 with SMTP id hj9so24783666igb.1
        for <netdev@vger.kernel.org>; Fri, 05 Jun 2015 14:23:56 -0700 (PDT)
In-Reply-To: <20150605180254.GC2951343@devbig242.prn2.facebook.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2015-06-05 at 11:02 -0700, Martin KaFai Lau wrote:

> tcp_trim_head() does not take the mss_now.
> Is it fine to have mss_now <= tcp_skb_mss(skb)? or we can depend on
> the tcp_init_tso_segs() in the tcp_write_xmit() to take care of it?

It should be fine : packets not yet sent have tcp_skb_pcount()==0,
so that tcp_init_tso_segs() can do the computation at the right time.
