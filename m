From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [Patch net-next] tcp: add a tracepoint for tcp_retransmit_skb()
Date: Thu, 12 Oct 2017 11:39:57 +0200
Message-ID: <87a80wd7rm.fsf@stressinduktion.org>
References: <20171010053547.21162-1-xiyou.wangcong@gmail.com>
        <20171010173821.6djxyvrggvaivqec@ast-mbp.dhcp.thefacebook.com>
        <87po9ull5u.fsf@stressinduktion.org>
        <20171011025606.tzts5wgys5hn52p2@ast-mbp>
        <1507728705.31614.24.camel@edumazet-glaptop3.roam.corp.google.com>
        <20171011182113.rdxgrebygmiijpqs@ast-mbp>
        <1507747095.31614.26.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Alexei Starovoitov <alexei.starovoitov@gmail.com>,
        Cong Wang <xiyou.wangcong@gmail.com>, netdev@vger.kernel.org,
        Eric Dumazet <edumazet@google.com>,
        Yuchung Cheng <ycheng@google.com>,
        Neal Cardwell <ncardwell@google.com>,
        Martin KaFai Lau <kafai@fb.com>,
        Brendan Gregg <brendan.d.gregg@gmail.com>,
        Song Liu <songliubraving@fb.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out1-smtp.messagingengine.com ([66.111.4.25]:35175 "EHLO
        out1-smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1755917AbdJLJkC (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 12 Oct 2017 05:40:02 -0400
In-Reply-To: <1507747095.31614.26.camel@edumazet-glaptop3.roam.corp.google.com>
        (Eric Dumazet's message of "Wed, 11 Oct 2017 11:38:15 -0700")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Eric Dumazet <eric.dumazet@gmail.com> writes:

[...]

> Since this sock_gen_cookie() is lock-free and IRQ ready, it should be
> not be a problem to pretend it works with a const socket.
>
> I am a bit unsure about revealing in socket cookie a precise count of
> sockets created on a netns. Some attackers might use this in a side
> channel attack.

That is true. We expose this information already via the inode number
allocator for sockets. It is a bit imprecise because of using CPU
batches.
