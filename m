From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [RFC PATCH 4/5] mlx4: add support for fast rx drop bpf program
Date: Mon, 04 Apr 2016 08:22:03 -0700
Message-ID: <1459783323.6473.341.camel@edumazet-glaptop3.roam.corp.google.com>
References: <1459560118-5582-1-git-send-email-bblanco@plumgrid.com>
	 <1459560118-5582-5-git-send-email-bblanco@plumgrid.com>
	 <1459562911.6473.299.camel@edumazet-glaptop3.roam.corp.google.com>
	 <20160402024710.GA59703@ast-mbp.thefacebook.com>
	 <20160404165701.2a25a17a@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Alexei Starovoitov <alexei.starovoitov@gmail.com>,
	Brenden Blanco <bblanco@plumgrid.com>, davem@davemloft.net,
	netdev@vger.kernel.org, tom@herbertland.com,
	Or Gerlitz <ogerlitz@mellanox.com>, daniel@iogearbox.net,
	john.fastabend@gmail.com
To: Jesper Dangaard Brouer <brouer@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f48.google.com ([209.85.220.48]:34418 "EHLO
	mail-pa0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755557AbcDDPWG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 4 Apr 2016 11:22:06 -0400
Received: by mail-pa0-f48.google.com with SMTP id fe3so146292962pab.1
        for <netdev@vger.kernel.org>; Mon, 04 Apr 2016 08:22:06 -0700 (PDT)
In-Reply-To: <20160404165701.2a25a17a@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2016-04-04 at 16:57 +0200, Jesper Dangaard Brouer wrote:
> On Fri, 1 Apr 2016 19:47:12 -0700 Alexei Starovoitov <alexei.starovoitov@gmail.com> wrote:
> 
> > My guess we're hitting 14.5Mpps limit for empty bpf program
> > and for program that actually looks into the packet because we're
> > hitting 10G phy limit of 40G nic. Since physically 40G nic
> > consists of four 10G phys. There will be the same problem
> > with 100G and 50G nics. Both will be hitting 25G phy limit.
> > We need to vary packets somehow. Hopefully Or can explain that
> > bit of hw design.
> > Jesper's experiments with mlx4 showed the same 14.5Mpps limit
> > when sender blasting the same packet over and over again.
> 
> That is an interesting observation Alexei, and could explain the pps limit
> I hit on 40G, with single flow testing.  AFAIK 40G is 4x 10G PHYs, and
> 100G is 4x 25G PHYs.
> 
> I have a pktgen script that tried to avoid this pitfall.  By creating a
> new flow per pktgen kthread. I call it "pktgen_sample05_flow_per_thread.sh"[1]
> 
> [1] https://github.com/netoptimizer/network-testing/blob/master/pktgen/pktgen_sample05_flow_per_thread.sh
> 

A single flow is able to use 40Gbit on those 40Gbit NIC, so there is not
a single 10GB trunk used for a given flow.

This 14Mpps thing seems to be a queue limitation on mlx4.
