From: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Subject: Re: [RFC PATCH 4/5] mlx4: add support for fast rx drop bpf program
Date: Mon, 4 Apr 2016 11:50:12 -0700
Message-ID: <20160404185010.GD68392@ast-mbp.thefacebook.com>
References: <1459560118-5582-1-git-send-email-bblanco@plumgrid.com>
 <1459560118-5582-5-git-send-email-bblanco@plumgrid.com>
 <1459562911.6473.299.camel@edumazet-glaptop3.roam.corp.google.com>
 <20160402024710.GA59703@ast-mbp.thefacebook.com>
 <20160404165701.2a25a17a@redhat.com>
 <1459783323.6473.341.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jesper Dangaard Brouer <brouer@redhat.com>,
	Brenden Blanco <bblanco@plumgrid.com>, davem@davemloft.net,
	netdev@vger.kernel.org, tom@herbertland.com,
	Or Gerlitz <ogerlitz@mellanox.com>, daniel@iogearbox.net,
	john.fastabend@gmail.com
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f174.google.com ([209.85.192.174]:33690 "EHLO
	mail-pf0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754687AbcDDSuQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 4 Apr 2016 14:50:16 -0400
Received: by mail-pf0-f174.google.com with SMTP id 184so49958973pff.0
        for <netdev@vger.kernel.org>; Mon, 04 Apr 2016 11:50:16 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <1459783323.6473.341.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Apr 04, 2016 at 08:22:03AM -0700, Eric Dumazet wrote:
> On Mon, 2016-04-04 at 16:57 +0200, Jesper Dangaard Brouer wrote:
> > On Fri, 1 Apr 2016 19:47:12 -0700 Alexei Starovoitov <alexei.starovoitov@gmail.com> wrote:
> > 
> > > My guess we're hitting 14.5Mpps limit for empty bpf program
> > > and for program that actually looks into the packet because we're
> > > hitting 10G phy limit of 40G nic. Since physically 40G nic
> > > consists of four 10G phys. There will be the same problem
> > > with 100G and 50G nics. Both will be hitting 25G phy limit.
> > > We need to vary packets somehow. Hopefully Or can explain that
> > > bit of hw design.
> > > Jesper's experiments with mlx4 showed the same 14.5Mpps limit
> > > when sender blasting the same packet over and over again.
> > 
> > That is an interesting observation Alexei, and could explain the pps limit
> > I hit on 40G, with single flow testing.  AFAIK 40G is 4x 10G PHYs, and
> > 100G is 4x 25G PHYs.
> > 
> > I have a pktgen script that tried to avoid this pitfall.  By creating a
> > new flow per pktgen kthread. I call it "pktgen_sample05_flow_per_thread.sh"[1]
> > 
> > [1] https://github.com/netoptimizer/network-testing/blob/master/pktgen/pktgen_sample05_flow_per_thread.sh
> > 
> 
> A single flow is able to use 40Gbit on those 40Gbit NIC, so there is not
> a single 10GB trunk used for a given flow.
> 
> This 14Mpps thing seems to be a queue limitation on mlx4.

yeah, could be queueing related.
Multiple cpus can send ~30Mpps of the same 64 byte packet,
but mlx4 can only receive 14.5Mpps. Odd.

Or (and other mellanox guys),
what is really going on inside 40G nic ?
