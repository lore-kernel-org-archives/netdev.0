From: Phil Oester <kernel@linuxace.com>
Subject: Re: [PATCH nf] netfilter: use RCU safe kfree for conntrack extensions
Date: Wed, 11 Sep 2013 07:57:15 -0700
Message-ID: <20130911145715.GA2882@linuxace.com>
References: <20130911090900.0129AE8AFF@unicorn.suse.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org,
	Pablo Neira Ayuso <pablo@netfilter.org>,
	Patrick McHardy <kaber@trash.net>,
	Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>,
	coreteam@netfilter.org
To: Michal Kubecek <mkubecek@suse.cz>
Return-path: <netfilter-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20130911090900.0129AE8AFF@unicorn.suse.cz>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Sep 11, 2013 at 10:17:27AM +0200, Michal Kubecek wrote:
> Commit 68b80f11 (netfilter: nf_nat: fix RCU races) introduced
> RCU protection for freeing extension data when reallocation
> moves them to a new location. We need the same protection when
> freeing them in nf_ct_ext_free() in order to prevent a
> use-after-free by other threads referencing a NAT extension data
> via bysource list.

Hi Michal - 

coincidentally I've been looking into this area this week due to another
bug report (https://bugzilla.kernel.org/show_bug.cgi?id=60853).  Looking at
your proposed fix, the NAT extension data should have been cleaned
from the bysource list in nf_nat_cleanup_conntrack (via __nf_ct_ext_destroy)
before reaching the kfree.  Would you agree?

The reporter of #60853 suggested adding a synchronize_rcu to the end of the
nf_nat_cleanup_conntrack function, which seems sane.  I have been trying to 
reproduce the crash to test that theory.

Are you able to reproduce an OOPS in your testing?  Or is there a bug report
you are working from?

Phil
