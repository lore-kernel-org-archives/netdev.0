From: Jay Vosburgh <fubar@us.ibm.com>
Subject: Re: [Bonding-devel] Re: [bonding] compatibilty issues
Date: Tue, 30 Sep 2003 09:39:52 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <200309301639.h8UGdqCq026858@death.ibm.com>
References: <shmulik.hen@intel.com>
Cc: "David S. Miller" <davem@redhat.com>, "Jeff Garzik" <jgarzik@pobox.com>,
        chad@tindel.net, bonding-devel@lists.sourceforge.net,
        netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: shmulik.hen@intel.com
In-Reply-To: Message from Shmulik Hen <shmulik.hen@intel.com>
   of "Tue, 30 Sep 2003 14:42:31 +0300." <200309301442.31991.shmulik.hen@intel.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


>I'm going to need a ruling here :)
>Re-creating those 19 trees each time is killing me and I would like to 
>reduce the number of iterations to a minimum.

	I say:

	Toast the whatever_OLD guys (the backwards compat ioctls) in
both 2.4 and 2.6.  Backwards compatibility is good, but there are
limits, and I think these have reached their limit.

	Keep the ABI versioning stuff in both 2.4 and 2.6.  As I've
said, that slimmed down ifenslave really makes my mouth water in
anticipation, but I don't think we can escape our fate that easily
just yet.  Someday....

	Any comments from the usual gang?

>I'm currently working on putting back all compatibility stuff for 2.4. 
>I would like to also get any input/reservations about other issues 
>(besides compatibility and the multicast param) so I may get a chance 
>to get them all in at once.

	I'm still looking through the patch set; I generally like what
I see, and think it's probably all good to go for 2.6 (modulo the
various changes we're discussing).  I was thinking the same for 2.4,
but then I had a long chat with Chad, and now he's got me worried
about potential stability problems from such a large set of changes.

	I'm wondering if we should apply the set to 2.6 first, and
give it some air time in that environment before going on to 2.4.

	The only nit I have thus far is that you need to remove the
documentation for multicast_mode along with the option (which I've
mentioned before somewhere; just reminding, not whining).  Or perhaps
better, leave some text explaining that the option is no longer
supported (and why).  Chad and I were discussing whether or not we
should leave a dummy option (that silently does nothing, or prints
some sort of useful message) so that end users don't get a warning if
they supply a multicast_mode module parameter.  If there is no
paramter at all, users get a warning from modprobe (or insmod or
somewhere) that the option does not exist, but the insmod does
complete.

	Another possibility would be a parameter that does nothing,
unless the user selects a setting that conflicts with the calculated
choice.  In that case, fail the insmod.  This way, end users won't get
a warning as long as they're doing the right thing.  I haven't decided
if I like this idea just because it seems kind of clever, or because
it would actually be the right thing to do.

>Once we get that settled, I can start working on a 2.6 version that 
>also handles any compatibility issues (preferrably as the last patch 
>of the series). I'm working in the assumption that 2.4-2.6 similarity 
>is no longer an option for bonding.

	Unfortunately, no, it doesn't seem to be feasible to keep the
2.4 and 2.6 source bases identical (which I was pretty jazzed about).
I still want to try to keep them as close as is reasonable, which is
why I'd like to put the full cleanup set into 2.4 if we can.

	-J

---
	-Jay Vosburgh, IBM Linux Technology Center, fubar@us.ibm.com
