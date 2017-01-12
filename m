From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH 5/6] treewide: use kv[mz]alloc* rather than opencoded
 variants
Date: Thu, 12 Jan 2017 18:37:46 +0100
Message-ID: <20170112173745.GC31509@dhcp22.suse.cz>
References: <20170112153717.28943-1-mhocko@kernel.org>
 <20170112153717.28943-6-mhocko@kernel.org>
 <CAGXu5jKhYP=5YNuntzmG64WL92F59VKhByOh9nqaGP7-LBEnng@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Andrew Morton <akpm@linux-foundation.org>,
	Vlastimil Babka <vbabka@suse.cz>,
	David Rientjes <rientjes@google.com>, Mel Gorman <mgorman@suse.de>,
	Johannes Weiner <hannes@cmpxchg.org>,
	Al Viro <viro@zeniv.linux.org.uk>, Linux-MM <linux-mm@kvack.org>,
	LKML <linux-kernel@vger.kernel.org>,
	Martin Schwidefsky <schwidefsky@de.ibm.com>,
	Heiko Carstens <heiko.carstens@de.ibm.com>,
	Herbert Xu <herbert@gondor.apana.org.au>,
	Anton Vorontsov <anton@enomsg.org>,
	Colin Cross <ccross@android.com>, Tony Luck <tony.luck@intel.com>,
	"Rafael J. Wysocki" <rjw@rjwysocki.net>,
	Ben Skeggs <bskeggs@redhat.com>,
	Kent Overstreet <kent.overstreet@gmail.com>,
	Santosh Raspatur <santosh@chelsio.com>,
	Hariprasad S <hariprasad@chelsio.com>,
	Tariq Toukan <tariqt@mellanox.com>,
	Yishai Hadas <yishaih@mellanox.com>,
	Dan Williams <dan.j.williams@intel.com>,
	Oleg Drokin <oleg.drokin@intel.com>,
	Andreas
To: Kees Cook <keescook@chromium.org>
Return-path: <owner-linux-mm@kvack.org>
Content-Disposition: inline
In-Reply-To: <CAGXu5jKhYP=5YNuntzmG64WL92F59VKhByOh9nqaGP7-LBEnng@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-Id: netdev.vger.kernel.org

On Thu 12-01-17 09:26:09, Kees Cook wrote:
> On Thu, Jan 12, 2017 at 7:37 AM, Michal Hocko <mhocko@kernel.org> wrote:
[...]
> > diff --git a/arch/s390/kvm/kvm-s390.c b/arch/s390/kvm/kvm-s390.c
> > index 4f74511015b8..e6bbb33d2956 100644
> > --- a/arch/s390/kvm/kvm-s390.c
> > +++ b/arch/s390/kvm/kvm-s390.c
> > @@ -1126,10 +1126,7 @@ static long kvm_s390_get_skeys(struct kvm *kvm, struct kvm_s390_skeys *args)
> >         if (args->count < 1 || args->count > KVM_S390_SKEYS_MAX)
> >                 return -EINVAL;
> >
> > -       keys = kmalloc_array(args->count, sizeof(uint8_t),
> > -                            GFP_KERNEL | __GFP_NOWARN);
> > -       if (!keys)
> > -               keys = vmalloc(sizeof(uint8_t) * args->count);
> > +       keys = kvmalloc(args->count * sizeof(uint8_t), GFP_KERNEL);
> 
> Before doing this conversion, can we add a kvmalloc_array() API? This
> conversion could allow for the reintroduction of integer overflow
> flaws. (This particular situation isn't at risk since ->count is
> checked, but I'd prefer we not create a risky set of examples for
> using kvmalloc.)

Well, I am not opposed to kvmalloc_array but I would argue that this
conversion cannot introduce new overflow issues. The code would have
to be broken already because even though kmalloc_array checks for the
overflow but vmalloc fallback doesn't...

If there is a general interest for this API I can add it.

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
