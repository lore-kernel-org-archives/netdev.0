From: Jeff Garzik <jeff@garzik.org>
Subject: Re: Splitting e1000 (Was: Re: e1000: backport ich9
 support from 7.5.5 ?)
Date: Thu, 05 Jul 2007 20:22:10 -0400
Message-ID: <468D8B32.9020305@garzik.org>
References: <1183138159.17243.16.camel@blaa>
	<20070629175006.GB3917@falooley.org>
	<468571C6.3090305@garzik.org> <46857C08.4030303@intel.com>
	<20070629150350.414553d4.akpm@linux-foundation.org>
	<4685838D.9080108@garzik.org>
	<c0a09e5c0706291657kd5e4baawb113a17ca5ab2191@mail.gmail.com>
	<46859F3F.305@garzik.org> <4685C09B.7040908@intel.com>
	<20070630082520.GA20140@infradead.org> <468AD23A.4090904@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Mark McLoughlin <markmc@redhat.com>,
	e1000-devel@lists.sourceforge.net, netdev@vger.kernel.org,
	"David S. Miller" <davem@davemloft.net>,
	Christoph Hellwig <hch@infradead.org>,
	"Ronciak,  John" <john.ronciak@intel.com>,
	Andrew Grover <andy.grover@gmail.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	'Stephen Hemminger' <shemminger@linux-foundation.org>,
	Jason Lunz <lunz@reflexsecurity.com>,
	Andy Gospodarek <andy@greyhouse.net>
To: "Kok, Auke" <auke-jan.h.kok@intel.com>
Return-path: <e1000-devel-bounces@lists.sourceforge.net>
In-Reply-To: <468AD23A.4090904@intel.com>
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

Kok, Auke wrote:
> 1a) We post an e1000e driver that implements support for all 8257x 
> (ich8/9, es2lan etc) devices.
> 1b) We post a patch that drops support for all of these devices in the 
> form of a pci-ID removal (no code removed) for e1000.
> 
> 2) we post patches that remove code support for non-8254x devices at a 
> later stage.
> 
> 3) we backport any and all cleanups and flags from e1000e to e1000 where 
> applicable.
> 
> 
> This plan leaves a significant gap that I'm worrying about: after step 
> (1) we basically have forced everyone to switch without providing a 
> fallback (allthough we have our out-of-tree driver, but no in-kernel 
> version in case issues exist).
> 
> 
> Comments?

I like the general gist of it.  My own suggestion would be

1) Create e1001.c, which is the SMALLEST POSSIBLE "it works" driver for 
ICH9.  No feature enablement (no TSO, no MQ, no IOAT, not even checksum 
offload), just a rock solid, no frills driver.  Think like e100.c :)

2) We review the hell out of e1001, and merge it.  This enables ICH9 
users, and ONLY ICH9 users, on e1001 in the upstream kernel, allowing us 
to blithely ignore driver->driver migration issues present with other chips.


At this point, e1001 is out in the field and in the upstream kernel in 
the absolute shortest amount of time.  Users of chips NOT found in 
current e1000 driver, and all future chips, can be enabled with little 
impediments, in parallel with the steps below.

(all the "3^y" steps can occur in parallel)

3^1) Add features to e1001, enabling new gizmos on new hardware.  This 
can proceed in parallel with any e1000 work.  This allows users to use 
git-bisect to find driver bugs -- or even hardware bugs, since you have 
a baseline working e1001 driver.

3^2) Add full ICH8 (8257x?) support to e1001.

4) Drop 8257x PCI IDs from e1000.  See who complains.  Lather, rinse, 
repeat.

5) Figure out how the hell to clean up the current mess that is e1000, 
and how to make sure e1000 and e1001 stay clean, long term.

	Jeff



-------------------------------------------------------------------------
This SF.net email is sponsored by DB2 Express
Download DB2 Express C - the FREE version of DB2 express and take
control of your XML. No limits. Just data. Click to get it now.
http://sourceforge.net/powerbar/db2/
