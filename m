From: Michal Kubecek <mkubecek@suse.cz>
Subject: Re: [PATCH nf] netfilter: use RCU safe kfree for conntrack extensions
Date: Wed, 11 Sep 2013 19:42:48 +0200
Message-ID: <20130911174248.GA8318@unicorn.suse.cz>
References: <20130911090900.0129AE8AFF@unicorn.suse.cz>
 <20130911145715.GA2882@linuxace.com>
 <20130911152804.GA5397@unicorn.suse.cz>
 <20130911170946.GA2926@linuxace.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org,
	Pablo Neira Ayuso <pablo@netfilter.org>,
	Patrick McHardy <kaber@trash.net>,
	Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>
To: Phil Oester <kernel@linuxace.com>
Return-path: <netfilter-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20130911170946.GA2926@linuxace.com>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Sep 11, 2013 at 10:09:47AM -0700, Phil Oester wrote:
> 
> 1) normally RCU functions have _rcu suffixes.  So nf_ct_ext_free should
> become nf_ct_ext_free_rcu.

Right. I'll post updated version with the rename tomorrow.

> 2) kfree_rcu was not added to the kernel until 3.0.  All of the bug
> reports I've been looking into (including the original in netfilter bugzilla
> at http://bugzilla.netfilter.org/show_bug.cgi?id=714) have been reported in
> 2.6.32 or earlier kernels.  So a different fix would need to be backported for
> -stable.  For that, we would probably export __nf_ct_ext_free_rcu from
> nf_conntrack_extend.c and change the kfree call in nf_ct_ext_free_rcu to
> call_rcu(&ct->ext->rcu, __nf_ct_ext_free_rcu).

Yes, the patch submitted here is against current nf branch. For
SLES 11 SP1 (with 2.6.32 kernel), I'm going to use call_rcu() the way
original commit 68b80f11 does. IIRC the only pre-3.0 stable branch still
maintained is 2.6.32, all others are 3.0 or newer so they have
kfree_rcu() and also use it in __nf_ct_ext_add() since commit 1f8d36a1. 

                                                        Michal Kubecek

