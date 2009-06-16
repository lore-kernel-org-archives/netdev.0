From: Jouni Malinen <j@w1.fi>
Subject: Re: [RFC] Documentation: add documentation for rc-series and merge
	window
Date: Tue, 16 Jun 2009 12:34:01 +0300
Message-ID: <20090616093401.GA11602@jm.kir.nu>
References: <1245096771-3966-1-git-send-email-lrodriguez@atheros.com> <20090615201934.GA12685@kroah.com> <20090615214735.GE23972@bombadil.infradead.org> <20090615223206.GA4966@kroah.com> <20090616004122.GC5492@tesla> <20090616021011.GF23972@bombadil.infradead.org> <20090616032034.GA17932@kroah.com> <20090616042113.GA5680@tesla>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Greg KH <greg-U8xfFu+wG4EAvxtiuMwx3w@public.gmane.org>,
	Luis Rodriguez <Luis.Rodriguez-DlyHzToyqoxBDgjK7y7TUQ@public.gmane.org>,
	"corbet-T1hC0tSOHrs@public.gmane.org" <corbet-T1hC0tSOHrs@public.gmane.org>,
	"linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"torvalds-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org" <torvalds-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>,
	"akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org" <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>,
	"alan-qBU/x9rampVanCEyBjwyrvXRex20P6io@public.gmane.org" <alan-qBU/x9rampVanCEyBjwyrvXRex20P6io@public.gmane.org>,
	"linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"tshibata-zZGIbrA41Td8UrSeD/g0lQ@public.gmane.org" <tshibata-zZGIbrA41Td8UrSeD/g0lQ@public.gmane.org>,
	"mcgrof-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org" <mcgrof-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
To: "Luis R. Rodriguez" <lrodriguez-DlyHzToyqoxBDgjK7y7TUQ@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20090616042113.GA5680@tesla>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Mon, Jun 15, 2009 at 09:21:14PM -0700, Luis R. Rodriguez wrote:

> +2.0.2: RC-SERIES RULES
> +
> +Rules on what kind of patches are accepted after the merge window closes.
> +These are patches targeted for the kernel rc-series of a kernel prior
> +to its release.
> +
> + - it must fix a reported regression
> + - if must fix a reported security hole
> + - if must fix a reported oops/kernel hang


s/if/it/ twice..

Is there a good reason for documenting different rules for rc-series and
-stable releases? These three rules look stricter than the ones
described in stable_kernel_rules.txt:

 - It must fix a problem that causes a build error (but not for things
   marked CONFIG_BROKEN), an oops, a hang, data corruption, a real
   security issue, or some "oh, that's not good" issue.  In short, something
   critical.

For example, a fix for data corruption that users can hit relatively
easily sounds like a good example of something that should really be
accepted during the rc-phase even if it is not really a regression or
does not cause a kernel oops/hang.

"oh, that's not good" issue is somewhat more difficult to comment on,
but I would expect that there could be some critical issues that really
would benefit from an exception. What exactly would qualify is something
that may be not be easily described in a sentence or two, though.


The main problem I see with having a very hard line on not allowing
critical fixes (however that would be defined) during the rc-phase is
that it will take quite a long time to get the fix eventually out. As an
example, a driver could have a bug that prevents it from working with
certain subset of devices, but this is noticed only couple of kernel
releases after the initial driver merge (e.g., for hardware that was not
yet available for end users at the time the driver was initially
submitted). In other words, the issue would not be a regression, not a
security hole, and not an oops/kernel hang. However, it could make the
driver unusable to large number of users (once the affected hardware
model becomes available; say in a new laptop).

If an issue is fixed just before a start of the next merge window the
patch may not have had enough time to go through the maintainers and end
up in linux-2.6.git in time before the merge window closes. If it
weren't now allowed in during the rc-phase, it may not go into a stable
release either (assuming the rc/stable rules are more or less the same)
and we would be looking something like five month time until the fix
would actually be released in a proper kernel release. Sure,
users/distros could take in some additional patches to fix issues they
care about, but worst case scenarios of close to half a year to fix an
issue in a kernel release does not sound quite ideal.

-- 
Jouni Malinen                                            PGP id EFC895FA
--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
