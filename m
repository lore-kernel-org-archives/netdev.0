From: Jay Vosburgh <fubar@us.ibm.com>
Subject: Re: Changing bonding <-> ifenslave interface [was: Problem with current /proc entries]
Date: Mon, 20 Oct 2003 09:42:22 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <200310201642.h9KGgMXp027089@death.ibm.com>
References: <amir.noam@intel.com>
Cc: bonding-devel@lists.sourceforge.net, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "Noam, Amir" <amir.noam@intel.com>
In-Reply-To: Message from "Noam, Amir" <amir.noam@intel.com>
   of "Sun, 19 Oct 2003 17:56:01 +0200." <E6F7D288B394A64585E67497E5126BA601EB5067@hasmsx403.iil.intel.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


	The "To clarify, I'm interpreting" comments are mine (3 ">");
Chad's are one up and down (2 and 4 ">").

>"Chad N. Tindel" <chad@tindel.net> wrote:
>
>>  > >I say that if people want to switch between 2.4 and 2.6, they can
>>  > >write a script to create the appropriate ifenslave symbolic link.
>>  > 
>>  > 	To clarify, I'm interpreting this to mean:
>>  > 
>>  > 	2.4.X ifenslave (where "X" is recent enough that it doesn't
>>  > use SIOCDEVPRIVATE) should work with 2.6.anything.
>
>I disagree. See below.
>
>>  > 	2.4.X ifenslave (where "X" is old and it uses SIOCDEVPRIVATE)
>>  > need not work with 2.6.anything.
>>  > 
>>  > 	2.6.X ifenslave (where "X" is 0 or better) should work with
>>  > any 2.6 later than the one it was shipped with.
>
>Yes.
>
>>  > 	2.6.X ifenslave (where "X" is 0 or better) need not work with
>>  > 2.4.anything.
>
>I disagree. I think that the latest version of ifenslave should work
>with all versions of the bonding module that we can reasonably expect
>people to use. This means that if ifenslave fails to use the new
>interface it can try the old one. (This is how I understood Jeff's
>position).

	When we discussed this previously, my understanding was:

	An ifenslave only had to work forwards, it didn't need to go
backwards.  So, an ifenslave from 2.4.X would run on that version, as
well as any future 2.4.Y (where Y > X).  But, the reverse isn't true:
ifenslave from 2.4.Y need not work on kernel 2.4.X (again, Y > X).

	Applying this to 2.6, a 2.6 ifenslave shouldn't need to
control a 2.4 bonding driver, but a 2.4 ifenslave should control a 2.6
kernel (for reasonable ranges of 2.4.X, in particular excluding
SIOCDEVPRIVATE).

	I was thinking that the 2.4 ifenslave should work with 2.4 or
2.6 (including the new shiny API, to make kernel upgrades less
hassle), but the 2.6 ifenslave need not work with 2.4, so we could
hopefully vacuum it clean of the various ABI gook once we have a new
shiny interface.  The 2.6 ifenslave presumably won't be included in a
distro until they ship a 2.6 kernel, so that would theoretically be
sufficient.

>However, I'm definitely in favor of dropping compatibility in the
>*module* in 2.6. This is because most recent distributions (Red Hat 9,
>for example) still use an antique version of ifenslave that still uses
>the SIOCDEVPRIVATE ioctls. If we remove support for these ioctls in
>2.6 (as we should), then the bonding module will break compatibility
>with those ifenslave versions anyway. I see no point in trying to keep
>compatibility with the ifenslave version that is in the 2.4 kernel
>tree, while it is not yet in use by any distribution.

	When you say "dropping compatibility" are you just referring
to the SIOCDEVPRIVATE ioctls, or the full "old style" ifenslave to
bonding API (which would be replaced by the new shiny interface you
were talking about earlier)?

>>  My opinion is this.  What has worked in 2.4 in the past 
>>  should always work
>>  for 2.4.  Once you upgrade to 2.6, all bets for that are off.  
>
>I agree, except that I think that if you upgrade to 2.6, and update
>your ifenslave accordingly, you shouldn't have to switch user space
>utilities when you boot into different kernels. That's why I said that
>once you update ifenslave it should work with old bonding as well.

	As I said above, I don't think we need to put ourselves in the
position of supporting both backwards compatibility (old ifenslave,
new bonding) and forwards compatibility (new ifenslave, old bonding).

	I'm thinking we should give the 2.4 ifenslave the "shiny new
API" stuff (which is only applicable to the 2.6 bonding driver) so
that it'll run with 2.6 for the forseeable future, and then excise the
existing API from 2.6 (realistically, at some point in the future,
probably when 2.6 becomes "the standard").

	Comments?

>We can probably provide a version of bonding/ifenslave that works with
>the new interface within two weeks (hopefully less). This is, of course,
>assuming we reach a consensus on the compatibility issue.

	Would that be dependant upon the cleanup stuff, or not?

>>  > 	Am I nuts to want to get the new API stuff in for 2.6.0?  It'd
>>  > be nice to not be locked in to supporting the current 
>>  scheme because
>>  > the first ifenslave in 2.6.0 uses it.
>>  
>>  I agree wholeheartedly.
>
>I also agree. The question is, can we really push such a change into
>bonding in 2.6, now that Linus only accepts bug fixes?

	That I don't know.  Most of this is moot if we can't mess with
2.6.

	-J

---
	-Jay Vosburgh, IBM Linux Technology Center, fubar@us.ibm.com
