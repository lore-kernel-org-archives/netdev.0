From: Jeff Garzik <jeff@garzik.org>
Subject: Re: Splitting e1000 (Was: Re: e1000: backport ich9
 support from 7.5.5 ?)
Date: Sun, 08 Jul 2007 13:41:20 -0400
Message-ID: <469121C0.7040208@garzik.org>
References: <1183138159.17243.16.camel@blaa>
	<20070629175006.GB3917@falooley.org>
	<468571C6.3090305@garzik.org> <46857C08.4030303@intel.com>
	<20070629150350.414553d4.akpm@linux-foundation.org>
	<4685838D.9080108@garzik.org>
	<c0a09e5c0706291657kd5e4baawb113a17ca5ab2191@mail.gmail.com>
	<46859F3F.305@garzik.org> <4685C09B.7040908@intel.com>
	<20070630082520.GA20140@infradead.org>
	<468AD23A.4090904@intel.com> <468D8B32.9020305@garzik.org>
	<468EDAF9.3020606@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Mark McLoughlin <markmc@redhat.com>,
	e1000-devel@lists.sourceforge.net, netdev@vger.kernel.org,
	"David S. Miller" <davem@davemloft.net>,
	Christoph Hellwig <hch@infradead.org>,
	"Ronciak,  John" <john.ronciak@intel.com>,
	Arjan van de Ven <arjan@linux.intel.com>,
	Andrew Grover <andy.grover@gmail.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	'Stephen Hemminger' <shemminger@linux-foundation.org>,
	Jason Lunz <lunz@reflexsecurity.com>,
	Andy Gospodarek <andy@greyhouse.net>
To: "Kok, Auke" <auke-jan.h.kok@intel.com>
Return-path: <e1000-devel-bounces@lists.sourceforge.net>
In-Reply-To: <468EDAF9.3020606@intel.com>
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
> This is not acceptable and hardly fair to expect from us.
> 
> It also exposes users to endless delays and uncertainties as to a final 
> resolution. Not to mention that writing a driver from scratch for (just) 
> ich9 will take significant time, is silly since it's almost identical to 
> ich8 etc..
> 
> I don't think that anyone besides you and maybe one or two others are 
> interested in doing this rewrite from scratch. The rest of us would 
> rather see something much more similar to my original suggestion which 
> relieves the ich9-wishes for everyone and provides a good starting point 
> to go forward. Not to mention that a lot of that code is already there, 
> and at least cleaned up quite a bit already.

Let's review the history here:

* For -years-, Intel has been told to stream structural cleanups into 
e1000 (and ixgb), along with feature enablement.  None of these cleanups 
happened, and the result was today's bloated driver.

* Intel posts a new e1000 driver, which is just as complex, if not more so.

* Intel proposes a Linux user transition plan that amounts to an abrupt 
NIC driver switch for users on a widely used NIC platform.

* Intel immediately dismisses all alternate paths to e1000 change, and 
all major e1000new structural comments.

Thus in effect you are presenting the Linux community with one option 
(and only one) -- your e1000new as it exists today -- and demanding that 
that option be accepted.

More importantly, Intel is asking the Linux community to TRUST that 
Intel will be a good driver MAINTAINER, despite lack of encouraging 
evidence in that regard.

Will we continue to see INATTENTION to basic driver maintenance, with 
100% of resources being devoted new features, and 0% devoted to thinking 
about how best to create a maintainable driver for those features long term?

With e1000new, I see a driver that's internally modular, but no more 
maintainable.  I also see a driver that runs directly counter to what we 
normally do in this situation -- split it up into multiple drivers. 
When you find yourself reinventing a net driver API, that's a big hint 
your engineering is ass-backwards.

It's not acceptable and hardly fair to expect the Linux community to 
blindly swallow the single option you've presented us.

We're talking about one of the most widely used NIC drivers here. 
Proposing to flip a switch and dump all users on the new driver in a 
couple months time does not serve Linux users at all.  Introducing the 
new driver more slowly -- starting with ICH9 and any other PCI IDs not 
covered by e1000 -- gives the driver a chance to prove itself in the 
field and be introduced more slowly, while at the same time not 
dramatically disturbing the existing, working e1000 installed base.

Starting with a new driver for the new hardware is the right way to go. 
    Get that driver into the field, get it right, and THEN use that 
field experience to see what PCI IDs you want to transition from the 
older driver.  That path is minimal disruption for Linux users, and 
maximizes the changes of Linux users running a working, proven driver. 
And coincidentally, that path also gives you the freedom to do heavy 
development on the new driver, with minimal disruption of the majority 
of your userbase.

So in sum, (a) Intel does not appear to have thought through the driver 
transition, (b) Intel has not proven itself to be a maintainer, and (c) 
e1000new needs to be restructured.

	Jeff




-------------------------------------------------------------------------
This SF.net email is sponsored by DB2 Express
Download DB2 Express C - the FREE version of DB2 express and take
control of your XML. No limits. Just data. Click to get it now.
http://sourceforge.net/powerbar/db2/
