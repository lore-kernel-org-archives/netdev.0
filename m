From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [PATCH] e1000e: test MSI interrupts
Date: Thu, 27 Mar 2008 19:38:17 -0400
Message-ID: <47EC2FE9.5020400@garzik.org>
References: <47EAB54A.1060306@intel.com><36D9DB17C6DE9E40B059440DB8D95F5204BF07F7@orsmsx418.amr.corp.intel.com><47EBF8EE.1000102@garzik.org>
	<20080327.150555.113590579.davem@davemloft.net>
	<36D9DB17C6DE9E40B059440DB8D95F5204C27573@orsmsx418.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: e1000-devel@lists.sourceforge.net, netdev@vger.kernel.org,
	"Kok,  Auke-jan H" <auke-jan.h.kok@intel.com>,
	David Miller <davem@davemloft.net>
To: "Brandeburg, Jesse" <jesse.brandeburg@intel.com>
Return-path: <e1000-devel-bounces@lists.sourceforge.net>
In-Reply-To: <36D9DB17C6DE9E40B059440DB8D95F5204C27573@orsmsx418.amr.corp.intel.com>
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

Brandeburg, Jesse wrote:
> I get your point, but this seems a maintainance problem due to not being
> able to "future proof" the solution.  I know what is (IDs) available
> now, but I don't know how many systems in the future IBM will release
> with a similar bridge but a different device ID that causes the same
> issue.

Future-proofing in that way is a pipe dream.

You hope to predict what _errata_, what out-of-spec behavior future 
hardware will have.  Trying to code for such N^M possible futures will 
lead to code bloat, depression, and eventually madness.


> Should we take on the maintenance of continually having to add
> every new bridge device that has this issue to our driver?  Users just
> want this stuff to work when they plug it in.

As David noted, we touch quirks.c all the time for various platform 
eccentricities.  Adding a new id is easy and takes two seconds.  The 
same ease of change applies to any driver-local list of ids, too.

Anyway, I think a better question to ask is:  should we bloat up every 
driver testing for platform quirks found on a minority of platforms?

Moreover, "it doesn't work" type errata is typically fixed in future 
chip generations -- making any such generic test /less/ valuable, 
because of the lower likelihood that IBM will continue to release this 
buggy hardware for decades.

We have an existing "this bridge and MSI don't get along" list.  Adding 
an id is a one-line patch.

	Jeff




-------------------------------------------------------------------------
Check out the new SourceForge.net Marketplace.
It's the best place to buy or sell services for
just about anything Open Source.
http://ad.doubleclick.net/clk;164216239;13503038;w?http://sf.net/marketplace
