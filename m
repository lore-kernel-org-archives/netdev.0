From: Mathieu Desnoyers <mathieu.desnoyers-vg+e7yoeK/dWk0Htik3J/w@public.gmane.org>
Subject: Re: [PATCH v7 06/16] tracepoint: use new hashtable
	implementation
Date: Mon, 29 Oct 2012 14:53:19 -0400
Message-ID: <20121029185319.GA21546@Krystal>
References: <1351450948-15618-1-git-send-email-levinsasha928@gmail.com>
	<1351450948-15618-6-git-send-email-levinsasha928@gmail.com>
	<20121029113515.GB9115@Krystal>
	<CA+1xoqce6uJ6wy3+2CBwsLHKnsz4wD0vt8MBEGKCFfXTvuC0Hg@mail.gmail.com>
	<20121029183157.GC3097@jtriplet-mobl1>
	<CA+1xoqfMrn9zDFMJNFfA0NA86wE_DedD97cP1yJ2UQdTjs3uyQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: snitzer-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, neilb-l3A5Bk7waGM@public.gmane.org, fweisbec-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org,
	Trond.Myklebust-HgOvQuBEEgTQT0dZR+AlfA@public.gmane.org, bfields-uC3wQj2KruNg9hUCZPvPmw@public.gmane.org,
	paul.gortmaker-CWA4WttNNZF54TAoqtyWWQ@public.gmane.org, dm-devel-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org,
	agk-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, aarcange-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, rds-devel-N0ozoZBvEnrZJqsBc5GL+g@public.gmane.org,
	eric.dumazet-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, venkat.x.venkatsubra-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org,
	ccaulfie-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, mingo-X9Un+BFzKDI@public.gmane.org, dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org,
	ericvh-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, Josh Triplett <josh-iaAMLnmF4UmaiuxdJuQwMA@public.gmane.org>,
	rostedt-nx8X9YLhiw1AfugRpC6u6w@public.gmane.org, lw-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org, teigland-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org,
	axboe-tSWWG44O7X1aa/9Udqfwiw@public.gmane.org, linux-nfs-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, edumazet-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org,
	linux-mm-Bw31MaZKKs3YtjvyW6yDsg@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, ejt-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org,
	ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org, tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org, akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org,
	torvalds-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org, davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org
To: Sasha Levin <levinsasha928-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Return-path: <dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <CA+1xoqfMrn9zDFMJNFfA0NA86wE_DedD97cP1yJ2UQdTjs3uyQ-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
List-Unsubscribe: <http://openvswitch.org/mailman/options/dev>,
	<mailto:dev-request-yBygre7rU0TnMu66kgdUjQ@public.gmane.org?subject=unsubscribe>
List-Archive: <http://openvswitch.org/pipermail/dev>
List-Post: <mailto:dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>
List-Help: <mailto:dev-request-yBygre7rU0TnMu66kgdUjQ@public.gmane.org?subject=help>
List-Subscribe: <http://openvswitch.org/mailman/listinfo/dev>,
	<mailto:dev-request-yBygre7rU0TnMu66kgdUjQ@public.gmane.org?subject=subscribe>
Sender: dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org
Errors-To: dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org
List-Id: netdev.vger.kernel.org

