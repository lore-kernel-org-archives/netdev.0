From: Matthew Wilcox <matthew@wil.cx>
Subject: Re: [PATCH 02/36] scsi,rcu: convert call_rcu(fc_rport_free_rcu) to
	kfree_rcu()
Date: Wed, 23 Mar 2011 05:22:57 -0600
Message-ID: <20110323112257.GD13806@parisc-linux.org>
References: <4D82D071.5020703@cn.fujitsu.com> <4D82D3FF.2080303@cn.fujitsu.com> <4D82D45A.30102@cn.fujitsu.com> <1300814913.19083.427.camel@fritz> <20110323065014.GU2322@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Robert Love <robert.w.love@intel.com>,
	Lai Jiangshan <laijs@cn.fujitsu.com>,
	Ingo Molnar <mingo@elte.hu>, Jens Axboe <axboe@kernel.dk>,
	"James E.J. Bottomley" <James.Bottomley@suse.de>,
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
To: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20110323065014.GU2322@linux.vnet.ibm.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Mar 22, 2011 at 11:50:14PM -0700, Paul E. McKenney wrote:
> On Tue, Mar 22, 2011 at 10:28:33AM -0700, Robert Love wrote:
> > On Thu, 2011-03-17 at 20:41 -0700, Lai Jiangshan wrote:
> > > -	call_rcu(&rdata->rcu, fc_rport_free_rcu);
> > > +	kfree_rcu(rdata, rcu);
> > 
> > I think this last line should be:
> > 
> > kfree_rcu(rdata, &rdata->rcu);
> 
> Hello, Robert,
> 
> I believe that it is correct as is.  The kfree_rcu() definition is as
> follows:
> 
> #define kfree_rcu(ptr, rcu_head)					\
> 	__kfree_rcu(&((ptr)->rcu_head), offsetof(typeof(*(ptr)), rcu_head))
> 
> Then __kfree_rcu() encodes the offset into the rcu_head so that it can
> be handled properly at the end of the grace period.

To be fair to Robert, I had the same thought, but decided to check the
definition of kfree_rcu before I made the same comment.  Unfortunately,
the definition of kfree_rcu is still not in Linus' tree (and there's no
indication in the patch series about where to find the definition).  It
would have been better if kfree_rcu were patch 1/n in the series, then
we'd've been able to review it more effectively.

Any idea when kfree_rcu will be submitted to Linus?

-- 
Matthew Wilcox				Intel Open Source Technology Centre
"Bill, look, we understand that you're interested in selling us this
operating system, but compare it to ours.  We can't possibly take such
a retrograde step."
