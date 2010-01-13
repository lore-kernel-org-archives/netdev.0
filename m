From: "Brandeburg, Jesse" <jesse.brandeburg@intel.com>
Subject: Re: [PATCH] e1000: enhance frame fragment detection
Date: Tue, 12 Jan 2010 18:47:41 -0800 (Pacific Standard Time)
Message-ID: <alpine.WNT.2.00.1001121839130.3168@jbrandeb-desk1.amr.corp.intel.com>
References: <20091228201005.GC18422@hmsreliant.think-freely.org>
	<alpine.WNT.2.00.1001051341110.4056@jbrandeb-desk1.amr.corp.intel.com>
	<alpine.WNT.2.00.1001061525050.4056@jbrandeb-desk1.amr.corp.intel.com>
	<alpine.WNT.2.00.1001121720300.3168@jbrandeb-desk1.amr.corp.intel.com>
	<20100113021238.GA2165@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: "e1000-devel@lists.sourceforge.net" <e1000-devel@lists.sourceforge.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>, "Allan,
	Bruce W" <bruce.w.allan@intel.com>, "Ronciak,
	John" <john.ronciak@intel.com>, "Kirsher,
	Jeffrey T" <jeffrey.t.kirsher@intel.com>,
	"davem@davemloft.net" <davem@davemloft.net>
To: Neil Horman <nhorman@tuxdriver.com>
Return-path: <e1000-devel-bounces@lists.sourceforge.net>
In-Reply-To: <20100113021238.GA2165@localhost.localdomain>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=e1000-devel>
List-Post: <mailto:e1000-devel@lists.sourceforge.net>
List-Help: <mailto:e1000-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=subscribe>
Errors-To: e1000-devel-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

On Tue, 12 Jan 2010, Neil Horman wrote:
> I'm sorry, it doesn't clear much up, at least not for me.  The patch you're
> referencing above deals only with the jumbo receive path, not the non-jumbo
> case, which is not written to handle skb chains.  The vulnerability targets the
> latter case specifically.  We've seen cases in which an extra data is
> transferred into a subsequent buffer in the ring in that path.  Normally in our
> reproducing cases, I only saw a 4 byte overrun.  Theres a check specifically in
> the e1000(e) drivers for that case.  Unfortunately I never tested other cases,
> but if someone sets a low mtu (say 1000 bytes), I don't see why the same issue
> can't manifest as a buffer chain consisting of a 1000 byte skb followed by up to
> an extra 522 byte skb.  such a condition would bypass that check and result in
> admitting a garbage frame to the network stack.

Hm, you're right. /me smacks head.  Thanks for your comments Neil, they 
are very useful.

Wish we had thought to test the 1000 mtu case before I replied.  In any 
case, we now have verified that the fix in this thread is good in the case 
of 1000 mtu. 

So I now withdraw my withdrawal.  

We have a couple more things to test/fix before we post the final 
version(s), I know this is priority but I also don't want to rush out an 
incomplete fix.

Current plan is Jeff K will post the official version in the next couple 
of days, for e1000 and e1000e, which isn't necessary for >=1500 mtu, but 
is apparently necessary for smaller MTU.

------------------------------------------------------------------------------
This SF.Net email is sponsored by the Verizon Developer Community
Take advantage of Verizon's best-in-class app development support
A streamlined, 14 day to market process makes app distribution fast and easy
Join now and get one step closer to millions of Verizon customers
http://p.sf.net/sfu/verizon-dev2dev 
_______________________________________________
E1000-devel mailing list
E1000-devel@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/e1000-devel
To learn more about Intel&#174; Ethernet, visit http://communities.intel.com/community/wired
