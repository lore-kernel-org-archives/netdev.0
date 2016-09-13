From: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Subject: Re: [net-next PATCH v3 2/3] e1000: add initial XDP support
Date: Tue, 13 Sep 2016 10:59:28 -0700
Message-ID: <20160913175926.GA38737@ast-mbp.thefacebook.com>
References: <20160912220312.5610.77528.stgit@john-Precision-Tower-5810>
 <20160912221351.5610.29043.stgit@john-Precision-Tower-5810>
 <1473720399.18970.91.camel@edumazet-glaptop3.roam.corp.google.com>
 <20160912230745.GA24171@ast-mbp.thefacebook.com>
 <1473723968.18970.111.camel@edumazet-glaptop3.roam.corp.google.com>
 <CALx6S35CE+ZYbGm96Y5YKnTqU0zfhg9_h0VSpD3ot8xB-scdFQ@mail.gmail.com>
 <20160913012815.GB25756@ast-mbp.thefacebook.com>
 <CALx6S36u+tQUEVhu0BaLZ6-_0=GSMwxd4m89-H+brVZ-rr-U2g@mail.gmail.com>
 <20160913171340.GA37341@ast-mbp.thefacebook.com>
 <1473788252.18970.177.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Tom Herbert <tom@herbertland.com>,
        John Fastabend <john.fastabend@gmail.com>,
        Brenden Blanco <bblanco@plumgrid.com>,
        Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
        Jesper Dangaard Brouer <brouer@redhat.com>,
        "David S. Miller" <davem@davemloft.net>,
        Cong Wang <xiyou.wangcong@gmail.com>,
        intel-wired-lan <intel-wired-lan@lists.osuosl.org>,
        William Tu <u9012063@gmail.com>,
        Linux Kernel Network Developers <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f196.google.com ([209.85.192.196]:35951 "EHLO
        mail-pf0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1756134AbcIMR7e (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 13 Sep 2016 13:59:34 -0400
Received: by mail-pf0-f196.google.com with SMTP id n24so98217pfb.3
        for <netdev@vger.kernel.org>; Tue, 13 Sep 2016 10:59:34 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <1473788252.18970.177.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Sep 13, 2016 at 10:37:32AM -0700, Eric Dumazet wrote:
> On Tue, 2016-09-13 at 10:13 -0700, Alexei Starovoitov wrote:
> 
> > I'm afraid the point 'only for debugging' still didn't make it across.
> > xdp+e1k is for development (and debugging) of xdp-type of bpf
> > programs and _not_ for debugging of xdp itself, kernel or anything else.
> > The e1k provided interfaces and behavior needs to match exactly
> > what real hw nics (like mlx4, mlx5, igxbe, i40e) will do.
> > Doing special hacks are not acceptable. Therefore your
> > 'proposed fix' misses the mark, since:
> > 1. ignoring bql/qdisc is not a bug, but the requirement
> > 2. such 'fix' goes against the goal above since behaviors will be
> > different and xdp developer won't be able to build something like
> > xdp loadbalancer in the kvm.
> > 
> 
> 
> Is e1k the only way a VM can receive and send packets ?
> 
> Instead of adding more cruft to a legacy driver, risking breaking real
> old machines, 

agree that it is the concern.

> I am sure we can find modern alternative.

I've looked through qemu and it appears only emulate e1k and tg3.
The latter is still used in the field, so the risk of touching
it is higher.
The other alternative is virtio, but it doesn't have dma and/or pages,
so it looks to me even messier hack.
The last alternative considered was to invent xdp-only fake 'hw' nic,
but it's too much work to get it into qemu then ask the world
to upgrade qemu.
At that point I ran out of ideas and settled on hacking e1k :(
Not proud of this hack at all.
