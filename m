From: Ming Zhang <mingz@ele.uri.edu>
Subject: Re: Page Allocation Failure with e1000 using
	jumboframe
Date: Fri, 19 Aug 2005 13:52:24 -0400
Message-ID: <1124473944.5552.22.camel@localhost.localdomain>
References: <1124326404.5546.215.camel@localhost.localdomain>
	 <Pine.WNT.4.63.0508190940210.3796@jbrandeb-desk.amr.corp.intel.com>
	 <1124470909.5552.11.camel@localhost.localdomain>
	 <Pine.WNT.4.63.0508191023130.3796@jbrandeb-desk.amr.corp.intel.com>
Reply-To: mingz@ele.uri.edu
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: E1000 <e1000-devel@lists.sourceforge.net>,
	iet-dev <iscsitarget-devel@lists.sourceforge.net>,
	netdev@vger.kernel.org
Return-path: <e1000-devel-admin@lists.sourceforge.net>
To: Jesse Brandeburg <jesse.brandeburg@intel.com>
In-Reply-To: <Pine.WNT.4.63.0508191023130.3796@jbrandeb-desk.amr.corp.intel.com>
Sender: e1000-devel-admin@lists.sourceforge.net
Errors-To: e1000-devel-admin@lists.sourceforge.net
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Post: <mailto:e1000-devel@lists.sourceforge.net>
List-Help: <mailto:e1000-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=subscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=e1000-devel>
List-Id: netdev.vger.kernel.org

On Fri, 2005-08-19 at 10:33 -0700, Jesse Brandeburg wrote:
> On Fri, 19 Aug 2005, Ming Zhang wrote:
> > This is first reported on IET list and then i redo the test with vanilla
> > 2.6.12.4 kernel and everything went fine.
> > 
> > so i suspect if there are special case caused by vendor kernel.
> > 
> > is this 32KB ATOMIC ram allocation request only available in jumbo frame
> > case? since the regular MTU case goes fine.
> >
> 
> Ahh, okay.  I'm pretty sure that SuSE did some changes (not sure what) to 
> memory management.
> 
> the formula for the size that the current e1000 looks for is something 
> like
> 
> a = MTU roundup to next power of 2
> a += 2 (skb_reserve(NET_IP_ALIGN))
> a += 16 (skb_reserve 16 by __dev_alloc_skb)
> 
> so, a = 2048 + 2 + 16, or 2066
> request (a) from slab, which does a power of 2 roundup
> so the skb comes from the 4k (single page) slab for standard mtu.
> 
that is wasteful.


> Jesse
> 
> PS we have a driver in test that won't do the large contig allocations any 
> more.
> 

then wait to see this. :P





-------------------------------------------------------
SF.Net email is Sponsored by the Better Software Conference & EXPO
September 19-22, 2005 * San Francisco, CA * Development Lifecycle Practices
Agile & Plan-Driven Development * Managing Projects & Teams * Testing & QA
Security * Process Improvement & Measurement * http://www.sqe.com/bsce5sf
