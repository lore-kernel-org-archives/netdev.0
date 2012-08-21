From: Cong Wang <amwang@redhat.com>
Subject: Re: [RFC Patch net-next] ipv6: unify conntrack reassembly expire
 code with standard one
Date: Tue, 21 Aug 2012 21:38:58 +0800
Message-ID: <1345556338.3044.1.camel@cr0>
References: <1345190565-21689-1-git-send-email-amwang@redhat.com>
	 <1826853.rak2U42CMU@alaris> <1345453599.22373.9.camel@cr0>
	 <20120820202109.GB28790@unicorn.suse.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Herbert Xu <herbert@gondor.hengli.com.au>,
	"David S. Miller" <davem@davemloft.net>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	Patrick McHardy <kaber@trash.net>,
	Shan Wei <shanwei@cn.fujitsu.com>,
	Pablo Neira Ayuso <pablo@netfilter.org>,
	netfilter-devel@vger.kernel.org
To: Michal Kubecek <mkubecek@suse.cz>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <20120820202109.GB28790@unicorn.suse.cz>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 2012-08-20 at 22:21 +0200, Michal Kubecek wrote:
> On Mon, Aug 20, 2012 at 05:06:39PM +0800, Cong Wang wrote:
> > doesn't work. I think we probably can save the struct net pointer in
> > struct netns_frags during inet_frags_init_net(), so that container_of()
> > can be eliminated. 
> 
> This would work but one would have to check carefully that the pointer
> is always set to an usable value. Or we could just add a flag indicating
> whether the structure is embedded (and if it is not, use init_net).
> Another approach was suggested in the patchworks discussion: add a
> special namespace for IPv6 conntrack fragment handling.

I think your former solution is easier, I will try it.

> 
> > Thanks for testing! I tried to test it too, but seems I can't trigger a
> > defragment. Any hints?
> 
> I used netfilter on a computer between source and destination of the 
> packets (generated with "ping6 -s 3000"):
> 
> ip6tables -A FORWARD -o ... -m frag --fragid 0:0xFFFFFFFF --fraglast -j DROP
> 
> The --fragid condition is needed to work around a bug in iptables (if 
> frag module is loaded and there is no --fragid, only packets with zero
> fragment id match - patch for this is already in git). On the target,
> packet is defragmented automatically, by default by the "normal" code,
> with nf_conntrack_ipv6 module by the conntrack code.
> 
> Setting
> 
>   echo 5 >/proc/sys/net/ipv6/ip6frag_time
>   echo 5 >/proc/sys/net/netfilter/nf_conntrack_frag6_timeout
> 
> on target also helps.
> 

Great! This helps!

Thanks!

