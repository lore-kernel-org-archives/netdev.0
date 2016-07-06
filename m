From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] ipv6: Fix soft lockup for ipv6 network notifier.
Date: Wed, 06 Jul 2016 10:44:04 +0200
Message-ID: <1467794644.1273.17.camel@edumazet-glaptop3.roam.corp.google.com>
References: <57761E04.8030202@huawei.com>
	 <1467359847.11238.34.camel@edumazet-glaptop3.roam.corp.google.com>
	 <5776258F.6080008@huawei.com>
	 <1467361396.11238.35.camel@edumazet-glaptop3.roam.corp.google.com>
	 <577CBE0E.1050809@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: luto@kernel.org, mingo@kernel.org, linux-kernel@vger.kernel.org,
	Eric Dumazet <edumazet@google.com>,
	"David S. Miller" <davem@davemloft.net>,
	Netdev <netdev@vger.kernel.org>,
	Cong Wang <cwang@twopensource.com>
To: Ding Tianhong <dingtianhong@huawei.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <577CBE0E.1050809@huawei.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 2016-07-06 at 16:15 +0800, Ding Tianhong wrote:
> Hi Eric=EF=BC=9A
>=20
> I had found out that the patch aaf92f(netfilter: conntrack: resched i=
n
> nf_ct_iterate_cleanup) solve the problem,=20
> this patch add cond_sched() in the nf_ct_iterate_cleanup() which will
> be called in the net notifier chain every time,
> and I revert this patch at kernel 4.7-rc4 , it will panic for soft
> lockup, so I am not sure whether our patch is need,
> it looks like if I disable the CONFIG for netfilter that would
> register the nf_ct_iterate_cleanup as notifier, the problem still be
> exist.

Well, I do not have conntrack on my kernels, and I can not reproduce th=
e
issue.

So I am guessing other patches also solved a scalability issue, between
4.1 and 4.7

I am aware of something that David did for IPv4, but this might help as
well for IPv6.

commit fbd40ea0180a2d328c5adc61414dc8bab9335ce2
ipv4: Don't do expensive useless work during inetdev destroy.
   =20
