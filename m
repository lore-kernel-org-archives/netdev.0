From: "Noam, Amir" <amir.noam@intel.com>
Subject: Changing bonding <-> ifenslave interface  [was: Problem with current /proc entries]
Date: Sun, 19 Oct 2003 17:56:01 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <E6F7D288B394A64585E67497E5126BA601EB5067@hasmsx403.iil.intel.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="iso-8859-1"
Content-Transfer-Encoding: 8bit
Return-path: <netdev-bounce@oss.sgi.com>
content-class: urn:content-classes:message
To: <bonding-devel@lists.sourceforge.net>, <netdev@oss.sgi.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


[adding netdev to the discussion]

"Chad N. Tindel" <chad@tindel.net> wrote:

>  > >I say that if people want to switch between 2.4 and 2.6, they can
>  > >write a script to create the appropriate ifenslave symbolic link.
>  > 
>  > 	To clarify, I'm interpreting this to mean:
>  > 
>  > 	2.4.X ifenslave (where "X" is recent enough that it doesn't
>  > use SIOCDEVPRIVATE) should work with 2.6.anything.

I disagree. See below.

>  > 	2.4.X ifenslave (where "X" is old and it uses SIOCDEVPRIVATE)
>  > need not work with 2.6.anything.
>  > 
>  > 	2.6.X ifenslave (where "X" is 0 or better) should work with
>  > any 2.6 later than the one it was shipped with.

Yes.

>  > 	2.6.X ifenslave (where "X" is 0 or better) need not work with
>  > 2.4.anything.

I disagree. I think that the latest version of ifenslave should work
with all versions of the bonding module that we can reasonably expect
people to use. This means that if ifenslave fails to use the new
interface it can try the old one. (This is how I understood Jeff's
position).

However, I'm definitely in favor of dropping compatibility in the
*module* in 2.6. This is because most recent distributions (Red Hat 9,
for example) still use an antique version of ifenslave that still uses
the SIOCDEVPRIVATE ioctls. If we remove support for these ioctls in
2.6 (as we should), then the bonding module will break compatibility
with those ifenslave versions anyway. I see no point in trying to keep
compatibility with the ifenslave version that is in the 2.4 kernel
tree, while it is not yet in use by any distribution.

>  My opinion is this.  What has worked in 2.4 in the past 
>  should always work
>  for 2.4.  Once you upgrade to 2.6, all bets for that are off.  

I agree, except that I think that if you upgrade to 2.6, and update
your ifenslave accordingly, you shouldn't have to switch user space
utilities when you boot into different kernels. That's why I said that
once you update ifenslave it should work with old bonding as well.

>  > 	Amir, how close are you to having a first draft patch for
>  > inspection?  I'm not concerned so much that it be fully baked
>  > as that
>  > it be something to look at and mess with for the usual gang.

We can probably provide a version of bonding/ifenslave that works with
the new interface within two weeks (hopefully less). This is, of course,
assuming we reach a consensus on the compatibility issue.

>  > 	Am I nuts to want to get the new API stuff in for 2.6.0?  It'd
>  > be nice to not be locked in to supporting the current 
>  scheme because
>  > the first ifenslave in 2.6.0 uses it.
>  
>  I agree wholeheartedly.

I also agree. The question is, can we really push such a change into
bonding in 2.6, now that Linus only accepts bug fixes?

Amir
