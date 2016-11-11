From: Florian Westphal <fw@strlen.de>
Subject: Re: question about xt_find_table_lock
Date: Fri, 11 Nov 2016 12:23:07 +0100
Message-ID: <20161111112307.GA7274@breakpoint.cc>
References: <alpine.DEB.2.20.1611111141380.2074@hadrien>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: pablo@netfilter.org, kaber@trash.net, kadlec@blackhole.kfki.hu,
        davem@davemloft.net, netfilter-devel@vger.kernel.org,
        coreteam@netfilter.org, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org, christophe.jaillet@wanadoo.fr
To: Julia Lawall <julia.lawall@lip6.fr>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.20.1611111141380.2074@hadrien>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Julia Lawall <julia.lawall@lip6.fr> wrote:
> The function xt_find_table_lock defined in net/netfilter/x_tables.c is
> preceeded by a comment that says that it returns ERR_PTR() on error.  But
> looking at the definition, I only see occurrences of return NULL and
> returns of pointers that have previously been dereferenced.  Is it the
> code or the documentation that is incorrect?  The call sites seem to be
> using IS_ERR_OR_NULL.  Is there a plan to return ERR_PTR values in the
> future?

It used to return ERR_PTR, see:

commit 7926dbfa4bc14e27f4e18a6184a031a1c1e077dc
netfilter: don't use mutex_lock_interruptible()

So the comment isn't correct anymore and callers could test vs NULL.
