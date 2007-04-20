From: Ingo Molnar <mingo@elte.hu>
Subject: Re: [1/3] 2.6.21-rc6: known regressions
Date: Fri, 20 Apr 2007 15:46:27 +0200
Message-ID: <20070420134627.GA18195@elte.hu>
References: <Pine.LNX.4.64.0704051944230.6730@woody.linux-foundation.org>
	<20070414003625.GS5907@stusta.de>
	<Pine.LNX.4.64.0704131821020.28042@woody.linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Ayaz Abdulla <aabdulla@nvidia.com>,
	e1000-devel@lists.sourceforge.net, netdev@vger.kernel.org,
	Adrian Bunk <bunk@stusta.de>, Greg KH <greg@kroah.com>,
	Dave Jones <davej@redhat.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	Jeff Garzik <jgarzik@pobox.com>,
	"David S. Miller" <davem@davemloft.net>
To: Linus Torvalds <torvalds@linux-foundation.org>
Return-path: <e1000-devel-bounces@lists.sourceforge.net>
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.64.0704131821020.28042@woody.linux-foundation.org>
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


* Linus Torvalds <torvalds@linux-foundation.org> wrote:

> [...] I think the hangs that Ingo sees with forcedeth were preceded by 
> mysterious and "impossible" NULL pointer oopses. Ingo?

update: the 'forcedeth NULL pointer oops' problem got resolved by one of 
these commits:

 commit 3ba4d093fe8a26f5f2da94411bf8732fa6e9da86
 Author: Ayaz Abdulla <aabdulla@nvidia.com>
 Date:   Fri Mar 23 05:50:02 2007 -0500

     forcedeth: fix tx timeout

 commit fcc5f2665c81e087fb95143325ed769a41128d50
 Author: Ayaz Abdulla <aabdulla@nvidia.com>
 Date:   Fri Mar 23 05:49:37 2007 -0500

     forcedeth: fix nic poll

it never reoccured since this went upstream - so i'd close the NULL 
dereference bug.

furthermore, i havent seen the 'forcedeth interface hangs' problem 
trigger with recent kernels (havent seen it trigger for the past 2 
weeks), but no forcedeth specific change went into the kernel since i 
last reproduced a hang so either it got fixed by something else, or the 
hang is very rare. We could lower its priority for v2.6.21. If it ever 
happens again i'll send another ethtool dump to Ayaz.

	Ingo

-------------------------------------------------------------------------
This SF.net email is sponsored by DB2 Express
Download DB2 Express C - the FREE version of DB2 express and take
control of your XML. No limits. Just data. Click to get it now.
http://sourceforge.net/powerbar/db2/
