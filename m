From: "David S. Miller" <davem@redhat.com>
Subject: Re: [PATCH] Prevent crash on ip_conntrack removal
Date: Sat, 21 Aug 2004 22:13:44 -0700
Sender: netfilter-devel-admin@lists.netfilter.org
Message-ID: <20040821221344.6dbc98ed.davem@redhat.com>
References: <20040818091352.GB6507@suse.de>
	<20040819101159.GC3921@sunbeam.de.gnumonks.org>
	<20040819071846.2d0d6120.davem@redhat.com>
	<4124BF7E.7090304@trash.net>
	<20040819081428.5243e314.davem@redhat.com>
	<412765DC.30600@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: laforge@netfilter.org, okir@suse.de, netdev@oss.sgi.com,
        netfilter-devel@lists.netfilter.org
Return-path: <netfilter-devel-admin@lists.netfilter.org>
To: Patrick McHardy <kaber@trash.net>
In-Reply-To: <412765DC.30600@trash.net>
Errors-To: netfilter-devel-admin@lists.netfilter.org
List-Help: <mailto:netfilter-devel-request@lists.netfilter.org?subject=help>
List-Post: <mailto:netfilter-devel@lists.netfilter.org>
List-Subscribe: <https://lists.netfilter.org/mailman/listinfo/netfilter-devel>,
	<mailto:netfilter-devel-request@lists.netfilter.org?subject=subscribe>
List-Unsubscribe: <https://lists.netfilter.org/mailman/listinfo/netfilter-devel>,
	<mailto:netfilter-devel-request@lists.netfilter.org?subject=unsubscribe>
List-Archive: <https://lists.netfilter.org/pipermail/netfilter-devel/>
List-Id: netdev.vger.kernel.org

On Sat, 21 Aug 2004 17:10:20 +0200
Patrick McHardy <kaber@trash.net> wrote:

> David S. Miller wrote:
> 
> >I have a better idea.
> >
> >Instead of setting skb->dst to NULL, it should set it to some
> >NULL destination entry which just frees up the packets.  Then
> >no special case handling.  skb->dst==NULL packets should never
> >get into the fragment queue to begin with.
> >
> The problem is that conntrack unload can cause packets without a
> dst_entry to appear in ip_local_deliver, which is already after
> the call to dst_input.

How can it call ip_local_deliver() without a valid skb->dst?
That function is only invoked via skb->dst->input(skb) which
by implication means that skb->dst is non-NULL.

Actually there is a call via ip_mr_input() but that code also
has a precondition that skb->dst is non-NULL too.  I say this
due to the unchecked skb->dst accesses it makes early on.

Please explain.  I don't question that it happens, just show
me how :-)
