From: Tejun Heo <tj@kernel.org>
Subject: Re: [PATCH 7/8] percpu: add __percpu sparse annotations to	hw_breakpoint
Date: Tue, 26 Jan 2010 11:13:59 +0900
Message-ID: <4B5E4FE7.30700@kernel.org>
References: <1264432935-10453-1-git-send-email-tj@kernel.org> <1264432935-10453-8-git-send-email-tj@kernel.org> <20100126001901.GI5087@nowhere> <4B5E3BED.6030705@kernel.org> <20100126010239.GK5087@nowhere> <4B5E4308.8020105@kernel.org> <20100126020113.GM5087@nowhere>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, axboe@kernel.dk,
	rusty@rustcorp.com.au, akpm@linux-foundation.org,
	ebiederm@xmission.com, tytso@mit.edu, Trond.Myklebust@netapp.com,
	aelder@sgi.com, hch@infradead.org, viro@zeniv.linux.org.uk,
	davem@davemloft.net, netdev@vger.kernel.org, x86@kernel.org,
	mingo@redhat.com, dan.j.williams@intel.com,
	borislav.petkov@amd.com, ying.huang@intel.com, lenb@kernel.org,
	neilb@suse.de, cl@linux-foundation.org
To: Frederic Weisbecker <fweisbec@gmail.com>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1753341Ab0AZCIe@vger.kernel.org>
In-Reply-To: <20100126020113.GM5087@nowhere>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello,

On 01/26/2010 11:01 AM, Frederic Weisbecker wrote:
> So, may be it considers you are applying the address space overriding
> to the pointer to the type and not to the type itself.
> 
> Consider:
> 
> 	int __percpu i;
> 
> What you do above *might* be considered as if SHIFT_PERCPU_PTR
> returns something of a type:
> 
> 	int * __percpu i;
> 
> So the pointer is in the normal address space, but its content is in
> __percpu address space.
> 
> What if you do this:
> 
> 
> #define SHIFT_PERCPU_PTR(__p, __offset)      ({                      \
>       __verify_pcpu_ptr((__p));                                       \
>       RELOC_HIDE((__p), (__offset)); \
> })
> 
> #define per_cpu(var, cpu) \
>       (typeof(var) __kernel __force)(*SHIFT_PERCPU_PTR(&(var), per_cpu_offset(cpu)))

arch/x86/kernel/cpu/common.c:1149:20: warning: cast to non-scalar
arch/x86/kernel/cpu/common.c:1149:20: error: strange non-value function or array
  CC      arch/x86/kernel/cpu/common.o
arch/x86/kernel/cpu/common.c: In function 'cpu_init':
arch/x86/kernel/cpu/common.c:1149: error: cast specifies array type

Can't cast that way.  :-(

-- 
tejun
