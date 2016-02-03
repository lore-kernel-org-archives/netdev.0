From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH v3] net:Add sysctl_max_skb_frags
Date: Wed, 03 Feb 2016 08:07:08 -0800
Message-ID: <1454515628.7627.245.camel@edumazet-glaptop2.roam.corp.google.com>
References: <568F87AC.60405@oracle.com>
	 <1454488017-8822-1-git-send-email-hans.westgaard.ry@oracle.com>
	 <CAKgT0UftR3pTOGO91GaUijPCTq8POQcNChRqyy1b1TYsM3n4Uw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Hans Westgaard Ry <hans.westgaard.ry@oracle.com>,
	"David S. Miller" <davem@davemloft.net>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	James Morris <jmorris@namei.org>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	Patrick McHardy <kaber@trash.net>,
	Tom Herbert <tom@herbertland.com>,
	Pablo Neira Ayuso <pablo@netfilter.org>,
	Eric Dumazet <edumazet@google.com>,
	Florian Westphal <fw@strlen.de>, Jiri Pirko <jiri@resnulli.us>,
	Alexander Duyck <alexander.h.duyck@redhat.com>,
	Michal Hocko <mhocko@suse.com>,
	Linus =?ISO-8859-1?Q?L=FCssing?= <linus.luessing@c0d3.blue>,
	Hannes Frederic Sowa <hannes@stressinduktion.org>,
	Herbert Xu <herbert@gondor.apana.org.au>,
	Tejun Heo <tj@kernel.org>,
	Andrew Morton <akpm@linux-foundation.org>,
	Alexey Kodanev <alexey.kodanev@oracle.com>,
	=?ISO-8859-1?Q?H=E5kon?= Bugge <haakon.bugge@oracle.com>,
	open list <linux-kernel@vger.kernel.org>,
	"open
To: Alexander Duyck <alexander.duyck@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CAKgT0UftR3pTOGO91GaUijPCTq8POQcNChRqyy1b1TYsM3n4Uw@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 2016-02-03 at 07:58 -0800, Alexander Duyck wrote:
> > +++ b/net/core/sysctl_net_core.c
> 
> I really don't think these changes belong in the core. Below you only
> modify the TCP code path so this more likely belongs in the TCP path
> unless you are going to guarantee that all other code paths obey the
> sysctl.  It probably belongs in net/ipv4/sysctl_net_ipv4.c


Alexander, this is a v3.

We rejected prior attempts doing exactly what you suggest.

Think about GRO : These people also need to use the same sysctl in GRO
to limit number of frags.

Limiting the stuff at the egress is useless in forwarding setups.
It will be too late as they'll need to linearize -> huge performance
drop.

This is why we wanted a global setup so that these guys can tweak the
default limit.

Please read netdev history about this stuff.

Plan of action :

1) This patch, adding a core sysctl.
2) Use it in TCP (already done in this patch)
3) Use it in GRO
