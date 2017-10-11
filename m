From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [Patch net-next] tcp: add a tracepoint for tcp_retransmit_skb()
Date: Wed, 11 Oct 2017 11:38:15 -0700
Message-ID: <1507747095.31614.26.camel@edumazet-glaptop3.roam.corp.google.com>
References: <20171010053547.21162-1-xiyou.wangcong@gmail.com>
         <20171010173821.6djxyvrggvaivqec@ast-mbp.dhcp.thefacebook.com>
         <87po9ull5u.fsf@stressinduktion.org>
         <20171011025606.tzts5wgys5hn52p2@ast-mbp>
         <1507728705.31614.24.camel@edumazet-glaptop3.roam.corp.google.com>
         <20171011182113.rdxgrebygmiijpqs@ast-mbp>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Hannes Frederic Sowa <hannes@stressinduktion.org>,
        Cong Wang <xiyou.wangcong@gmail.com>, netdev@vger.kernel.org,
        Eric Dumazet <edumazet@google.com>,
        Yuchung Cheng <ycheng@google.com>,
        Neal Cardwell <ncardwell@google.com>,
        Martin KaFai Lau <kafai@fb.com>,
        Brendan Gregg <brendan.d.gregg@gmail.com>,
        Song Liu <songliubraving@fb.com>
To: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f195.google.com ([209.85.192.195]:51580 "EHLO
        mail-pf0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752094AbdJKSiQ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 11 Oct 2017 14:38:16 -0400
Received: by mail-pf0-f195.google.com with SMTP id n14so1591373pfh.8
        for <netdev@vger.kernel.org>; Wed, 11 Oct 2017 11:38:16 -0700 (PDT)
In-Reply-To: <20171011182113.rdxgrebygmiijpqs@ast-mbp>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2017-10-11 at 11:21 -0700, Alexei Starovoitov wrote:
> On Wed, Oct 11, 2017 at 06:31:45AM -0700, Eric Dumazet wrote:
> > On Tue, 2017-10-10 at 19:56 -0700, Alexei Starovoitov wrote:
> > 
> > > actually we hit that too for completely different tracing use case.
> > > Indeed would be good to generate socket cookie unconditionally
> > > for all sockets. I don't think there is any harm.
> > > 
> > 
> > Simply call sock_gen_cookie() when needed.
> > 
> > If a tracepoint needs the cookie and the cookie was not yet generated,
> > it will be generated at this point.
> 
> we already have bpf_get_socket_cookie() that will call it,
> but this helper is for bpf socket filters, clsact and other
> networking related prog types, whereas all of tracing is
> read-only and side-effect-free, so we cannot use
> bpf_get_socket_cookie() there.
> Hence for tracing in kprobe-bpf we use raw sk pointer
> as map key and full tuple when passing the socket info to user
> space. If we could use socket cookie vs full tuple it would
> make a nice difference.

Since this sock_gen_cookie() is lock-free and IRQ ready, it should be
not be a problem to pretend it works with a const socket.

I am a bit unsure about revealing in socket cookie a precise count of
sockets created on a netns. Some attackers might use this in a side
channel attack.
