From: Al Viro <viro@ZenIV.linux.org.uk>
Subject: Re: [PATCHSET] percpu: add __percpu sparse annotations
Date: Mon, 25 Jan 2010 23:14:11 +0000
Message-ID: <20100125231411.GA19799@ZenIV.linux.org.uk>
References: <1264432935-10453-1-git-send-email-tj@kernel.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org, axboe@kernel.dk,
	rusty@rustcorp.com.au, akpm@linux-foundation.org,
	ebiederm@xmission.com, tytso@mit.edu, Trond.Myklebust@netapp.com,
	aelder@sgi.com, hch@infradead.org, davem@davemloft.net,
	netdev@vger.kernel.org, x86@kernel.org, mingo@redhat.com,
	fweisbec@gmail.com, dan.j.williams@intel.com,
	borislav.petkov@amd.com, ying.huang@intel.com, lenb@kernel.org,
	neilb@suse.de, cl@linux-foundation.org
To: Tejun Heo <tj@kernel.org>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1752680Ab0AYXOU@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1264432935-10453-1-git-send-email-tj@kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Jan 26, 2010 at 12:22:07AM +0900, Tejun Heo wrote:
> This patchset adds __percpu sparse annotations to all percpu users
> covered by x86_64 allmodconfig.  __percpu annotation teaches sparse
> that percpu variables live in a separate address space and can't be
> accessed directly without going through percpu accessors.  This allows
> detection of most percpu access mistakes involving both static and
> dyanmic percpu variables.
> 
> This patchset contains the following eight patches.
> 
>  0001-percpu-add-__percpu-sparse-annotations-to-core-kerne.patch
>  0002-percpu-add-__percpu-sparse-annotations-to-fs.patch
>  0003-percpu-add-__percpu-sparse-annotations-to-net.patch
>  0004-percpu-add-__percpu-sparse-annotations-to-net-driver.patch
>  0005-percpu-add-__percpu-sparse-annotations-to-x86.patch
>  0006-percpu-add-__percpu-sparse-annotations-to-trace.patch
>  0007-percpu-add-__percpu-sparse-annotations-to-hw_breakpo.patch
>  0008-percpu-add-__percpu-sparse-annotations-to-what-s-lef.patch
> 
> As these annotations are for sparse, none of the above patches affects
> normal kernel build and most of the conversions are straight-forward
> and trivial.  There are a few places where the conversion isn't
> completely straight-forward (but still fairly trivial).  Those are
> mentioned in each patch description.
> 
> I can route the patch through percpu and conflict resolution, if
> necessary, wouldn't be difficult at all for these changes.  If anyone
> wants to route one of these patches through a different tree, please
> let me know.  All that's necessary would be adding dummy __percpu
> definition to the patch.
> 
> If nobody objects, I'll push these into percpu tree in three or four
> days.

Um.  Where *is* the definition of __percpu?  Presumably, that'd be
something like __attribute__((noderef,address_space(4)) under ifdef
__CHECKER__ and empty otherwise?  If so, I'm fine with that patchset,
provided that it does grow that #define and becomes self-contained...
