From: Tejun Heo <tj@kernel.org>
Subject: Re: [PATCH 7/8] percpu: add __percpu sparse annotations to	hw_breakpoint
Date: Tue, 26 Jan 2010 11:34:40 +0900
Message-ID: <4B5E54C0.2040709@kernel.org>
References: <1264432935-10453-1-git-send-email-tj@kernel.org> <1264432935-10453-8-git-send-email-tj@kernel.org> <20100126001901.GI5087@nowhere> <4B5E3BED.6030705@kernel.org> <20100126010239.GK5087@nowhere> <4B5E4308.8020105@kernel.org> <20100126020113.GM5087@nowhere> <4B5E4FE7.30700@kernel.org> <20100126021846.GO5087@nowhere> <20100126022211.GP5087@nowhere>
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
Return-path: <netdev-owner@vger.kernel.org>
Received: from hera.kernel.org ([140.211.167.34]:49424 "EHLO hera.kernel.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751396Ab0AZC3Z (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 25 Jan 2010 21:29:25 -0500
In-Reply-To: <20100126022211.GP5087@nowhere>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 01/26/2010 11:22 AM, Frederic Weisbecker wrote:
>> What about this? It doesn't use direct cast to scalar but should
>> create a pointer type to kernel space datas:
>>
>>
>> #define kernel_space_t(var)	\
>> 	(typeof(var)	__kernel __force)
> 
> 
> Should be typeof(*var)
> 
>>
>> #define SHIFT_PERCPU_PTR(__p, __offset) ({                              \
>>         __verify_pcpu_ptr((__p));                                       \
>>         RELOC_HIDE((typeof(*(kernel_space_t(var)) __kernel __force *)(__p), (__offset)); \
>> })

Can you balance ()'s here too?

-- 
tejun
