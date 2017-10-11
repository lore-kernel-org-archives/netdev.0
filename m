From: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Subject: Re: [Patch net-next] tcp: add a tracepoint for tcp_retransmit_skb()
Date: Tue, 10 Oct 2017 19:53:41 -0700
Message-ID: <20171011025339.yhhktwuhv7xdbiew@ast-mbp>
References: <20171010053547.21162-1-xiyou.wangcong@gmail.com>
 <20171010173821.6djxyvrggvaivqec@ast-mbp.dhcp.thefacebook.com>
 <CAM_iQpU9TAU-SbjTyfp3xZUjpdrz=WWobHiAhoZ2zeF0oonYXg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Linux Kernel Network Developers <netdev@vger.kernel.org>,
        Eric Dumazet <edumazet@google.com>,
        Yuchung Cheng <ycheng@google.com>,
        Neal Cardwell <ncardwell@google.com>,
        Martin KaFai Lau <kafai@fb.com>,
        Brendan Gregg <brendan.d.gregg@gmail.com>,
        Hannes Frederic Sowa <hannes@stressinduktion.org>,
        Song Liu <songliubraving@fb.com>
To: Cong Wang <xiyou.wangcong@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f54.google.com ([74.125.83.54]:52643 "EHLO
        mail-pg0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752099AbdJKCxp (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 10 Oct 2017 22:53:45 -0400
Received: by mail-pg0-f54.google.com with SMTP id w9so243492pgo.9
        for <netdev@vger.kernel.org>; Tue, 10 Oct 2017 19:53:45 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <CAM_iQpU9TAU-SbjTyfp3xZUjpdrz=WWobHiAhoZ2zeF0oonYXg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Oct 10, 2017 at 02:37:11PM -0700, Cong Wang wrote:
> >
> > More concrete, if you can make this trace_tcp_retransmit_skb() to record
> > sk, skb pointers and err code at the end of __tcp_retransmit_skb() it will solve
> > our need as well.
> 
> 
> Note, currently I only call trace_tcp_retransmit_skb() for successful
> retransmissions, since you mentioned err code, I guess you want it
> for failures too? I am not sure if tracing unsuccessful TCP retransmissions
> is meaningful here, I guess it's needed for BPF to track TCP states?
>
> It doesn't harm to add it, at least we can filter out err!=0 since we
> only care about successful ones.

right now only successful rxmit would be enough for us.
Only that 'err' is hard to do via kprobe, since it's in some random
register and debug info is generally not available.
If you want to drop err for now and call tracepoint only
on success, I think, that's fine too. Need to double check.
Only sk and skb pointers are must have.

Thanks!
