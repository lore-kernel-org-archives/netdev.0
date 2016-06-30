From: David Howells <dhowells@redhat.com>
Subject: Re: [PATCH net-next 19/19] rxrpc: Use RCU to access a peer's service connection tree
Date: Thu, 30 Jun 2016 17:22:19 +0100
Message-ID: <19436.1467303739@warthog.procyon.org.uk>
References: <20160630153049.GG30935@twins.programming.kicks-ass.net> <146729584148.26306.13038965408565743258.stgit@warthog.procyon.org.uk> <146729597856.26306.17024362508555652794.stgit@warthog.procyon.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: dhowells@redhat.com, davem@davemloft.net, netdev@vger.kernel.org,
	linux-afs@lists.infradead.org, linux-kernel@vger.kernel.org
To: Peter Zijlstra <peterz@infradead.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20160630153049.GG30935@twins.programming.kicks-ass.net>
Content-ID: <19435.1467303739.1@warthog.procyon.org.uk>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Peter Zijlstra <peterz@infradead.org> wrote:

> > +			if (conn->proto.index_key < k.index_key)
> > +				p = p->rb_left;
> > +			else if (conn->proto.index_key > k.index_key)
> > +				p = p->rb_right;
> 
> You still very much need rcu_dereference() for both left and right
> pointers. As well as the first p load.

Bah...  Yes.  Good point.

> > +	rb_link_node(&conn->service_node, parent, pp);
> 
> You want rb_link_node_rcu() here.

Should there be an rb_replace_node_rcu() also?

David
