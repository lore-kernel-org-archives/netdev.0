From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: add per device sg_max_frags for skb
Date: Wed, 13 Jan 2016 10:38:25 -0500 (EST)
Message-ID: <20160113.103825.475570791449704545.davem@davemloft.net>
References: <568FA1E5.7060204@stressinduktion.org>
	<569657D8.1020807@oracle.com>
	<CANn89iJtB1qJCbBWUTXFo2LRWobQe6aDFb_KEWUhBNiZCNpdWA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: hans.westgaard.ry@oracle.com, hannes@stressinduktion.org,
	David.Laight@aculab.com, kuznet@ms2.inr.ac.ru, jmorris@namei.org,
	yoshfuji@linux-ipv6.org, kaber@trash.net, ast@plumgrid.com,
	jiri@mellanox.com, daniel@iogearbox.net, nicolas.dichtel@6wind.com,
	ebiederm@xmission.com, noureddine@arista.com, jarod@redhat.com,
	makita.toshiaki@lab.ntt.co.jp, ja@ssi.bg, ying.xue@windriver.com,
	kraig@google.com, mgorman@techsingularity.net, edjee@google.com,
	julia.lawall@lip6.fr, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, haakon.bugge@oracle.com,
	knut.omang@oracle.com, wei.lin.guay@oracle.com,
	santosh.shilimkar@oracle.com, yuval.shaia@oracle.com
To: edumazet@google.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CANn89iJtB1qJCbBWUTXFo2LRWobQe6aDFb_KEWUhBNiZCNpdWA@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Eric Dumazet <edumazet@google.com>
Date: Wed, 13 Jan 2016 06:19:11 -0800

> 2) TCP stack has coalescing support. write(2) or sendmsg(2) should
> append data into the last skb in write queue, and still use 32 KB
> frags.

Another way to get pathological SKBs is to do lots of tiny sendpage()
calls over discontiguous areas of the file.
