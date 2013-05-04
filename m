From: Pavel Machek <pavel-+ZI9xUNit7I@public.gmane.org>
Subject: Re: [PATCH 1/2] freezer: add unsafe versions of freezable helpers
Date: Sun, 5 May 2013 00:55:49 +0200
Message-ID: <20130504225549.GA24276@amd.pavel.ucw.cz>
References: <1367615050-3894-1-git-send-email-ccross@android.com>
 <20130504130033.GB13770@amd.pavel.ucw.cz>
 <CAMbhsRS6+hjTmrihVzgu3Dtyp8XAhJJ4VKMj=28G6xH3H73=6Q@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: lkml <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Trond Myklebust <Trond.Myklebust-HgOvQuBEEgTQT0dZR+AlfA@public.gmane.org>,
	Len Brown <len.brown-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>,
	"Rafael J. Wysocki" <rjw-KKrjLPT3xs0@public.gmane.org>,
	Peter Zijlstra <peterz-wEGCiKHe2LqWVfeAwA7xHQ@public.gmane.org>,
	Ingo Molnar <mingo-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>,
	"J. Bruce Fields" <bfields-uC3wQj2KruNg9hUCZPvPmw@public.gmane.org>,
	"David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>,
	Mandeep Singh Baines <msb-F7+t8E8rja9g9hUCZPvPmw@public.gmane.org>,
	Paul Walmsley <paul-DWxLp4Yu+b8AvxtiuMwx3w@public.gmane.org>,
	Al Viro <viro-RmSDqhL/yNMiFSDQTTA3OLVCufUGDwFn@public.gmane.org>,
	"Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>,
	Oleg Nesterov <oleg-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, linux-nfs-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	Linux PM list <linux-pm-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	Linus Torvalds <torvalds-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>,
	Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>, Ben Chan <benchan-F7+t8E8rja9g9hUCZPvPmw@public.gmane.org>
To: Colin Cross <ccross-z5hGa2qSFaRBDgjK7y7TUQ@public.gmane.org>
Return-path: <linux-nfs-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <CAMbhsRS6+hjTmrihVzgu3Dtyp8XAhJJ4VKMj=28G6xH3H73=6Q-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
Sender: linux-nfs-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Hi!

> >> NFS calls the freezable helpers with locks held, which is unsafe
> >> and caused lockdep warnings when 6aa9707 "lockdep: check that no
> >> locks held at freeze time" was applied (reverted in dbf520a).
> >> Add new *_unsafe versions of the helpers that will not run the
> >> lockdep test when 6aa9707 is reapplied, and call them from NFS.
> >>
> >> Signed-off-by: Colin Cross <ccross-z5hGa2qSFaRBDgjK7y7TUQ@public.gmane.org>
> >
> > Looks mostly good.
> >
> >> @@ -152,6 +169,14 @@ static inline bool freezer_should_skip(struct task_struct *p)
> >>       freezer_count();                                                \
> >>  })
> >>
> >> +/* DO NOT ADD ANY NEW CALLERS OF THIS FUNCTION */
> >> +#define freezable_schedule_unsafe()                                  \
> >> +({                                                                   \
> >> +     freezer_do_not_count();                                         \
> >> +     schedule();                                                     \
> >> +     freezer_count_unsafe();                                         \
> >> +})
> >> +
> >
> > Make it inline function? :-). Add short explanation why it is good
> > idea?
> 
> These are exact copies of the existing non-unsafe versions, except
> they call freezer_count_unsafe() instead of freezer_count().  The next
> version of my other patch stack that goes on top of this has a patch
> to convert the macros in this file to static inline functions (at
> least the ones that can be).  I'd rather not mix it in with this patch
> for ease of comparison with the existing calls.

Ok.

Acked-by: Pavel Machek <pavel-+ZI9xUNit7I@public.gmane.org>

-- 
(english) http://www.livejournal.com/~pavelmachek
(cesky, pictures) http://atrey.karlin.mff.cuni.cz/~pavel/picture/horses/blog.html
--
To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
