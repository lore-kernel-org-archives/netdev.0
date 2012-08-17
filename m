From: Michal =?utf-8?B?S3ViZcSNZWs=?= <mkubecek@suse.cz>
Subject: Re: [RFC Patch net-next] ipv6: unify conntrack reassembly expire code with standard one
Date: Fri, 17 Aug 2012 19:05:57 +0200
Message-ID: <1826853.rak2U42CMU@alaris>
References: <1345190565-21689-1-git-send-email-amwang@redhat.com>
Reply-To: Michal =?utf-8?B?S3ViZcSNZWs=?= <mkubecek@suse.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7Bit
Cc: netdev@vger.kernel.org, Herbert Xu <herbert@gondor.hengli.com.au>,
	"David S. Miller" <davem@davemloft.net>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	Patrick McHardy <kaber@trash.net>,
	Shan Wei <shanwei@cn.fujitsu.com>,
	Pablo Neira Ayuso <pablo@netfilter.org>,
	netfilter-devel@vger.kernel.org
To: Cong Wang <amwang@redhat.com>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1345190565-21689-1-git-send-email-amwang@redhat.com>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Friday 17 of August 2012 16:02EN, Cong Wang wrote:
> Two years ago, Shan Wei tried to fix this:
> http://patchwork.ozlabs.org/patch/43905/
> 
...
>
> As Herbert suggested, we could actually use the standard IPv6
> reassembly code which follows RFC2460.

I tested the patch and I ran into a problem in this place in 
ip6_expire_frag_queue():

>  	net = container_of(fq->q.net, struct net, ipv6.frags);

For frag queues coming from IPv6 conntrack, fq->q.net points to 
nf_init_frags which is not embedded into struct net so that the 
following device lookup leads to reading from an invalid address.
The same problem has been discussed on the page linked above.

I didn't test with current net-next source but as far as I can tell, 
this hasn't changed. Did I miss something?

                                                     Michal Kubecek

