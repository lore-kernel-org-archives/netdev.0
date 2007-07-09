From: Jeff Garzik <jeff@garzik.org>
Subject: Re: Splitting e1000 (Was: Re: e1000: backport ich9
 support from 7.5.5 ?)
Date: Mon, 09 Jul 2007 14:39:49 -0400
Message-ID: <469280F5.8000909@garzik.org>
References: <46857C08.4030303@intel.com>	<20070629150350.414553d4.akpm@linux-foundation.org>	<4685838D.9080108@garzik.org>	<c0a09e5c0706291657kd5e4baawb113a17ca5ab2191@mail.gmail.com>	<46859F3F.305@garzik.org>	<4685C09B.7040908@intel.com>	<20070630082520.GA20140@infradead.org>	<468AD23A.4090904@intel.com>	<468D8B32.9020305@garzik.org>	<468EDAF9.3020606@intel.com>	<20070707190431.GA26341@electric-eye.fr.zoreil.com>	<46900B83.1060902@intel.com>
	<20070707183244.19d21893@freepuppy.rosehill.hemminger.net>
	<469110F6.2030902@linux.intel.com> <4691279C.8030603@garzik.org>
	<46914382.8090801@linux.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: e1000-devel@lists.sourceforge.net, netdev@vger.kernel.org,
	Christoph Hellwig <hch@infradead.org>,
	"Ronciak,  John" <john.ronciak@intel.com>,
	Andrew Grover <andy.grover@gmail.com>,
	Francois Romieu <romieu@fr.zoreil.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	Stephen Hemminger <shemminger@linux-foundation.org>,
	"David S. Miller" <davem@davemloft.net>,
	Andy Gospodarek <andy@greyhouse.net>
To: Arjan van de Ven <arjan@linux.intel.com>,
	"Kok, Auke" <auke-jan.h.kok@intel.com>
Return-path: <e1000-devel-bounces@lists.sourceforge.net>
In-Reply-To: <46914382.8090801@linux.intel.com>
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

Arjan van de Ven wrote:
> Jeff Garzik wrote:
>> Is this is the attitude, what's the point of even posting the driver 
>> for review?  Intel posted e1000new on June 29.  Feedback was then posted. 
> 
> and feedback is being incorperated.
> 
>> Ten days later, without a single revision, Intel declares its own 
>> driver clean and working and good enough for merging as-is.
> 
> No. Arjan looked at driver and sees a rather clean driver compared to 
> some of the other recently merged drivers, sees a list of relatively 
> simple todos (some of which obviously aren't merge stoppers, others are) 
> and hopes that this driver will be treated objectively without the 
> appearance of having different levels of bars depending on what your 
> email address ends with.


Ignoring small potatoes, the merge stoppers in my mind are:

1) Transition plan.  I strongly oppose switching all e1000 users en 
masse to a new driver, especially so soon.  Flag day transitions to 
unproven drivers suck.  Defaults don't work:  users use the old driver 
until the default changes, which means the new driver gets little field 
testing.

Regardless of my opinion of old-e1000 maintainability, top priority is 
to keep users running on a stable driver until new driver is stable.  I 
would propose merging a new driver with only the PCI IDs not already in 
the kernel, get that stable, then consider moving the rest of the 
PCI-Express PCI IDs (or others?).


2) Internal API.  An "it can do anything" API is a hint that the driver 
should be structured differently.  Perhaps a divorce between pre-PCIe 
and PCIe will help things (or 8257x vs other?).  I tend to think that 
both e1000 and e1000new could be cleaned up substantially by such a 
split.  Also, specifically for PHYs, we already have a phy layer that 
can be used a focal point for PHY modularity.

Overall, within minor chip revs you'll probably create standard 
branches.  But within major chip revs, you really should be looking at 
separate code paths rather than trying to shoehorn a wide variety of 
chips down the same (highly modular!) hot path.  That slows down 
everybody to the same speed (least common denominator), and makes it 
more difficult to follow the code path for a single chip.

If the chips are sufficiently different, it is better to write two 
distinct RX/TX/etc. code paths than to create a single, highly modular 
yet highly dense code path.  Easier to read.  Easier to tune.  Easier to 
leave chip errata behind, as time progresses.


3) Looming over everything else, is I wonder if Intel has recognized 
that a maintainership problem exists: lack of ongoing cleanups and lack 
of "focus" on issues not directly related to enabling new features?

My only "bias" against Intel is that I am -nervous- that past history 
will continue, with regards to the "stuff it into the driver and move 
on" driver maintenance regime.  Even most clean driver in the world will 
fall upon hard times if under-maintained.

Receiving feedback, disappearing for months, and then reappearing with 
"blessed" changes is not adequate.  netdev@vger.kernel.org and 
netdev-2.6.git need to be the primary vehicle for e1000[new] 
development, maintained through small incremental changes streaming into 
the kernel.  (though I do understand the constraints of hardware 
go-public release dates)

	Jeff



-------------------------------------------------------------------------
This SF.net email is sponsored by DB2 Express
Download DB2 Express C - the FREE version of DB2 express and take
control of your XML. No limits. Just data. Click to get it now.
http://sourceforge.net/powerbar/db2/
