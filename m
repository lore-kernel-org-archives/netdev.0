From: Al Viro <viro@ZenIV.linux.org.uk>
Subject: Re: [PATCH 7/8] percpu: add __percpu sparse annotations to
	hw_breakpoint
Date: Tue, 26 Jan 2010 03:56:58 +0000
Message-ID: <20100126035658.GE19799@ZenIV.linux.org.uk>
References: <1264432935-10453-8-git-send-email-tj@kernel.org> <20100126001901.GI5087@nowhere> <4B5E3F2C.2010702@zytor.com> <4B5E4E12.7060900@kernel.org> <20100126020452.GB19799@ZenIV.linux.org.uk> <4B5E508A.1030305@kernel.org> <20100126023238.GC19799@ZenIV.linux.org.uk> <4B5E56EC.2090600@kernel.org> <20100126024857.GD19799@ZenIV.linux.org.uk> <4B5E5D3B.7040102@kernel.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "H. Peter Anvin" <hpa@zytor.com>,
	Frederic Weisbecker <fweisbec@gmail.com>,
	linux-kernel@vger.kernel.org, axboe@kernel.dk,
	rusty@rustcorp.com.au, akpm@linux-foundation.org,
	ebiederm@xmission.com, tytso@mit.edu, Trond.Myklebust@netapp.com,
	aelder@sgi.com, hch@infradead.org, davem@davemloft.net,
	netdev@vger.kernel.org, x86@kernel.org, mingo@redhat.com,
	dan.j.williams@intel.com, borislav.petkov@amd.com,
	ying.huang@intel.com, lenb@kernel.org, neilb@suse.de,
	cl@linux-foundation.org
To: Tejun Heo <tj@kernel.org>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1753181Ab0AZD5w@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <4B5E5D3B.7040102@kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Jan 26, 2010 at 12:10:51PM +0900, Tejun Heo wrote:
> Hello,
> 
> On 01/26/2010 11:48 AM, Al Viro wrote:
> > On Tue, Jan 26, 2010 at 11:43:56AM +0900, Tejun Heo wrote:
> > 
> >>> Eh...  You are leaving that noderef in place in case of array.  And _that_
> >>> is not an address space, so casts to AS 0 won't do you any good.
> >>
> >> Any ideas on how to fix it?
> > 
> > BTW, before we go any further, which warnings are you getting from sparse
> > and which version of sparse are you using?
> > 
> > noderef is one thing; address_space mess is a different story.  The version
> > I have here steps into the former, but not the latter; what are you seeing?
> 
> Oops, I too am seeing the noderef thing not the address space warning.

OK...  So all messing around __kernel __force is actually a red herring.

Frankly, for now I'd keep it as in your patch.  Yes, including workarounds
in these few places.  Longer term...  We probably want to implement
__attribute__((qualify(...)))/__attribute__((unqualify(...))), revert
__typeof__ for AS/noderef to what gcc is doing for normal qualifiers
(i.e. "if p is int const *, typeof(*p) v gives const int") go for explicit
__unqualify((address_space,noderef)) in there.  Playing interesting games
with arrays for unqualify (i.e. creating parallel chains of type nodes
all way down to the place where original qualifier had been applied).
