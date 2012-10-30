From: Tejun Heo <tj@kernel.org>
Subject: Re: [PATCH v8 01/16] hashtable: introduce a small and naive hashtable
Date: Tue, 30 Oct 2012 14:42:57 -0700
Message-ID: <20121030214257.GB2681@htj.dyndns.org>
References: <1351622772-16400-1-git-send-email-levinsasha928@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: torvalds@linux-foundation.org, akpm@linux-foundation.org,
	linux-kernel@vger.kernel.org, linux-mm@kvack.org,
	paul.gortmaker@windriver.com, davem@davemloft.net,
	rostedt@goodmis.org, mingo@elte.hu, ebiederm@xmission.com,
	aarcange@redhat.com, ericvh@gmail.com, netdev@vger.kernel.org,
	josh@joshtriplett.org, eric.dumazet@gmail.com,
	mathieu.desnoyers@efficios.com, axboe@kernel.dk, agk@redhat.com,
	dm-devel@redhat.com, neilb@suse.de, ccaulfie@redhat.com,
	teigland@redhat.com, Trond.Myklebust@netapp.com,
	bfields@fieldses.org, fweisbec@gmail.com, jesse@nicira.com,
	venkat.x.venkatsubra@oracle.com, ejt@redhat.com, snitzer@redhat.com,
	edumazet@google.com, linux-nfs@vger.kernel.org, dev@openvswitch.org,
	rds-devel@oss.oracle.com, lw@cn.fujitsu.com
To: Sasha Levin <levinsasha928@gmail.com>
Return-path: <owner-linux-mm@kvack.org>
Content-Disposition: inline
In-Reply-To: <1351622772-16400-1-git-send-email-levinsasha928@gmail.com>
Sender: owner-linux-mm@kvack.org
List-Id: netdev.vger.kernel.org

Hello,

Just some nitpicks.

On Tue, Oct 30, 2012 at 02:45:57PM -0400, Sasha Levin wrote:
> +/* Use hash_32 when possible to allow for fast 32bit hashing in 64bit kernels. */
> +#define hash_min(val, bits)							\
> +({										\
> +	sizeof(val) <= 4 ?							\
> +	hash_32(val, bits) :							\
> +	hash_long(val, bits);							\
> +})

Doesn't the above fit in 80 column.  Why is it broken into multiple
lines?  Also, you probably want () around at least @val.  In general,
it's a good idea to add () around any macro argument to avoid nasty
surprises.

Looks good to me otherwise.

 Reviewed-by: Tejun Heo <tj@kernel.org>

Thanks.

-- 
tejun

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
