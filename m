From: Andrey Wagin <avagin@gmail.com>
Subject: Re: [PATCH] netfilter: nf_conntrack: fix RCU race in
 nf_conntrack_find_get (v3)
Date: Tue, 14 Jan 2014 15:10:50 +0400
Message-ID: <CANaxB-zSkmVy+TBCa0CyReiSgubBUmyz6iUp8bxByOr7Jb9oGw@mail.gmail.com>
References: <1389188841.26646.87.camel@edumazet-glaptop2.roam.corp.google.com>
	<1389549033-23523-1-git-send-email-avagin@openvz.org>
	<1389558074.31367.187.camel@edumazet-glaptop2.roam.corp.google.com>
	<20140114105147.GA14538@paralelels.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	Florian Westphal <fw@strlen.de>,
	netfilter-devel@vger.kernel.org, netfilter@vger.kernel.org,
	coreteam@netfilter.org, netdev@vger.kernel.org,
	LKML <linux-kernel@vger.kernel.org>, vvs@openvz.org,
	Pablo Neira Ayuso <pablo@netfilter.org>,
	Patrick McHardy <kaber@trash.net>,
	Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>,
	"David S. Miller" <davem@davemloft.net>,
	Cyrill Gorcunov <gorcunov@openvz.org>
To: Andrew Vagin <avagin@parallels.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20140114105147.GA14538@paralelels.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

>
> Eh, looks like this path is incomplete too:(
>
> I think we can't set a reference counter for objects which is allocated
> from a SLAB_DESTROY_BY_RCU cache. Look at the following backtrace.
>
> cpu1                                    cpu2
> ct = ____nf_conntrack_find()
>                                         destroy_conntrack
> atomic_inc_not_zero(ct)

ct->ct_general.use is zero after destroy_conntrack(). Sorry for the noise.
