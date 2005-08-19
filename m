From: Andi Kleen <ak@suse.de>
Subject: Re: [E1000-devel] Page Allocation Failure with e1000 using jumboframe
Date: Fri, 19 Aug 2005 19:42:01 +0200
Message-ID: <20050819174201.GJ3953@verdi.suse.de>
References: <1124326404.5546.215.camel@localhost.localdomain> <Pine.WNT.4.63.0508190940210.3796@jbrandeb-desk.amr.corp.intel.com> <1124470909.5552.11.camel@localhost.localdomain> <Pine.WNT.4.63.0508191023130.3796@jbrandeb-desk.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Ming Zhang <mingz@ele.uri.edu>,
	E1000 <e1000-devel@lists.sourceforge.net>,
	iet-dev <iscsitarget-devel@lists.sourceforge.net>,
	netdev@vger.kernel.org
Return-path: <iscsitarget-devel-admin@lists.sourceforge.net>
To: Jesse Brandeburg <jesse.brandeburg@intel.com>
Content-Disposition: inline
In-Reply-To: <Pine.WNT.4.63.0508191023130.3796@jbrandeb-desk.amr.corp.intel.com>
Sender: iscsitarget-devel-admin@lists.sourceforge.net
Errors-To: iscsitarget-devel-admin@lists.sourceforge.net
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/iscsitarget-devel>,
	<mailto:iscsitarget-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Post: <mailto:iscsitarget-devel@lists.sourceforge.net>
List-Help: <mailto:iscsitarget-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/iscsitarget-devel>,
	<mailto:iscsitarget-devel-request@lists.sourceforge.net?subject=subscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=iscsitarget-devel>
List-Id: netdev.vger.kernel.org

> Ahh, okay.  I'm pretty sure that SuSE did some changes (not sure what) to 
> memory management.

I don't think so.

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

That's very suboptimal because you're wasting nearly 2k. It would 
be better if you allocated 4k or exactly 2k

-Andi


-------------------------------------------------------
SF.Net email is Sponsored by the Better Software Conference & EXPO
September 19-22, 2005 * San Francisco, CA * Development Lifecycle Practices
Agile & Plan-Driven Development * Managing Projects & Teams * Testing & QA
Security * Process Improvement & Measurement * http://www.sqe.com/bsce5sf
