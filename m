From: "Serge E. Hallyn" <serge.hallyn@canonical.com>
Subject: Re: [PATCH 01/15] add Documentation/namespaces/user_namespace.txt
 (v3)
Date: Fri, 9 Sep 2011 08:10:45 -0500
Message-ID: <20110909131045.GB3476@sergelap>
References: <1314993400-6910-1-git-send-email-serge@hallyn.com>
 <1314993400-6910-4-git-send-email-serge@hallyn.com>
 <20110907155024.42e3fe27.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Serge Hallyn <serge@hallyn.com>, segooon@gmail.com,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	containers@lists.linux-foundation.org, dhowells@redhat.com,
	ebiederm@xmission.com, rdunlap@xenotime.net
To: Andrew Morton <akpm@linux-foundation.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20110907155024.42e3fe27.akpm@linux-foundation.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Quoting Andrew Morton (akpm@linux-foundation.org):
> On Fri,  2 Sep 2011 19:56:26 +0000
> Serge Hallyn <serge@hallyn.com> wrote:
> 
> > +Note that this userid mapping for the VFS is not yet implemented, though the
> > +lkml and containers mailing list archives will show several previous
> > +prototypes.  In the end, those got hung up waiting on the concept of targeted
> > +capabilities to be developed, which, thanks to the insight of Eric Biederman,
> > +they finally did.
> 
> not-yet-implemented things worry me.  When can we expect this to
> happen, and how big and ugly will it be?

Hi Andrew,

We did a proof of concept of the simplest version of this in early August
(see git://git.kernel.org/pub/scm/linux/kernel/git/ebiederm/linux-userns-devel.git)
which actually was very un-scary.  So technically we could push it at the
same time as this set, but I thought that might just be too much for
review in one cycle.  That set (Eric's) is the very simplest approach
which tags an entire filesystem with a user namespace.

We would also want to pursue the more baroque approach, where filesystems
themselves are user-namespace aware.  I did an approach like that in
2008, see
https://lists.linux-foundation.org/pipermail/containers/2008-August/012679.html
It again is very do-able without being ugly, but, importantly, user
namespaces are usable for containers without that.  For starters, we only
need /proc and /sys to be user namespace aware (since they must allow
access from multiple namespaces), and that is simple as they are not
persistent.

So I believe that this is the last scary patchset, and that user
namespaces could actually be usable by the end of the year!

> I'm not seeing many (any) reviewed-by's on these patches.  I could get
> down and stare at them myself, but that wouldn't be very useful.  This
> work goes pretty deep and is quite security-affecting.  And network-afecting.
> Can you round up some suitable people and get the reviewing and testing happening
> please?

Will try.  Unfortunately I missed my chance to beg and bribe people in
person at plumbers :(

thanks,
-serge
