From: Frederic Weisbecker <fweisbec@gmail.com>
Subject: Re: [PATCH 7/8] percpu: add __percpu sparse annotations to
	hw_breakpoint
Date: Tue, 26 Jan 2010 02:12:36 +0100
Message-ID: <20100126011234.GL5087@nowhere>
References: <1264432935-10453-1-git-send-email-tj@kernel.org> <1264432935-10453-8-git-send-email-tj@kernel.org> <20100126001901.GI5087@nowhere> <4B5E401D.2020809@zytor.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Tejun Heo <tj@kernel.org>, linux-kernel@vger.kernel.org,
	axboe@kernel.dk, rusty@rustcorp.com.au, akpm@linux-foundation.org,
	ebiederm@xmission.com, tytso@mit.edu, Trond.Myklebust@netapp.com,
	aelder@sgi.com, hch@infradead.org, viro@zeniv.linux.org.uk,
	davem@davemloft.net, netdev@vger.kernel.org, x86@kernel.org,
	mingo@redhat.com, dan.j.williams@intel.com,
	borislav.petkov@amd.com, ying.huang@intel.com, lenb@kernel.org,
	neilb@suse.de, cl@linux-foundation.org
To: "H. Peter Anvin" <hpa@zytor.com>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1752522Ab0AZBMn@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <4B5E401D.2020809@zytor.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Jan 25, 2010 at 05:06:37PM -0800, H. Peter Anvin wrote:
> On 01/25/2010 04:19 PM, Frederic Weisbecker wrote:
> > On Tue, Jan 26, 2010 at 12:22:14AM +0900, Tejun Heo wrote:
> >> Add __percpu sparse annotations to hw_breakpoint.
> >>
> >> These annotations are to make sparse consider percpu variables to be
> >> in a different address space and warn if accessed without going
> >> through percpu accessors.  This patch doesn't affect normal builds.
> >>
> >> per_cpu(nr_task_bp_pinned, cpu) is replaced with
> >> &per_cpu(nr_task_bp_pinned[0], cpu).  This is the same to the compiler
> >> but allows per_cpu() macro to correctly drop __percpu designation for
> >> the returned pointer.
> > 
> > Ouch... It's unpleasant to see such workaround that messes up the
> > code just to make sparse happy.
> > 
> > I guess __percpu is an address_space attribute? Is there no
> > way to force the address space change directly from the
> > per_cpu() macro?
> > 
> 
> Hmm... thinking more about it, we should be able to just move the & and
> [0] into the per_cpu() macro, addressing the situation, or does that
> cause problems elsewhere?
> 
> 	-hpa


That would work only with arrays. per_cpu() can access either pointers
or direct values. Well that can be worked around with fake casts, but
I would except the (typeof(x) __force) to work and then offer a more
elegant solution.
