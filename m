From: "Reshetova, Elena" <elena.reshetova-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
Subject: RE: [PATCH 08/29] drivers, md: convert mddev.active from atomic_t
 to refcount_t
Date: Wed, 8 Mar 2017 09:42:09 +0000
Message-ID: <2236FBA76BA1254E88B949DDB74E612B41C5606B@IRSMSX102.ger.corp.intel.com>
References: <1488810076-3754-1-git-send-email-elena.reshetova@intel.com>
 <1488810076-3754-9-git-send-email-elena.reshetova@intel.com>
 <20170307190449.baceyzzngsz776x7@kernel.org>
Reply-To: open-iscsi-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
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
	<open-iscsi-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org>, "devel-gWbeCf7V1WCQmaza687I9mD2FQJk+8+b@public.gmane.org"
	<devel-gWbeCf7V1WCQmaza687I9mD2FQJk+8+b@public.gmane.org>, "target-devel-u79uwXL29TZNg+MwTxZMZA@public.gmane.org
To: Shaohua Li <shli-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>, "gregkh-hQyY1W1yCW8ekmWlsbkhG0B+6BGkLq7r@public.gmane.org"
	<gregkh-hQyY1W1yCW8ekmWlsbkhG0B+6BGkLq7r@public.gmane.org>
Return-path: <open-iscsi+bncBCWONPVE7ANRB6VD77CQKGQEI7TI3BQ-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org>
Sender: open-iscsi-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org
In-Reply-To: <20170307190449.baceyzzngsz776x7-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Content-Language: en-US
List-Post: <https://groups.google.com/group/open-iscsi/post>, <mailto:open-iscsi-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org>
List-Help: <https://groups.google.com/support/>, <mailto:open-iscsi+help-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org>
List-Archive: <https://groups.google.com/group/open-iscsi
List-Subscribe: <https://groups.google.com/group/open-iscsi/subscribe>, <mailto:open-iscsi+subscribe-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org>
List-Unsubscribe: <mailto:googlegroups-manage+856124926423+unsubscribe-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org>,
 <https://groups.google.com/group/open-iscsi/subscribe>
List-Id: netdev.vger.kernel.org

> On Mon, Mar 06, 2017 at 04:20:55PM +0200, Elena Reshetova wrote:
> > refcount_t type and corresponding API should be
> > used instead of atomic_t when the variable is used as
> > a reference counter. This allows to avoid accidental
> > refcounter overflows that might lead to use-after-free
> > situations.
> 
> Looks good. Let me know how do you want to route the patch to upstream.

Greg, you previously mentioned that driver's conversions can go via your tree. Does this still apply?
Or should I be asking maintainers to merge these patches via their trees? 
I am not sure about the correct (and easier for everyone) way, please suggest.  

Best Regards,
Elena.
> 
> > Signed-off-by: Elena Reshetova <elena.reshetova-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
> > Signed-off-by: Hans Liljestrand <ishkamiel-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
> > Signed-off-by: Kees Cook <keescook-F7+t8E8rja9g9hUCZPvPmw@public.gmane.org>
> > Signed-off-by: David Windsor <dwindsor-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
> > ---
> >  drivers/md/md.c | 6 +++---
> >  drivers/md/md.h | 3 ++-
> >  2 files changed, 5 insertions(+), 4 deletions(-)
> >
> > diff --git a/drivers/md/md.c b/drivers/md/md.c
> > index 985374f..94c8ebf 100644
> > --- a/drivers/md/md.c
> > +++ b/drivers/md/md.c
> > @@ -449,7 +449,7 @@ EXPORT_SYMBOL(md_unplug);
> >
> >  static inline struct mddev *mddev_get(struct mddev *mddev)
> >  {
> > -	atomic_inc(&mddev->active);
> > +	refcount_inc(&mddev->active);
> >  	return mddev;
> >  }
> >
> > @@ -459,7 +459,7 @@ static void mddev_put(struct mddev *mddev)
> >  {
> >  	struct bio_set *bs = NULL;
> >
> > -	if (!atomic_dec_and_lock(&mddev->active, &all_mddevs_lock))
> > +	if (!refcount_dec_and_lock(&mddev->active, &all_mddevs_lock))
> >  		return;
> >  	if (!mddev->raid_disks && list_empty(&mddev->disks) &&
> >  	    mddev->ctime == 0 && !mddev->hold_active) {
> > @@ -495,7 +495,7 @@ void mddev_init(struct mddev *mddev)
> >  	INIT_LIST_HEAD(&mddev->all_mddevs);
> >  	setup_timer(&mddev->safemode_timer, md_safemode_timeout,
> >  		    (unsigned long) mddev);
> > -	atomic_set(&mddev->active, 1);
> > +	refcount_set(&mddev->active, 1);
> >  	atomic_set(&mddev->openers, 0);
> >  	atomic_set(&mddev->active_io, 0);
> >  	spin_lock_init(&mddev->lock);
> > diff --git a/drivers/md/md.h b/drivers/md/md.h
> > index b8859cb..4811663 100644
> > --- a/drivers/md/md.h
> > +++ b/drivers/md/md.h
> > @@ -22,6 +22,7 @@
> >  #include <linux/list.h>
> >  #include <linux/mm.h>
> >  #include <linux/mutex.h>
> > +#include <linux/refcount.h>
> >  #include <linux/timer.h>
> >  #include <linux/wait.h>
> >  #include <linux/workqueue.h>
> > @@ -360,7 +361,7 @@ struct mddev {
> >  	 */
> >  	struct mutex			open_mutex;
> >  	struct mutex			reconfig_mutex;
> > -	atomic_t			active;
> 	/* general refcount */
> > +	refcount_t			active;
> 	/* general refcount */
> >  	atomic_t			openers;	/*
> number of active opens */
> >
> >  	int
> 	changed;	/* True if we might need to
> > --
> > 2.7.4
> >
> > --
> > To unsubscribe from this list: send the line "unsubscribe linux-raid" in
> > the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
> > More majordomo info at  http://vger.kernel.org/majordomo-info.html

-- 
You received this message because you are subscribed to the Google Groups "open-iscsi" group.
To unsubscribe from this group and stop receiving emails from it, send an email to open-iscsi+unsubscribe-/JYPxA39Uh5TLH3MbocFF+G/Ez6ZCGd0@public.gmane.org
To post to this group, send email to open-iscsi-/JYPxA39Uh5TLH3MbocFF+G/Ez6ZCGd0@public.gmane.org
Visit this group at https://groups.google.com/group/open-iscsi.
For more options, visit https://groups.google.com/d/optout.
