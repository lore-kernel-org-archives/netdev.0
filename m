From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: Re: [PATCH v4 net-next 5/5] net: filter: split 'struct sk_filter'
 into socket and bpf parts
Date: Thu, 31 Jul 2014 21:40:59 +0200
Message-ID: <20140731194059.GA8681@salvia>
References: <1406777656-27755-1-git-send-email-ast@plumgrid.com>
 <1406777656-27755-6-git-send-email-ast@plumgrid.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>,
	Daniel Borkmann <dborkman@redhat.com>,
	Willem de Bruijn <willemb@google.com>,
	Kees Cook <keescook@chromium.org>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, netfilter-devel@vger.kernel.org
To: Alexei Starovoitov <ast@plumgrid.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1406777656-27755-6-git-send-email-ast@plumgrid.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Jul 30, 2014 at 08:34:16PM -0700, Alexei Starovoitov wrote:
> clean up names related to socket filtering and bpf in the following way:
> - everything that deals with sockets keeps 'sk_*' prefix
> - everything that is pure BPF is changed to 'bpf_*' prefix
> 
> split 'struct sk_filter' into
> struct sk_filter {
> 	atomic_t        refcnt;
> 	struct rcu_head rcu;
> 	struct bpf_prog *prog;
> };

I think you can use 'struct bpf_prog prog' instead so the entire
sk_filter remains in the same memory blob (as it is before this
patch).

You can add an inline function to retrieve the bpg prog from the
filter:

static inline struct bpf_prog *sk_filter_bpf(struct sk_filter *)

and use it whenever possible to fetch the bpf program. I'm suggesting
this because we can use the zero array size in the socket filtering
abstraction later on, if the function above is used, this just needs
one line in that function to be updated to fetch the program from the
placeholder.
