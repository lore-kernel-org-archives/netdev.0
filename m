From: Jesper Dangaard Brouer <brouer@redhat.com>
Subject: Re: [RFC PATCH 4/5] mlx4: add support for fast rx drop bpf program
Date: Mon, 4 Apr 2016 16:57:01 +0200
Message-ID: <20160404165701.2a25a17a@redhat.com>
References: <1459560118-5582-1-git-send-email-bblanco@plumgrid.com>
	<1459560118-5582-5-git-send-email-bblanco@plumgrid.com>
	<1459562911.6473.299.camel@edumazet-glaptop3.roam.corp.google.com>
	<20160402024710.GA59703@ast-mbp.thefacebook.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	Brenden Blanco <bblanco@plumgrid.com>, davem@davemloft.net,
	netdev@vger.kernel.org, tom@herbertland.com,
	Or Gerlitz <ogerlitz@mellanox.com>, daniel@iogearbox.net,
	john.fastabend@gmail.com, brouer@redhat.com
To: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:55892 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751746AbcDDO5H (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 4 Apr 2016 10:57:07 -0400
In-Reply-To: <20160402024710.GA59703@ast-mbp.thefacebook.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


On Fri, 1 Apr 2016 19:47:12 -0700 Alexei Starovoitov <alexei.starovoitov@gmail.com> wrote:

> My guess we're hitting 14.5Mpps limit for empty bpf program
> and for program that actually looks into the packet because we're
> hitting 10G phy limit of 40G nic. Since physically 40G nic
> consists of four 10G phys. There will be the same problem
> with 100G and 50G nics. Both will be hitting 25G phy limit.
> We need to vary packets somehow. Hopefully Or can explain that
> bit of hw design.
> Jesper's experiments with mlx4 showed the same 14.5Mpps limit
> when sender blasting the same packet over and over again.

That is an interesting observation Alexei, and could explain the pps limit
I hit on 40G, with single flow testing.  AFAIK 40G is 4x 10G PHYs, and
100G is 4x 25G PHYs.

I have a pktgen script that tried to avoid this pitfall.  By creating a
new flow per pktgen kthread. I call it "pktgen_sample05_flow_per_thread.sh"[1]

[1] https://github.com/netoptimizer/network-testing/blob/master/pktgen/pktgen_sample05_flow_per_thread.sh

-- 
Best regards,
  Jesper Dangaard Brouer
  MSc.CS, Principal Kernel Engineer at Red Hat
  Author of http://www.iptv-analyzer.org
  LinkedIn: http://www.linkedin.com/in/brouer
