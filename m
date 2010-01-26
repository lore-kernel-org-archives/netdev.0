From: "H. Peter Anvin" <hpa@zytor.com>
Subject: Re: [PATCH 7/8] percpu: add __percpu sparse annotations to	hw_breakpoint
Date: Mon, 25 Jan 2010 17:06:37 -0800
Message-ID: <4B5E401D.2020809@zytor.com>
References: <1264432935-10453-1-git-send-email-tj@kernel.org> <1264432935-10453-8-git-send-email-tj@kernel.org> <20100126001901.GI5087@nowhere>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Tejun Heo <tj@kernel.org>, linux-kernel@vger.kernel.org,
	axboe@kernel.dk, rusty@rustcorp.com.au, akpm@linux-foundation.org,
	ebiederm@xmission.com, tytso@mit.edu, Trond.Myklebust@netapp.com,
	aelder@sgi.com, hch@infradead.org, viro@zeniv.linux.org.uk,
	davem@davemloft.net, netdev@vger.kernel.org, x86@kernel.org,
	mingo@redhat.com, dan.j.williams@intel.com,
	borislav.petkov@amd.com, ying.huang@intel.com, lenb@kernel.org,
	neilb@suse.de, cl@linux-foundation.org
To: Frederic Weisbecker <fweisbec@gmail.com>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1751404Ab0AZBTf@vger.kernel.org>
In-Reply-To: <20100126001901.GI5087@nowhere>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 01/25/2010 04:19 PM, Frederic Weisbecker wrote:
> On Tue, Jan 26, 2010 at 12:22:14AM +0900, Tejun Heo wrote:
>> Add __percpu sparse annotations to hw_breakpoint.
>>
>> These annotations are to make sparse consider percpu variables to be
>> in a different address space and warn if accessed without going
>> through percpu accessors.  This patch doesn't affect normal builds.
>>
>> per_cpu(nr_task_bp_pinned, cpu) is replaced with
>> &per_cpu(nr_task_bp_pinned[0], cpu).  This is the same to the compiler
>> but allows per_cpu() macro to correctly drop __percpu designation for
>> the returned pointer.
> 
> Ouch... It's unpleasant to see such workaround that messes up the
> code just to make sparse happy.
> 
> I guess __percpu is an address_space attribute? Is there no
> way to force the address space change directly from the
> per_cpu() macro?
> 

Hmm... thinking more about it, we should be able to just move the & and
[0] into the per_cpu() macro, addressing the situation, or does that
cause problems elsewhere?

	-hpa
