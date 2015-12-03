From: Alexander Duyck <alexander.duyck@gmail.com>
Subject: Re: [BUG] net: performance regression on ixgbe (Intel
 82599EB 10-Gigabit NIC)
Date: Thu, 3 Dec 2015 09:15:22 -0800
Message-ID: <566078AA.5040804@gmail.com>
References: <20151203162627.GA8989@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Jirka Hladky <jhladky@redhat.com>,
	"e1000-devel@lists.sourceforge.net" <e1000-devel@lists.sourceforge.net>,
	Adam Okuliar <aokuliar@redhat.com>, Kamil Kolakowski <kkolakow@redhat.com>
To: Otto Sabart <osabart@redhat.com>, netdev@vger.kernel.org
Return-path: <e1000-devel-bounces@lists.sourceforge.net>
In-Reply-To: <20151203162627.GA8989@redhat.com>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=e1000-devel>
List-Post: <mailto:e1000-devel@lists.sourceforge.net>
List-Help: <mailto:e1000-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=subscribe>
Errors-To: e1000-devel-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

On 12/03/2015 08:26 AM, Otto Sabart wrote:
> Hello netdev,
> I probably found a performance regression on ixgbe (Intel 82599EB
> 10-Gigabit NIC) on v4.4-rc3. I am able to see this problem since
> v4.4-rc1.
>
> The bug report you can find here [0].
>
> Can somebody take a look at it?
>
> [0] https://bugzilla.redhat.com/show_bug.cgi?id=1288124
>
>
> thanks,
> Ota

Hi Ota,

It looks like there were a few changes that went through that could be 
causing the regression.  The most obvious one that jumps out at me is 
commit 72bfd32d2f84 ("ixgbe: disable LRO by default").  As such one 
thing you might try doing is turning on LRO support via ethtool -k to 
see if that is the issue you are seeing.

If that doesn't resolve the issue it would be useful if you could might 
try doing a git bisect to narrow this down to a specific patch.

Thanks.

- Alex


------------------------------------------------------------------------------
Go from Idea to Many App Stores Faster with Intel(R) XDK
Give your users amazing mobile app experiences with Intel(R) XDK.
Use one codebase in this all-in-one HTML5 development environment.
Design, debug & build mobile apps & 2D/3D high-impact games for multiple OSs.
http://pubads.g.doubleclick.net/gampad/clk?id=254741911&iu=/4140
_______________________________________________
E1000-devel mailing list
E1000-devel@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/e1000-devel
To learn more about Intel&#174; Ethernet, visit http://communities.intel.com/community/wired
