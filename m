From: Jesper Dangaard Brouer <brouer@redhat.com>
Subject: Re: [PATCH RFC 1/3] xdp: Infrastructure to generalize XDP
Date: Thu, 22 Sep 2016 15:14:03 +0200
Message-ID: <20160922151403.24648381@redhat.com>
References: <1474408824-418864-1-git-send-email-tom@herbertland.com>
        <1474408824-418864-2-git-send-email-tom@herbertland.com>
        <20160920224416.GF3291@pox.localdomain>
        <CALx6S36FVU7bNu3JudZuET-VdFND2ZO7n9A7k--qsZVyxTvcpQ@mail.gmail.com>
        <20160920230927.GG3291@pox.localdomain>
        <CALx6S37oniKp1JOeiygzr0RiQojj651ONqBgyvcJvqHj5-aT5g@mail.gmail.com>
        <20160920234347.GH3291@pox.localdomain>
        <CALx6S35LmUtwRA85Kg6s7OR=e5Pj9ssqmWLsjtmXfZTXeG02zQ@mail.gmail.com>
        <20160921115545.GA12789@pox.localdomain>
        <CALx6S35Xctd-aA8DF1_vypMDejiGXcud6=UO33dqgvO60W0DZQ@mail.gmail.com>
        <20160921144800.GB13991@pox.localdomain>
        <CALx6S36ZCdh5iOp6CPfztVKOEkDFgUo1RyqWMJVxhakOYNx8iw@mail.gmail.com>
        <20160921215658.2c61ed5e@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Thomas Graf <tgraf@suug.ch>,
        "David S. Miller" <davem@davemloft.net>,
        Linux Kernel Network Developers <netdev@vger.kernel.org>,
        Kernel Team <kernel-team@fb.com>,
        Tariq Toukan <tariqt@mellanox.com>,
        Brenden Blanco <bblanco@plumgrid.com>,
        Alexei Starovoitov <alexei.starovoitov@gmail.com>,
        Eric Dumazet <eric.dumazet@gmail.com>, brouer@redhat.com
To: Tom Herbert <tom@herbertland.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:36954 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752165AbcIVNOK (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 22 Sep 2016 09:14:10 -0400
In-Reply-To: <20160921215658.2c61ed5e@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 21 Sep 2016 21:56:58 +0200
Jesper Dangaard Brouer <brouer@redhat.com> wrote:

> > > I'm not opposed to running non-BPF code at XDP. I'm against adding
> > > a linked list of hook consumers.  
> 
> I also worry about the performance impact of a linked list.  We should
> simple benchmark it instead of discussing it! ;-)

(Note, there are some stability issue with this RFC patchset, when
removing the xdp program, that I had to workaround/patch)


I've started benchmarking this and I only see added cost of 2.89ns from
these patches, at these crazy speeds it does correspond to -485Kpps.

 I was really expecting to see a higher cost of this approach.

I tested this on two different machines. One was suppose to work with
DDIO, but I could not get DDIO working on that machine (result in max
12.7Mpps drop).  Even-though the mlx5 card does work with DDIO.  Even
removed the mlx5 and used same slot but no luck.   (A side-note: Also
measured a 16ns performance difference between which PCIe slot I'm
using).

The reason I wanted to benchmark this on a DDIO machine is, that I'm
suspecting that the added cost, could be hiding behind the cache miss.

Well, I'm running out-of-time benchmarking this stuff, I must prepare
for my Network Performance Workshop ;-)


(A side-note: my skylake motherboard also had a PCI slot, so I found an
old e1000 NIC in my garage, and it worked!)
-- 
Best regards,
  Jesper Dangaard Brouer
  MSc.CS, Principal Kernel Engineer at Red Hat
  Author of http://www.iptv-analyzer.org
  LinkedIn: http://www.linkedin.com/in/brouer
