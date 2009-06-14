From: Andreas Mohr <andim2@users.sourceforge.net>
Subject: Re: [PATCH] Make e100 suspend handler support PCI
	cards lacking PM	capability
Date: Sun, 14 Jun 2009 19:20:22 +0200
Message-ID: <20090614172022.GA22586@rhlx01.hs-esslingen.de>
References: <20081229102515.GA17171@rhlx01.hs-esslingen.de>
	<200906141606.29754.rjw@sisk.pl>
	<20090614164604.GA19746@rhlx01.hs-esslingen.de>
	<200906141909.46354.rjw@sisk.pl>
Reply-To: andi@lisas.de
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: e1000-devel@lists.sourceforge.net, netdev@vger.kernel.org,
	akpm@linux-foundation.org, linux-kernel@vger.kernel.org, andi@lisas.de
To: "Rafael J. Wysocki" <rjw@sisk.pl>
Return-path: <e1000-devel-bounces@lists.sourceforge.net>
Content-Disposition: inline
In-Reply-To: <200906141909.46354.rjw@sisk.pl>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=e1000-devel>
List-Post: <mailto:e1000-devel@lists.sourceforge.net>
List-Help: <mailto:e1000-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=subscribe>
Errors-To: e1000-devel-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

Hi,

On Sun, Jun 14, 2009 at 07:09:45PM +0200, Rafael J. Wysocki wrote:
> On Sunday 14 June 2009, Andreas Mohr wrote:
> > Couple questions still:
> > - why do we call pci_wake_from_d3(...false) only!?
> >   Wouldn't this break WoL after one iteration back and forth,
> >   due to missing 'true' case?
> 
> The 'true' case is the 'wake = true' one.

OK, so it wasn't an explicit pci_wake_from_d3(...true), but the
operations done there are the equivalent of it probably.

> > - why do we call netif_device_detach() _after_ doing hardware shutdown
> >   of the network controller? I'd guess this can cause huge issues?
> >   Someone told me he had rtnl lock issues upon S2D with e100
> >   (very similar to my rtnl issues during aborted .suspend),
> >   and that might possibly be the reason?
> 
> I think you're right, but I'm not a network driver expert.
> 
> Perhaps you can change the ordering and see if that fixes the rtnl issue
> (since you're able to reproduce it without my patch, that should be easy to
> verify).

I'll test this - later.

Thanks a lot,

Andreas Mohr

------------------------------------------------------------------------------
Crystal Reports - New Free Runtime and 30 Day Trial
Check out the new simplified licensing option that enables unlimited
royalty-free distribution of the report engine for externally facing 
server and web deployment.
http://p.sf.net/sfu/businessobjects
