From: "Kok, Auke" <auke-jan.h.kok@intel.com>
Subject: Re: e1000: backport ich9 support from 7.5.5 ?
Date: Fri, 29 Jun 2007 14:39:20 -0700
Message-ID: <46857C08.4030303@intel.com>
References: <1183138159.17243.16.camel@blaa>
	<20070629175006.GB3917@falooley.org> <468571C6.3090305@garzik.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Mark McLoughlin <markmc@redhat.com>,
	Auke Kok <auke-jan.h.kok@intel.com>,
	e1000-devel@lists.sourceforge.net, netdev@vger.kernel.org,
	Andrew Morton <akpm@linux-foundation.org>,
	Jason Lunz <lunz@reflexsecurity.com>
To: Jeff Garzik <jeff@garzik.org>
Return-path: <e1000-devel-bounces@lists.sourceforge.net>
In-reply-to: <468571C6.3090305@garzik.org>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=e1000-devel>
List-Post: <mailto:e1000-devel@lists.sourceforge.net>
List-Help: <mailto:e1000-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=subscribe>
Sender: e1000-devel-bounces@lists.sourceforge.net
Errors-To: e1000-devel-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

Jeff Garzik wrote:
> Jason Lunz wrote:
>> What's the prognosis for the 7.5.5-series e1000 reorg going into
>> netdev-2.6?
> 
> As I have posted previously, I am not keen on merging basically an e1000 
> rewrite.  That basically throws away all Internet-wide testing so far. 
> The rewrite was not done according to Linux kernel standards (read: 
> progression of changes), so any problems will bisect into The Big 
> Commit(tm) and go no further.  A rewrite also means the complete driver 
> has to be reviewed from scratch, since such a large patch is basically 
> impossible to review.  Finally, the rewrite doesn't do much to clean up 
> the e1000 driver.
> 
> I warned Intel for months not to do things this way, but I guess my 
> opinion counts for little :)

no, they do

However, I am stuck with a half rewritten e1000 codebase (the 7.4.x code base) 
and on top of that all the changes that you requested from us. This effort has 
taken me about two months of time.

Taking apart that work change for every change seems very wasteful to me: it 
mucks up the current e1000 driver potentially, might break it and that is 
exactly what we want to prevent.

That's why we want to introduce a second e1000 driver (named differently, pick 
any name) that contains the new code base, side-by-side into the kernel with the 
current e1000.

This would allow everyone to fallback and compare the new and old code 
instantly, for several kernel releases at least. After that period, we can 
retire the old codebase.

Given the size of the changes and the fact that this is an interal API change 
that gigantically changes how e1000 internally works, there is *no* way that we 
can introduce this change in any other way in my opinion.

Looking at that, I think that bringing a second and new e1000 driver into the 
kernel is the best thing to do, and that is what I have been working towards. 
This new e1000 codebase goes miles and miles beyond what I posted in april/march 
and what is in -mm. For instance: the new codebase no longer has mac_type checks 
in *any* part of e1000_main.c.

I will try to post it as soon as I can. Please bear with me until I get that out 
  to everyone.

Auke

-------------------------------------------------------------------------
This SF.net email is sponsored by DB2 Express
Download DB2 Express C - the FREE version of DB2 express and take
control of your XML. No limits. Just data. Click to get it now.
http://sourceforge.net/powerbar/db2/
