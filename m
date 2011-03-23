From: Matthew Wilcox <matthew@wil.cx>
Subject: Re: [PATCH 02/36] scsi,rcu: convert call_rcu(fc_rport_free_rcu) to
	kfree_rcu()
Date: Wed, 23 Mar 2011 17:19:49 -0600
Message-ID: <20110323231948.GE13806@parisc-linux.org>
References: <4D82D071.5020703@cn.fujitsu.com> <4D82D3FF.2080303@cn.fujitsu.com> <4D82D45A.30102@cn.fujitsu.com> <1300814913.19083.427.camel@fritz> <20110323065014.GU2322@linux.vnet.ibm.com> <1300889151.15899.4.camel@mulgrave.site>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: paulmck@linux.vnet.ibm.com, Robert Love <robert.w.love@intel.com>,
	Lai Jiangshan <laijs@cn.fujitsu.com>,
	Ingo Molnar <mingo@elte.hu>, Jens Axboe <axboe@kernel.dk>,
	Neil Horman <nhorman@tuxdriver.com>,
	"David S. Miller" <davem@davemloft.net>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	"Pekka Savola (ipv6)" <pekkas@netcore.fi>,
	James Morris <jmorris@namei.org>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	Patrick McHardy <kaber@trash.net>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Stephen Hemminger <shemminger@vyatta.com>,
	Tejun Heo <tj@kernel.org>, Jarek Poplawski <jarkao2@gmail.com>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"devel@open-fcoe.org" <devel@open-fcoe.org>,
	"linux-scsi@vger.kernel.org" <linux-scsi@vger.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: James Bottomley <James.Bottomley@suse.de>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1300889151.15899.4.camel@mulgrave.site>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Mar 23, 2011 at 09:05:51AM -0500, James Bottomley wrote:
> > #define kfree_rcu(ptr, rcu_head)					\
> > 	__kfree_rcu(&((ptr)->rcu_head), offsetof(typeof(*(ptr)), rcu_head))
> 
> Isn't this one of those cases where the obvious use of the interface is
> definitely wrong?

But it's a compile time breakage if you use it wrong, not runtime.

> It's also another nasty pseudo C prototype.  I know we do this sort of
> thing for container_of et al, but I don't really think we want to extend
> it.

We do it for list_entry, list_for_each_entry, etc.  And those are very
widespread within the kernel.

-- 
Matthew Wilcox				Intel Open Source Technology Centre
"Bill, look, we understand that you're interested in selling us this
operating system, but compare it to ours.  We can't possibly take such
a retrograde step."
