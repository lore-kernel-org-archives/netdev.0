From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH v3] net:Add sysctl_max_skb_frags
Date: Wed, 3 Feb 2016 20:20:52 +0800
Message-ID: <20160203122052.GA28619@gondor.apana.org.au>
References: <568F87AC.60405@oracle.com>
 <1454488017-8822-1-git-send-email-hans.westgaard.ry@oracle.com>
 <20160203112550.GB28003@gondor.apana.org.au>
 <56B1E635.8020707@stressinduktion.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
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
	Linus =?iso-8859-1?Q?L=FCssing?= <linus.luessing@c0d3.blue>,
	Tejun Heo <tj@kernel.org>,
	Andrew Morton <akpm@linux-foundation.org>,
	Alexey Kodanev <alexey.kodanev@oracle.com>,
	=?iso-8859-1?Q?H=E5kon?= Bugge <haakon.bugge@oracle.com>,
	open list <linux-kernel@vger.kernel.org>,
	"open list:NETWORKING [GENERAL]" <netdev@vger.kernel.org>
To: Hannes Frederic Sowa <hannes@stressinduktion.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <56B1E635.8020707@stressinduktion.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Feb 03, 2016 at 12:36:21PM +0100, Hannes Frederic Sowa wrote:
>
> Agreed that it feels like a hack, but a rather simple one. I would
> consider this to be just a performance improvement. We certainly need
> a slow-path when virtio drivers submit gso packets to the stack (and
> already discussed with Hans). The sysctl can't help here. But without
> the sysctl the packets would constantly hit the slow-path in case of
> e.g. IPoIB and that would also be rather bad.

So you want to penalise every NIC in the system if just one of
them is broken? This is insane.  Just do the partial linearisation
in that one driver that needs it and not only won't you have to
penalise anyone else but you still get the best result for that
driver that needs it.

Besides, you have to implement the linearisation anyway because
of virtualisation.

Cheers,
-- 
Email: Herbert Xu <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
