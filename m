From: Shmulik Hen <shmulik.hen@intel.com>
Subject: Re: Changing bonding <-> ifenslave interface [was: Problem with current /proc entries]
Date: Mon, 20 Oct 2003 20:20:57 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <200310202020.57503.shmulik.hen@intel.com>
References: <E791C176A6139242A988ABA8B3D9B38A02A4651C@hasmsx403.iil.intel.com>
Reply-To: shmulik.hen@intel.com
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 8bit
Cc: <bonding-devel@lists.sourceforge.net>, <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: "Jay Vosburgh" <fubar@us.ibm.com>
In-Reply-To: <E791C176A6139242A988ABA8B3D9B38A02A4651C@hasmsx403.iil.intel.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Monday 20 October 2003 06:42 pm, Jay Vosburgh wrote:
>
> >I disagree. I think that the latest version of ifenslave should
> > work with all versions of the bonding module that we can
> > reasonably expect people to use. This means that if ifenslave
> > fails to use the new interface it can try the old one. (This is
> > how I understood Jeff's position).
>
>         When we discussed this previously, my understanding was:
>
>         An ifenslave only had to work forwards, it didn't need to
> go backwards.  So, an ifenslave from 2.4.X would run on that
> version, as well as any future 2.4.Y (where Y > X).  But, the
> reverse isn't true: ifenslave from 2.4.Y need not work on kernel
> 2.4.X (again, Y > X).

Suppose a user updates an application package (in this case iputils). 
It seems unreasonable to require a kernel upgrade to make the updated 
app work.

Likewise, if the user updates the kernel, existing apps should still 
work. The sole exception is when switching major kernel versions (and 
even this should be avoided where possible). This is similar to the 
modutils package that has to be updated to work with 2.6. (and once 
updated it works with 2.4 as well).

This is how we've understood Jeff's approach when the ABI issue was 
first raised:
[From <http://sourceforge.net/mailarchive/message.php?msg_id=4875256>]
    On 12 May 2003, Jeff Garzik wrote:
    > FWIW the main worry is users booting into "new bonding" and "old
    > bonding" kernels, with the same userspace.  (which of course
    > implies an ifenslave userspace upgrade, but that's ok)


Based on the above assumptions, and on the fact that removing 
SIOCDEVPRIVATE support from bonding in 2.6 already breaks 
compatibility with existing ifenslave apps, we thought the sensible 
thing to do would be to drop all support of old interfaces from 
bonding in 2.6 (including the current SIOCBOND* ioctls), and thus 
force users that upgrade to 2.6 to use a new ifenslave (that can be 
found either in the 2.6 kernel tree or at sourceforge). This new 
ifenslave will also support any 2.4 bonding.

After a while, we will probably backport the new interface into the 
2.4 bonding module, so it too will benefit from the its new 
capabilities.

>         Applying this to 2.6, a 2.6 ifenslave shouldn't need to
> control a 2.4 bonding driver, but a 2.4 ifenslave should control a
> 2.6 kernel (for reasonable ranges of 2.4.X, in particular excluding
> SIOCDEVPRIVATE).
>
>         I was thinking that the 2.4 ifenslave should work with 2.4
> or 2.6 (including the new shiny API, to make kernel upgrades less
> hassle), but the 2.6 ifenslave need not work with 2.4, so we could
> hopefully vacuum it clean of the various ABI gook once we have a
> new shiny interface.  The 2.6 ifenslave presumably won't be
> included in a distro until they ship a 2.6 kernel, so that would
> theoretically be sufficient.

The thing to note here is that there is no "2.6 ifenslave" and "2.4 
ifenslave" per se. The ifenslave app lives in several places: the 
kernel source tree, the bonding sourceforge site, the iputils RPM, 
etc. The important thing is that updating this app should not require 
a kernel upgrade.

> >We can probably provide a version of bonding/ifenslave that works
> > with the new interface within two weeks (hopefully less). This
> > is, of course, assuming we reach a consensus on the compatibility
> > issue.
>
>         Would that be dependant upon the cleanup stuff, or not?

Yes, it will. We do all our code developement on top of the cleanup 
stuff.

-- 
| Shmulik Hen   Advanced Network Services  |
| Israel Design Center, Jerusalem          |
| LAN Access Division, Platform Networking |
| Intel Communications Group, Intel corp.  |
