From: Roger Oksanen <roger.oksanen@cs.helsinki.fi>
Subject: Re: e100 REGRESSION in 2.6.32
Date: Wed, 16 Dec 2009 22:46:49 +0200
Message-ID: <200912162246.49611.roger.oksanen@cs.helsinki.fi>
References: <Pine.LNX.4.44L0.0912161447260.2643-100000@iolanthe.rowland.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: "e1000-devel@lists.sourceforge.net" <e1000-devel@lists.sourceforge.net>,
	netdev@vger.kernel.org, "Allan,
	Bruce W" <bruce.w.allan@intel.com>, "Brandeburg,
	Jesse" <jesse.brandeburg@intel.com>,
	Kernel development list <linux-kernel@vger.kernel.org>, "Ronciak,
	John" <john.ronciak@intel.com>, "Kirsher,
	Jeffrey T" <jeffrey.t.kirsher@intel.com>
To: Alan Stern <stern@rowland.harvard.edu>
Return-path: <e1000-devel-bounces@lists.sourceforge.net>
In-Reply-To: <Pine.LNX.4.44L0.0912161447260.2643-100000@iolanthe.rowland.org>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=e1000-devel>
List-Post: <mailto:e1000-devel@lists.sourceforge.net>
List-Help: <mailto:e1000-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=subscribe>
Errors-To: e1000-devel-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

On Wednesday 16 December 2009 21:50:38 Alan Stern wrote:
> On Wed, 16 Dec 2009, Brandeburg, Jesse wrote:
> >  Alan thanks for the report, I wonder if 
> > you can revert 98468efddb101f8a29af974101c17ba513b07be1 and see if that 
> > fixes it?
> 
> It does indeed.  Thanks for the quick response.
> 
> > Roger on the To: line made that change, which may have broken e100 for 
> > your system.
> 
> It looks simple enough, but obviously something is wrong with it.

I'm looking into this. Quite a baffling problem though. I have no idea what
causes the last 4 bytes  to change slightly (6c 6b 6b a3). Perhaps the patch 
only changed the timings to uncloak a lurking bug.. 
struct sk_buff has users as it's last member, so perhaps there is a preempt
point in dmapool that triggers a race with the rx path.

I'll try to reproduce this..

-- 
Roger Oksanen <roger.oksanen@cs.helsinki.fi>
http://www.cs.helsinki.fi/u/raoksane
+358 50 355 1990

------------------------------------------------------------------------------
This SF.Net email is sponsored by the Verizon Developer Community
Take advantage of Verizon's best-in-class app development support
A streamlined, 14 day to market process makes app distribution fast and easy
Join now and get one step closer to millions of Verizon customers
http://p.sf.net/sfu/verizon-dev2dev 
