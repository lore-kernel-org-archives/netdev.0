From: Jay Vosburgh <fubar@us.ibm.com>
Subject: Re: Changing bonding <-> ifenslave interface [was: Problem with current /proc entries]
Date: Mon, 20 Oct 2003 12:12:50 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <200310201912.h9KJCo7A027272@death.ibm.com>
References: <shmulik.hen@intel.com>
Cc: bonding-devel@lists.sourceforge.net, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: shmulik.hen@intel.com
In-Reply-To: Message from Shmulik Hen <shmulik.hen@intel.com>
   of "Mon, 20 Oct 2003 20:20:57 +0200." <200310202020.57503.shmulik.hen@intel.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


[...]
>Based on the above assumptions, and on the fact that removing 
>SIOCDEVPRIVATE support from bonding in 2.6 already breaks 
>compatibility with existing ifenslave apps, we thought the sensible 
>thing to do would be to drop all support of old interfaces from 
>bonding in 2.6 (including the current SIOCBOND* ioctls), and thus 
>force users that upgrade to 2.6 to use a new ifenslave (that can be 
>found either in the 2.6 kernel tree or at sourceforge). This new 
>ifenslave will also support any 2.4 bonding.
>
>After a while, we will probably backport the new interface into the 
>2.4 bonding module, so it too will benefit from the its new 
>capabilities.

	I was leaning towards supporting existing 2.4 ifenslaves (not
the ancient ones using SIOCDEVPRIVATE, but more recent versions) so
that end users could hypothetically dabble with the 2.6 bonding
without messing with their 2.4 user space.  In that way, the 2.6 (or
"new ifenslave," if you prefer) ifenslave wouldn't have all of the old
2.4-style bonding API stuff in it.

	Anyway, I can live with the above; it does require an
ifenslave upgrade to dabble with 2.6, but as long as the 2.4
reliability isn't affected, I don't see a problem with it.

[...]
>The thing to note here is that there is no "2.6 ifenslave" and "2.4 
>ifenslave" per se. The ifenslave app lives in several places: the 
>kernel source tree, the bonding sourceforge site, the iputils RPM, 
>etc. The important thing is that updating this app should not require 
>a kernel upgrade.

	I'm having a thought here... Would it be both feasible and
reasonable to pull ifenslave.c out of the kernel source, and maintain
a separate bonding-utils package, wherein the shiny new API has some
knowledge of ifenslave versions?  In this way, the bonding kernel
driver could enforce version requirements for ifenslave, possibly at a
per-feature granularity (e.g., "need ifenslave version X for
frog-blending mode").  In this way, we'd have just one ifenslave
development line (not two), and somewhat better upgrade prospects over
time.

	In the past, I'd thought this (a bonding-utils package for
ifenslave) wasn't an especially good idea, because I didn't really see
much advantage for us in doing it.  Now, it looks like it is to our
advantage to have just one ifenslave development line, distinct from
the kernel development line (if the single ifenslave will be going
both ways there's no reason to keep two separate copies in the 2.4 and
2.6 kernel trees).

	I really do like having ifenslave right there in the kernel
source, it's very handy, but it may be better overall to pull it out
and distribute it separately.

	Comments?  Chad, you out there?  I know you really like having
ifenslave in the kernel source; what do you think about this?

	-J

---
	-Jay Vosburgh, IBM Linux Technology Center, fubar@us.ibm.com
