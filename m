From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH v2 net-next] mlx4: optimize xmit path
Date: Thu, 02 Oct 2014 05:07:00 -0700
Message-ID: <1412251620.16704.88.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1411692382-8898-1-git-send-email-ast@plumgrid.com>
			 <1411694414.16953.70.camel@edumazet-glaptop2.roam.corp.google.com>
			 <1411717322.16953.99.camel@edumazet-glaptop2.roam.corp.google.com>
			 <1411850590.15768.6.camel@edumazet-glaptop2.roam.corp.google.com>
			 <CAJ3xEMhQCf7j48Yn5sjH6jaYYdLQUgOe2hk-OZhhdZ7taOyx+Q@mail.gmail.com>
			 <1411853441.15768.13.camel@edumazet-glaptop2.roam.corp.google.com>
			 <1411858593.15768.51.camel@edumazet-glaptop2.roam.corp.google.com>
			 <1411964353.30721.6.camel@edumazet-glaptop2.roam.corp.google.com>
		 <1412224524.16704.75.camel@edumazet-glaptop2.roam.corp.google.com>
		 <542D06C1.6090802@mellanox.com>
	 <1412250327.16704.84.camel@edumazet-glaptop2.roam.corp.google.com>
	 <542D3D5F.5090900@mellanox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Or Gerlitz <gerlitz.or@gmail.com>,
	Alexei Starovoitov <ast@plumgrid.com>,
	"David S. Miller" <davem@davemloft.net>,
	Jesper Dangaard Brouer <brouer@redhat.com>,
	Eric Dumazet <edumazet@google.com>,
	John Fastabend <john.r.fastabend@intel.com>,
	Linux Netdev List <netdev@vger.kernel.org>,
	Or Gerlitz <or.gerlitz@gmail.com>, amira@mellanox.com,
	idos@mellanox.com, Yevgeny Petrilin <yevgenyp@mellanox.com>,
	eyalpe@mellanox.com
To: Amir Vadai <amirv@mellanox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f51.google.com ([209.85.220.51]:55987 "EHLO
	mail-pa0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751507AbaJBMHD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 2 Oct 2014 08:07:03 -0400
Received: by mail-pa0-f51.google.com with SMTP id lj1so2197181pab.24
        for <netdev@vger.kernel.org>; Thu, 02 Oct 2014 05:07:02 -0700 (PDT)
In-Reply-To: <542D3D5F.5090900@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2014-10-02 at 14:56 +0300, Amir Vadai wrote:
> After making sure the sender thread and the TX completions are not on
> the same CPU, I see the expected improvement. +0.5Mpps with tx
> optimizations.

I got 40% here.

Hmm... both cpus are on the same socket, right ?

TX coalescing is properly setup ?

What interrupt rate do you get ?

You can take a look at where cycles are spent

perf record -a -g sleep 5
perf report
