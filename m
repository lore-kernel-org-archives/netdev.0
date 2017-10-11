From: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Subject: Re: [Patch net-next] tcp: add a tracepoint for tcp_retransmit_skb()
Date: Wed, 11 Oct 2017 11:21:15 -0700
Message-ID: <20171011182113.rdxgrebygmiijpqs@ast-mbp>
References: <20171010053547.21162-1-xiyou.wangcong@gmail.com>
 <20171010173821.6djxyvrggvaivqec@ast-mbp.dhcp.thefacebook.com>
 <87po9ull5u.fsf@stressinduktion.org>
 <20171011025606.tzts5wgys5hn52p2@ast-mbp>
 <1507728705.31614.24.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Hannes Frederic Sowa <hannes@stressinduktion.org>,
        Cong Wang <xiyou.wangcong@gmail.com>, netdev@vger.kernel.org,
        Eric Dumazet <edumazet@google.com>,
        Yuchung Cheng <ycheng@google.com>,
        Neal Cardwell <ncardwell@google.com>,
        Martin KaFai Lau <kafai@fb.com>,
        Brendan Gregg <brendan.d.gregg@gmail.com>,
        Song Liu <songliubraving@fb.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f193.google.com ([209.85.192.193]:36237 "EHLO
        mail-pf0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1757508AbdJKSVT (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 11 Oct 2017 14:21:19 -0400
Received: by mail-pf0-f193.google.com with SMTP id z11so2939111pfk.3
        for <netdev@vger.kernel.org>; Wed, 11 Oct 2017 11:21:19 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <1507728705.31614.24.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Oct 11, 2017 at 06:31:45AM -0700, Eric Dumazet wrote:
> On Tue, 2017-10-10 at 19:56 -0700, Alexei Starovoitov wrote:
> 
> > actually we hit that too for completely different tracing use case.
> > Indeed would be good to generate socket cookie unconditionally
> > for all sockets. I don't think there is any harm.
> > 
> 
> Simply call sock_gen_cookie() when needed.
> 
> If a tracepoint needs the cookie and the cookie was not yet generated,
> it will be generated at this point.

we already have bpf_get_socket_cookie() that will call it,
but this helper is for bpf socket filters, clsact and other
networking related prog types, whereas all of tracing is
read-only and side-effect-free, so we cannot use
bpf_get_socket_cookie() there.
Hence for tracing in kprobe-bpf we use raw sk pointer
as map key and full tuple when passing the socket info to user
space. If we could use socket cookie vs full tuple it would
make a nice difference.
