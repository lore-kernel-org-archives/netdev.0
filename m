From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: Re: [PATCH net-next] net: filter: rename 'struct sk_filter' to
 'struct bpf_prog'
Date: Fri, 25 Jul 2014 13:54:37 +0200
Message-ID: <20140725115414.GA4770@salvia>
References: <1406275499-7822-1-git-send-email-ast@plumgrid.com>
 <53D23EAF.4000001@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Alexei Starovoitov <ast@plumgrid.com>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, willemb@google.com,
	netfilter-devel@vger.kernel.org
To: Daniel Borkmann <dborkman@redhat.com>
Return-path: <netfilter-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <53D23EAF.4000001@redhat.com>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Jul 25, 2014 at 01:25:35PM +0200, Daniel Borkmann wrote:
> [ also Cc'ing Willem, Pablo ]
> 
> On 07/25/2014 10:04 AM, Alexei Starovoitov wrote:
> >'sk_filter' name is used as 'struct sk_filter', function sk_filter() and
> >as variable 'sk_filter', which makes code hard to read.
> >Also it's easily confused with 'struct sock_filter'
> >Rename 'struct sk_filter' to 'struct bpf_prog' to clarify semantics and
> >align the name with generic BPF use model.
> 
> Agreed, as we went for kernel/bpf/, renaming makes absolutely sense.

My nft socket filtering changes are accomodated into struct sk_filter,
and will still be, so I still need some generic name there...

Please, leave this as it is.

> >The only ugly place is uapi/linux/netfilter/xt_bpf.h which
> >managed to expose kernel internal structure into uapi header.
> >Though it shouldn't even compile in user space, preserve the mess by
> >adding empty 'struct sk_filter;' there and type cast it to 'struct bpf_prog'
> >inside kernel in net/netfilter/xt_bpf.c
> >
> >Signed-off-by: Alexei Starovoitov <ast@plumgrid.com>
> >---
> >
> >alternative fix for xt_bpf.h could be to replace:
> >         /* only used in the kernel */
> >	struct sk_filter *filter __attribute__((aligned(8)));
> >with
> >         /* only used in the kernel */
> >	void *filter __attribute__((aligned(8)));
> >
> >but this 'void *' approach may further break broken userspace,
> >whereas the fix implemented here is more seamless.
> 
> Yep, that's not good, 'struct sk_filter' should never have been in a uapi
> file actually.

You can just send me a patch to change it to void. It's an internal
kernel pointer as the comment states. There is **no** way that
userspace can lurk with that from iptables at all.
