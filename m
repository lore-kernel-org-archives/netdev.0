From: Al Viro <viro@ZenIV.linux.org.uk>
Subject: Re: [PATCH 7/8] percpu: add __percpu sparse annotations to
	hw_breakpoint
Date: Tue, 26 Jan 2010 02:32:38 +0000
Message-ID: <20100126023238.GC19799@ZenIV.linux.org.uk>
References: <1264432935-10453-1-git-send-email-tj@kernel.org> <1264432935-10453-8-git-send-email-tj@kernel.org> <20100126001901.GI5087@nowhere> <4B5E3F2C.2010702@zytor.com> <4B5E4E12.7060900@kernel.org> <20100126020452.GB19799@ZenIV.linux.org.uk> <4B5E508A.1030305@kernel.org>
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
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1753662Ab0AZCdd@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <4B5E508A.1030305@kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Jan 26, 2010 at 11:16:42AM +0900, Tejun Heo wrote:

> # define RELOC_HIDE(ptr, off)					\
>   ({ unsigned long __ptr;					\
>      __ptr = (unsigned long) (ptr);				\
>     (typeof(ptr)) (__ptr + (off)); })
> 
> #define __verify_pcpu_ptr(ptr)	do {					\
> 	const void __percpu *__vpp_verify = (typeof(ptr))NULL;		\
> 	(void)__vpp_verify;						\
> } while (0)
> 
> /* Weird cast keeps both GCC and sparse happy. */
> #define SHIFT_PERCPU_PTR(__p, __offset)	({				\
> 	__verify_pcpu_ptr((__p));					\
> 	RELOC_HIDE((typeof(*(__p)) __kernel __force *)(__p), (__offset)); \
> })
> 
> #define per_cpu(var, cpu) \
> 	(*SHIFT_PERCPU_PTR(&(var), per_cpu_offset(cpu)))

Eh...  You are leaving that noderef in place in case of array.  And _that_
is not an address space, so casts to AS 0 won't do you any good.
