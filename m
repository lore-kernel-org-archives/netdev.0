From: Christoph Hellwig <hch@infradead.org>
Subject: Re: [PATCH 0/3] netfilter : 3 patches to boost ip_tables performance
Date: Thu, 22 Sep 2005 13:58:49 +0100
Message-ID: <20050922125849.GA27413@infradead.org>
References: <43308324.70403@cosmosbay.com> <43329F6E.3030706@cosmosbay.com> <20050922124941.GA26936@infradead.org> <200509221454.22923.ak@suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Christoph Hellwig <hch@infradead.org>,
	Eric Dumazet <dada1@cosmosbay.com>,
	Christoph Lameter <clameter@engr.sgi.com>,
	"David S. Miller" <davem@davemloft.net>,
	linux-kernel@vger.kernel.org, netfilter-devel@lists.netfilter.org,
	netdev@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1030294AbVIVM64@vger.kernel.org>
To: Andi Kleen <ak@suse.de>
Content-Disposition: inline
In-Reply-To: <200509221454.22923.ak@suse.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Sep 22, 2005 at 02:54:22PM +0200, Andi Kleen wrote:
> > > +void *vmalloc_node(unsigned long size, int node)
> > > +{
> > > +	void *result;
> > > +	struct mempolicy *oldpol = current->mempolicy;
> > > +	mm_segment_t oldfs = get_fs();
> > > +	DECLARE_BITMAP(prefnode, MAX_NUMNODES);
> > > +
> > > +	mpol_get(oldpol);
> > > +	bitmap_zero(prefnode, MAX_NUMNODES);
> > > +	set_bit(node, prefnode);
> > > +
> > > +	set_fs(KERNEL_DS);
> > > +	sys_set_mempolicy(MPOL_PREFERRED, prefnode, MAX_NUMNODES);
> > > +	set_fs(oldfs);
> > > +
> > > +	result = vmalloc(size);
> > > +
> > > +	mpol_free(current->mempolicy);
> > > +	current->mempolicy = oldpol;
> > > +	return result;
> > > +}
> >
> > No way, sorry.  If you want a vmalloc node do it right.
> 
> The implementation looks fine to me, so I think it's already right.

Umm, no - adding set_fs/get_fs mess for things like that is not right.
If we want to go down the mempolicy-based route we need to add a proper
kernel entry point for setting a mempolicy
