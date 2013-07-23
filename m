From: Pavel Machek <pavel-+ZI9xUNit7I@public.gmane.org>
Subject: Re: 3.11-rc regression bisected: s2disk does not work (was Re:
 [PATCH v3 13/16] futex: use freezable blocking call)
Date: Tue, 23 Jul 2013 02:26:28 +0200
Message-ID: <20130723002627.GA11751@amd.pavel.ucw.cz>
References: <1367884221-20462-1-git-send-email-ccross@android.com>
 <1367884221-20462-14-git-send-email-ccross@android.com>
 <20130723010250.5a3465ec@xenia.leun.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Colin Cross <ccross-z5hGa2qSFaRBDgjK7y7TUQ@public.gmane.org>, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	"Rafael J. Wysocki" <rjw-KKrjLPT3xs0@public.gmane.org>,
	Peter Zijlstra <peterz-wEGCiKHe2LqWVfeAwA7xHQ@public.gmane.org>,
	Ingo Molnar <mingo-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>,
	Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>,
	Mandeep Singh Baines <msb-F7+t8E8rja9g9hUCZPvPmw@public.gmane.org>,
	Oleg Nesterov <oleg-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, linux-nfs-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-pm-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	Linus Torvalds <torvalds-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>,
	Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>,
	Darren Hart <dvhart-VuQAYsv1563Yd54FQh9/CA@public.gmane.org>,
	Thomas Gleixner <tglx-hfZtesqFncYOwBW4kG4KsQ@public.gmane.org>,
	Randy Dunlap <rdunlap-wEGCiKHe2LqWVfeAwA7xHQ@public.gmane.org>,
	Al Viro <viro-RmSDqhL/yNMiFSDQTTA3OLVCufUGDwFn@public.gmane.org>
To: Michael Leun <lkml20130126-yS7QfQBdiAdyjo5WHAzKoQ@public.gmane.org>
Return-path: <linux-nfs-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20130723010250.5a3465ec-gjVD6BTPoEbYa4IuQwzu8g@public.gmane.org>
Sender: linux-nfs-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Tue 2013-07-23 01:02:50, Michael Leun wrote:
> On Mon,  6 May 2013 16:50:18 -0700
> Colin Cross <ccross-z5hGa2qSFaRBDgjK7y7TUQ@public.gmane.org> wrote:
> 
> > Avoid waking up every thread sleeping in a futex_wait call during
> [...]
> 
> With 3.11-rc s2disk from suspend-utils stopped working: Frozen at
> displaying 0% of saving image to disk.
> 
> echo "1" >/sys/power/state still works.
> 
> Bisecting yielded 88c8004fd3a5fdd2378069de86b90b21110d33a4, reverting
> that from 3.11-rc2 makes s2disk working again.

Would id be possible to get all the backtraces using magic sysrq?

...actually...

I see what could happen. Before, system hibernated in state where all
the futexes were unlocked. Now, it can happen that we attempt s2disk
with futex held. s2disk should not depend on other parts of userspace,
and should not take futexes, but maybe it does...?
								Pavel
-- 
(english) http://www.livejournal.com/~pavelmachek
(cesky, pictures) http://atrey.karlin.mff.cuni.cz/~pavel/picture/horses/blog.html
--
To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
