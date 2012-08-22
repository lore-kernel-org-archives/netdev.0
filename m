From: Ryan Mallon <rmallon@gmail.com>
Subject: Re: [PATCH v3 01/17] hashtable: introduce a small and naive hashtable
Date: Thu, 23 Aug 2012 09:54:15 +1000
Message-ID: <50357127.1000608@gmail.com>
References: <1345602432-27673-1-git-send-email-levinsasha928@gmail.com> <1345602432-27673-2-git-send-email-levinsasha928@gmail.com> <20120822180138.GA19212@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Sasha Levin <levinsasha928@gmail.com>, torvalds@linux-foundation.org,
 akpm@linux-foundation.org, linux-kernel@vger.kernel.org,
 linux-mm@kvack.org, paul.gortmaker@windriver.com, davem@davemloft.net,
 rostedt@goodmis.org, mingo@elte.hu, ebiederm@xmission.com,
 aarcange@redhat.com, ericvh@gmail.com, netdev@vger.kernel.org,
 josh@joshtriplett.org, eric.dumazet@gmail.com,
 mathieu.desnoyers@efficios.com, axboe@kernel.dk, agk@redhat.com,
 dm-devel@redhat.com, neilb@suse.de, ccaulfie@redhat.com,
 teigland@redhat.com, Trond.Myklebust@netapp.com, bfields@fieldses.org,
 fweisbec@gmail.com, jesse@nicira.com, venkat.x.venkatsubra@oracle.com,
 ejt@redhat.com, snitzer@redhat.com, edumazet@google.com,
 linux-nfs@vger.kernel.org, dev@openvswitch.org,
 rds-devel@oss.oracle.com, lw@cn.fujitsu.com
To: Tejun Heo <tj@kernel.org>
Return-path: <owner-linux-mm@kvack.org>
In-Reply-To: <20120822180138.GA19212@google.com>
Sender: owner-linux-mm@kvack.org
List-Id: netdev.vger.kernel.org

On 23/08/12 04:01, Tejun Heo wrote:
> Hello, Sasha.
> 
> On Wed, Aug 22, 2012 at 04:26:56AM +0200, Sasha Levin wrote:
>> +#define DEFINE_HASHTABLE(name, bits)					\
>> +	struct hlist_head name[HASH_SIZE(bits)];
> 
> Shouldn't this be something like the following?
> 
> #define DEFINE_HASHTABLE(name, bits)					\
> 	struct hlist_head name[HASH_SIZE(bits)] =			\
> 		{ [0 ... HASH_SIZE(bits) - 1] = HLIST_HEAD_INIT };
> 
> Also, given that the declaration isn't non-trivial, you'll probably
> want a matching DECLARE_HASHTABLE() macro too.
> 
>> +/* Use hash_32 when possible to allow for fast 32bit hashing in 64bit kernels. */
>> +#define hash_min(val, bits) ((sizeof(val)==4) ? hash_32((val), (bits)) : hash_long((val), (bits)))
> 
> Why is the branching condition sizeof(val) == 4 instead of <= 4?
> Also, no biggie but why isn't this macro in caps?

It should probably use gcc's statement expression extensions to prevent
side-effect issues with the arguments:

  #define hash_min ({		\
	sizeof(val) <= 4 ?	\
	hash_32(val, bits) :	\
	hash_long(val, bits));	\
  })

~Ryan

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
