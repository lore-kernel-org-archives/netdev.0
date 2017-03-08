From: "Reshetova, Elena" <elena.reshetova-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
Subject: RE: [PATCH 10/29] drivers, md: convert stripe_head.count from
 atomic_t to refcount_t
Date: Wed, 8 Mar 2017 09:39:30 +0000
Message-ID: <2236FBA76BA1254E88B949DDB74E612B41C56050@IRSMSX102.ger.corp.intel.com>
References: <1488810076-3754-1-git-send-email-elena.reshetova@intel.com>
 <1488810076-3754-11-git-send-email-elena.reshetova@intel.com>
 <20170307190759.jnrq66kfpkr4m7zl@kernel.org>
Reply-To: open-iscsi-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "gregkh-hQyY1W1yCW8ekmWlsbkhG0B+6BGkLq7r@public.gmane.org" <gregkh-hQyY1W1yCW8ekmWlsbkhG0B+6BGkLq7r@public.gmane.org>,
	"linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"xen-devel-GuqFBffKawtpuQazS67q72D2FQJk+8+b@public.gmane.org" <xen-devel-GuqFBffKawtpuQazS67q72D2FQJk+8+b@public.gmane.org>,
	"netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"linux1394-devel-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org"
	<linux1394-devel-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org>, "linux-bcache-u79uwXL29TY76Z2rM5mHXA@public.gmane.org"
	<linux-bcache-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, "linux-raid-u79uwXL29TY76Z2rM5mHXA@public.gmane.org"
	<linux-raid-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, "linux-media-u79uwXL29TY76Z2rM5mHXA@public.gmane.org"
	<linux-media-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, "devel-tBiZLqfeLfOHmIFyCCdPziST3g8Odh+X@public.gmane.org"
	<devel-tBiZLqfeLfOHmIFyCCdPziST3g8Odh+X@public.gmane.org>, "linux-pci-u79uwXL29TY76Z2rM5mHXA@public.gmane.org"
	<linux-pci-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, "linux-s390-u79uwXL29TY76Z2rM5mHXA@public.gmane.org"
	<linux-s390-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, "fcoe-devel-s9riP+hp16TNLxjTenLetw@public.gmane.org"
	<fcoe-devel-s9riP+hp16TNLxjTenLetw@public.gmane.org>, "linux-scsi-u79uwXL29TY76Z2rM5mHXA@public.gmane.org"
	<linux-scsi-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, "open-iscsi-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org"
	<open-iscsi-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org>, "devel-gWbeCf7V1WCQmaza687I9uG/Ez6ZCGd0@public.gmane.org
To: Shaohua Li <shli-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Return-path: <open-iscsi+bncBCWONPVE7ANRBWFC77CQKGQENLEVWYQ-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org>
Sender: open-iscsi-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org
In-Reply-To: <20170307190759.jnrq66kfpkr4m7zl-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Content-Language: en-US
List-Post: <https://groups.google.com/group/open-iscsi/post>, <mailto:open-iscsi-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org>
List-Help: <https://groups.google.com/support/>, <mailto:open-iscsi+help-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org>
List-Archive: <https://groups.google.com/group/open-iscsi
List-Subscribe: <https://groups.google.com/group/open-iscsi/subscribe>, <mailto:open-iscsi+subscribe-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org>
List-Unsubscribe: <mailto:googlegroups-manage+856124926423+unsubscribe-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org>,
 <https://groups.google.com/group/open-iscsi/subscribe>
List-Id: netdev.vger.kernel.org

> On Mon, Mar 06, 2017 at 04:20:57PM +0200, Elena Reshetova wrote:
> > refcount_t type and corresponding API should be
> > used instead of atomic_t when the variable is used as
> > a reference counter. This allows to avoid accidental
> > refcounter overflows that might lead to use-after-free
> > situations.
> >
> > Signed-off-by: Elena Reshetova <elena.reshetova-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
> > Signed-off-by: Hans Liljestrand <ishkamiel-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
> > Signed-off-by: Kees Cook <keescook-F7+t8E8rja9g9hUCZPvPmw@public.gmane.org>
> > Signed-off-by: David Windsor <dwindsor-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
> > ---
> >  drivers/md/raid5-cache.c |  8 +++---
> >  drivers/md/raid5.c       | 66 ++++++++++++++++++++++++------------------------
> >  drivers/md/raid5.h       |  3 ++-
> >  3 files changed, 39 insertions(+), 38 deletions(-)
> >
> > diff --git a/drivers/md/raid5-cache.c b/drivers/md/raid5-cache.c
> > index 3f307be..6c05e12 100644
> > --- a/drivers/md/raid5-cache.c
> > +++ b/drivers/md/raid5-cache.c
> 
> snip
> >  	       sh->check_state, sh->reconstruct_state);
> >
> >  	analyse_stripe(sh, &s);
> > @@ -4924,7 +4924,7 @@ static void activate_bit_delay(struct r5conf *conf,
> >  		struct stripe_head *sh = list_entry(head.next, struct
> stripe_head, lru);
> >  		int hash;
> >  		list_del_init(&sh->lru);
> > -		atomic_inc(&sh->count);
> > +		refcount_inc(&sh->count);
> >  		hash = sh->hash_lock_index;
> >  		__release_stripe(conf, sh,
> &temp_inactive_list[hash]);
> >  	}
> > @@ -5240,7 +5240,7 @@ static struct stripe_head *__get_priority_stripe(struct
> r5conf *conf, int group)
> >  		sh->group = NULL;
> >  	}
> >  	list_del_init(&sh->lru);
> > -	BUG_ON(atomic_inc_return(&sh->count) != 1);
> > +	BUG_ON(refcount_inc_not_zero(&sh->count));
> 
> This changes the behavior. refcount_inc_not_zero doesn't inc if original value is 0

Hm.. So, you want to inc here in any case and BUG if the end result differs from 1. 
So essentially you want to only increment here from zero to one under normal conditions... This is a challenge for refcount_t and against the design.
Is it ok just to maybe do this here:

-	BUG_ON(atomic_inc_return(&sh->count) != 1);
+	BUG_ON(refcount_read(&sh->count) != 0);
+	refcount_set((&sh->count, 1);

Do we have an issue with locking in this case? Or maybe it is then better to leave this one to be atomic_t without protection since it isn't a real refcounter as it turns out. 

Best Regards,
Elena. 

> 
> Thanks,
> Shaohua

-- 
You received this message because you are subscribed to the Google Groups "open-iscsi" group.
To unsubscribe from this group and stop receiving emails from it, send an email to open-iscsi+unsubscribe-/JYPxA39Uh5TLH3MbocFF+G/Ez6ZCGd0@public.gmane.org
To post to this group, send email to open-iscsi-/JYPxA39Uh5TLH3MbocFF+G/Ez6ZCGd0@public.gmane.org
Visit this group at https://groups.google.com/group/open-iscsi.
For more options, visit https://groups.google.com/d/optout.
