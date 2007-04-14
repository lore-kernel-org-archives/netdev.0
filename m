From: Linus Torvalds <torvalds@linux-foundation.org>
Subject: Re: [1/3] 2.6.21-rc6: known regressions
Date: Fri, 13 Apr 2007 18:34:23 -0700 (PDT)
Message-ID: <Pine.LNX.4.64.0704131821020.28042@woody.linux-foundation.org>
References: <Pine.LNX.4.64.0704051944230.6730@woody.linux-foundation.org>
	<20070414003625.GS5907@stusta.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Ayaz Abdulla <aabdulla@nvidia.com>,
	e1000-devel@lists.sourceforge.net, netdev@vger.kernel.org,
	"David S. Miller" <davem@davemloft.net>, Greg KH <greg@kroah.com>,
	Dave Jones <davej@redhat.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	Jeff Garzik <jgarzik@pobox.com>, Ingo Molnar <mingo@elte.hu>
To: Adrian Bunk <bunk@stusta.de>
Return-path: <e1000-devel-bounces@lists.sourceforge.net>
In-Reply-To: <20070414003625.GS5907@stusta.de>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=e1000-devel>
List-Post: <mailto:e1000-devel@lists.sourceforge.net>
List-Help: <mailto:e1000-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=subscribe>
Sender: e1000-devel-bounces@lists.sourceforge.net
Errors-To: e1000-devel-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org


Note: Ingo also reports what looks like a memory corruption due to 
the 6b6b6b6b pattern on presumably the same box.

The 6b6b6b6b pattern is POISON_FREE, implying some kind of slab misuse, 
most likely a use-after-free, although possibly just due to overrunning a 
slab into the next one or something like that.

What I'm leading up to is that I'm wondering if these mysterious network 
driver bugs aren't due to the network drivers themselves, but due to some 
higher-level problem. I think the hangs that Ingo sees with forcedeth were 
preceded by mysterious and "impossible" NULL pointer oopses. Ingo?

Davem - have there been network infrastructure changes that migt be 
suspect? Jeff and/or Greg - anything in the generic network driver/device 
driver level? We had some trouble earlier with the transition to the 
driver core, and kref miscounting. Related? The last Oops Ingo saw was a 
module refcounting one, iirc.

It does seem networking related somehow. Yeah, it could be obviously be a 
combination of independent bugs both in e1000/ and forcedeth drivers, but 
maybe there is something in common here...

I'll make an -rc7, but I'm a bit worried about the fact that I haven't 
actually gotten anything that looks like it might address any of this 
(unless some of the network patches I just pulled do, but that sounds 
unlikely). It's been very quiet. I don't like that. I don't get the 
feeling that we're making progress here, unlike the timer-related 
regressions which seem to all be slowly working themselves out..

So please people, give it a look. Comments?

		Linus

On Sat, 14 Apr 2007, Adrian Bunk wrote:
> 
> Subject    : laptops with e1000: lockups
> References : https://bugzilla.redhat.com/bugzilla/show_bug.cgi?id=229603
> Submitter  : Dave Jones <davej@redhat.com>
> Handled-By : Jesse Brandeburg <jesse.brandeburg@intel.com>
> Status     : problem is being debugged
> 
> Subject    : forcedeth: interface hangs under load
> References : http://lkml.org/lkml/2007/4/3/39
> Submitter  : Ingo Molnar <mingo@elte.hu>
> Handled-By : Ingo Molnar <mingo@elte.hu>
>              Ayaz Abdulla <aabdulla@nvidia.com>
> Status     : problem is being debugged


-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys-and earn cash
http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