* Sasha Levin (levinsasha928-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org) wrote:
> On Mon, Oct 29, 2012 at 2:31 PM, Josh Triplett <josh-iaAMLnmF4UmaiuxdJuQwMA@public.gmane.org> wrote:
> > On Mon, Oct 29, 2012 at 01:29:24PM -0400, Sasha Levin wrote:
> >> On Mon, Oct 29, 2012 at 7:35 AM, Mathieu Desnoyers
> >> <mathieu.desnoyers-vg+e7yoeK/dWk0Htik3J/w@public.gmane.org> wrote:
> >> > * Sasha Levin (levinsasha928-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org) wrote:
> >> >> Switch tracepoints to use the new hashtable implementation. This reduces the amount of
> >> >> generic unrelated code in the tracepoints.
> >> >>
> >> >> Signed-off-by: Sasha Levin <levinsasha928-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
> >> >> ---
> >> >>  kernel/tracepoint.c | 27 +++++++++++----------------
> >> >>  1 file changed, 11 insertions(+), 16 deletions(-)
> >> >>
> >> >> diff --git a/kernel/tracepoint.c b/kernel/tracepoint.c
> >> >> index d96ba22..854df92 100644
> >> >> --- a/kernel/tracepoint.c
> >> >> +++ b/kernel/tracepoint.c
> >> >> @@ -26,6 +26,7 @@
> >> >>  #include <linux/slab.h>
> >> >>  #include <linux/sched.h>
> >> >>  #include <linux/static_key.h>
> >> >> +#include <linux/hashtable.h>
> >> >>
> >> >>  extern struct tracepoint * const __start___tracepoints_ptrs[];
> >> >>  extern struct tracepoint * const __stop___tracepoints_ptrs[];
> >> >> @@ -49,8 +50,7 @@ static LIST_HEAD(tracepoint_module_list);
> >> >>   * Protected by tracepoints_mutex.
> >> >>   */
> >> >>  #define TRACEPOINT_HASH_BITS 6
> >> >> -#define TRACEPOINT_TABLE_SIZE (1 << TRACEPOINT_HASH_BITS)
> >> >> -static struct hlist_head tracepoint_table[TRACEPOINT_TABLE_SIZE];
> >> >> +static DEFINE_HASHTABLE(tracepoint_table, TRACEPOINT_HASH_BITS);
> >> >>
> >> > [...]
> >> >>
> >> >> @@ -722,6 +715,8 @@ struct notifier_block tracepoint_module_nb = {
> >> >>
> >> >>  static int init_tracepoints(void)
> >> >>  {
> >> >> +     hash_init(tracepoint_table);
> >> >> +
> >> >>       return register_module_notifier(&tracepoint_module_nb);
> >> >>  }
> >> >>  __initcall(init_tracepoints);
> >> >
> >> > So we have a hash table defined in .bss (therefore entirely initialized
> >> > to NULL), and you add a call to "hash_init", which iterates on the whole
> >> > array and initialize it to NULL (again) ?
> >> >
> >> > This extra initialization is redundant. I think it should be removed
> >> > from here, and hashtable.h should document that hash_init() don't need
> >> > to be called on zeroed memory (which includes static/global variables,
> >> > kzalloc'd memory, etc).
> >>
> >> This was discussed in the previous series, the conclusion was to call
> >> hash_init() either way to keep the encapsulation and consistency.
> >>
> >> It's cheap enough and happens only once, so why not?
> >
> > Unnecessary work adds up.  Better not to do it unnecessarily, even if by
> > itself it doesn't cost that much.
> >
> > It doesn't seem that difficult for future fields to have 0 as their
> > initialized state.
> 
> Let's put it this way: hlist requires the user to initialize hlist
> head before usage, therefore as a hlist user, hashtable implementation
> must do that.
> 
> We do it automatically when the hashtable user does
> DEFINE_HASHTABLE(), but we can't do that if he does
> DECLARE_HASHTABLE(). This means that the hashtable user must call
> hash_init() whenever he uses DECLARE_HASHTABLE() to create his
> hashtable.
> 
> There are two options here, either we specify that hash_init() should
> only be called if DECLARE_HASHTABLE() was called, which is confusing,
> inconsistent and prone to errors, or we can just say that it should be
> called whenever a hashtable is used.
> 
> The only way to work around it IMO is to get hlist to not require
> initializing before usage, and there are good reasons that that won't
> happen.

Hrm, just a second here.

The argument about hash_init being useful to add magic values in the
future only works for the cases where a hash table is declared with
DECLARE_HASHTABLE(). It's completely pointless with DEFINE_HASHTABLE(),
because we could initialize any debugging variables from within
DEFINE_HASHTABLE().

So I take my "Agreed" back. I disagree with initializing the hash table
twice redundantly. There should be at least "DEFINE_HASHTABLE()" or a
hash_init() (for DECLARE_HASHTABLE()), but not useless execution
initialization on top of an already statically initialized hash table.

Thanks,

Mathieu

-- 
Mathieu Desnoyers
Operating System Efficiency R&D Consultant
EfficiOS Inc.
http://www.efficios.com
