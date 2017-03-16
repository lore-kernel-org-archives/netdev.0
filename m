From: "Reshetova, Elena" <elena.reshetova-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
Subject: RE: [PATCH 08/29] drivers, md: convert mddev.active from atomic_t
 to refcount_t
Date: Thu, 16 Mar 2017 18:00:07 +0000
Message-ID: <2236FBA76BA1254E88B949DDB74E612B41C59FF8@IRSMSX102.ger.corp.intel.com>
References: <1488810076-3754-1-git-send-email-elena.reshetova@intel.com>
	 <1488810076-3754-9-git-send-email-elena.reshetova@intel.com>
	 <87lgs8ukfq.fsf@concordia.ellerman.id.au>
	 <2236FBA76BA1254E88B949DDB74E612B41C588E8@IRSMSX102.ger.corp.intel.com>
 <1489503539.3214.17.camel@HansenPartnership.com>
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
To: James Bottomley <James.Bottomley-d9PhHud1JfjCXq6kfMZ53/egYHeGw8Jk@public.gmane.org>, Michael Ellerman
	<mpe-Gsx/Oe8HsFggBc27wqDAHg@public.gmane.org>, "gregkh-hQyY1W1yCW8ekmWlsbkhG0B+6BGkLq7r@public.gmane.org"
	<gregkh-hQyY1W1yCW8ekmWlsbkhG0B+6BGkLq7r@public.gmane.org>
Return-path: <open-iscsi+bncBCWONPVE7ANRBLVFVPDAKGQEK762NQQ-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org>
Sender: open-iscsi-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org
In-Reply-To: <1489503539.3214.17.camel-d9PhHud1JfjCXq6kfMZ53/egYHeGw8Jk@public.gmane.org>
Content-Language: en-US
List-Post: <https://groups.google.com/group/open-iscsi/post>, <mailto:open-iscsi-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org>
List-Help: <https://groups.google.com/support/>, <mailto:open-iscsi+help-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org>
List-Archive: <https://groups.google.com/group/open-iscsi
List-Subscribe: <https://groups.google.com/group/open-iscsi/subscribe>, <mailto:open-iscsi+subscribe-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org>
List-Unsubscribe: <mailto:googlegroups-manage+856124926423+unsubscribe-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org>,
 <https://groups.google.com/group/open-iscsi/subscribe>
List-Id: netdev.vger.kernel.org

> On Tue, 2017-03-14 at 12:29 +0000, Reshetova, Elena wrote:
> > > Elena Reshetova <elena.reshetova-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org> writes:
> > >
> > > > refcount_t type and corresponding API should be
> > > > used instead of atomic_t when the variable is used as
> > > > a reference counter. This allows to avoid accidental
> > > > refcounter overflows that might lead to use-after-free
> > > > situations.
> > > >
> > > > Signed-off-by: Elena Reshetova <elena.reshetova-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
> > > > Signed-off-by: Hans Liljestrand <ishkamiel-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
> > > > Signed-off-by: Kees Cook <keescook-F7+t8E8rja9g9hUCZPvPmw@public.gmane.org>
> > > > Signed-off-by: David Windsor <dwindsor-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
> > > > ---
> > > >  drivers/md/md.c | 6 +++---
> > > >  drivers/md/md.h | 3 ++-
> > > >  2 files changed, 5 insertions(+), 4 deletions(-)
> > >
> > > When booting linux-next (specifically 5be4921c9958ec) I'm seeing
> > > the
> > > backtrace below. I suspect this patch is just exposing an existing
> > > issue?
> >
> > Yes, we have actually been following this issue in the another
> > thread.
> > It looks like the object is re-used somehow, but I can't quite
> > understand how just by reading the code.
> > This was what I put into the previous thread:
> >
> > "The log below indicates that you are using your refcounter in a bit
> > weird way in mddev_find().
> > However, I can't find the place (just by reading the code) where you
> > would increment refcounter from zero (vs. setting it to one).
> > It looks like you either iterate over existing nodes (and increment
> > their counters, which should be >= 1 at the time of increment) or
> > create a new node, but then mddev_init() sets the counter to 1. "
> >
> > If you can help to understand what is going on with the object
> > creation/destruction, would be appreciated!
> >
> > Also Shaohua Li stopped this patch coming from his tree since the
> > issue was caught at that time, so we are not going to merge this
> > until we figure it out.
> 
> Asking on the correct list (dm-devel) would have got you the easy
> answer:  The refcount behind mddev->active is a genuine atomic.  It has
> refcount properties but only if the array fails to initialise (in that
> case, final put kills it).  Once it's added to the system as a gendisk,
> it cannot be freed until md_free().  Thus its ->active count can go to
> zero (when it becomes inactive; usually because of an unmount). On a
> simple allocation regardless of outcome, the last executed statement in
> md_alloc is mddev_put(): that destroys the device if we didn't manage
> to create it or returns 0 and adds an inactive device to the system
> which the user can get with mddev_find().

Thank you James for explaining this! I guess in this case, the conversion doesn't make sense. 
And sorry about not asking in a correct place: we are handling many similar patches now and while I try to reach the right audience using get_maintainer script, it doesn't always succeeds. 

Best Regards,
Elena.

> 
> James
> 

-- 
You received this message because you are subscribed to the Google Groups "open-iscsi" group.
To unsubscribe from this group and stop receiving emails from it, send an email to open-iscsi+unsubscribe-/JYPxA39Uh5TLH3MbocFF+G/Ez6ZCGd0@public.gmane.org
To post to this group, send email to open-iscsi-/JYPxA39Uh5TLH3MbocFF+G/Ez6ZCGd0@public.gmane.org
Visit this group at https://groups.google.com/group/open-iscsi.
For more options, visit https://groups.google.com/d/optout.
