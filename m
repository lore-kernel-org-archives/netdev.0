From: Amir Vadai <amirv@mellanox.com>
Subject: Re: [PATCH v2 net-next] mlx4: optimize xmit path
Date: Thu, 2 Oct 2014 11:03:13 +0300
Message-ID: <542D06C1.6090802@mellanox.com>
References: <1411692382-8898-1-git-send-email-ast@plumgrid.com>	 <1411694414.16953.70.camel@edumazet-glaptop2.roam.corp.google.com>	 <1411717322.16953.99.camel@edumazet-glaptop2.roam.corp.google.com>	 <1411850590.15768.6.camel@edumazet-glaptop2.roam.corp.google.com>	 <CAJ3xEMhQCf7j48Yn5sjH6jaYYdLQUgOe2hk-OZhhdZ7taOyx+Q@mail.gmail.com>	 <1411853441.15768.13.camel@edumazet-glaptop2.roam.corp.google.com>	 <1411858593.15768.51.camel@edumazet-glaptop2.roam.corp.google.com>	 <1411964353.30721.6.camel@edumazet-glaptop2.roam.corp.google.com> <1412224524.16704.75.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 8bit
Cc: Alexei Starovoitov <ast@plumgrid.com>,
	"David S. Miller" <davem@davemloft.net>,
	Jesper Dangaard Brouer <brouer@redhat.com>,
	"Eric Dumazet" <edumazet@google.com>,
	John Fastabend <john.r.fastabend@intel.com>,
	Linux Netdev List <netdev@vger.kernel.org>,
	Or Gerlitz <or.gerlitz@gmail.com>, <amira@mellanox.com>,
	<idos@mellanox.com>, "Yevgeny Petrilin" <yevgenyp@mellanox.com>,
	<eyalpe@mellanox.com>
To: Eric Dumazet <eric.dumazet@gmail.com>,
	Or Gerlitz <gerlitz.or@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from eu1sys200aog108.obsmtp.com ([207.126.144.125]:34129 "EHLO
	eu1sys200aog108.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751266AbaJBID7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 2 Oct 2014 04:03:59 -0400
In-Reply-To: <1412224524.16704.75.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 10/2/2014 7:35 AM, Eric Dumazet wrote:
> On Sun, 2014-09-28 at 21:19 -0700, Eric Dumazet wrote:
>> From: Eric Dumazet <edumazet@google.com>
> 

[...]

> Sorry, there is a missing replacement of 
> 
> 	iowrite32be(ring->doorbell_qpn,
> 		    ring->bf.uar->map + MLX4_SEND_DOORBELL);
> 
> by iowrite32(ring->doorbell_qpn,
> 	     ring->bf.uar->map + MLX4_SEND_DOORBELL);
> 
> Since doorbel_qpn was changed to a __be32 and setup in
> mlx4_en_activate_tx_ring()
> 

Hi,

Will take it into the split patchset - we just hit this bug when tried
to run benchmarks with blueflame disabled (easy to test by using ethtool
priv flag blueflame).

I'm still working on it, but I can't reproduce the numbers that you
show. On my development machine, I get ~5.5Mpps with burst=8 and ~2Mpps
with burst=1.

In addition, I see no improvements when adding the optimization to the
xmit path.
I use the net-next kernel + pktgen burst support patch, with and without
this xmit path optimization patch.

Do you use other patches not upstream in your environment?
Can you share the .config/pktgen configuration?

One other note: we're checking now that blueflame could be used with
xmit_more. It might result with packets reordering/drops. Still under
investigation.

Thanks,
Amir
