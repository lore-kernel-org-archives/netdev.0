From: Christoph Hellwig <hch@infradead.org>
Subject: Re: BUG: unable to handle kernel NULL pointer dereference at
 000000000000002c
Date: Thu, 1 Dec 2011 13:23:09 -0500
Message-ID: <20111201182309.GA10686@infradead.org>
References: <4ED7C367.3070109@profihost.ag>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, Dave Chinner <david@fromorbit.com>,
	stable@vger.kernel.org
To: Stefan Priebe <s.priebe@profihost.ag>
Return-path: <netdev-owner@vger.kernel.org>
Received: from 173-166-109-252-newengland.hfc.comcastbusiness.net ([173.166.109.252]:43256
	"EHLO bombadil.infradead.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1756016Ab1LASXM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 1 Dec 2011 13:23:12 -0500
Content-Disposition: inline
In-Reply-To: <4ED7C367.3070109@profihost.ag>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Dec 01, 2011 at 07:11:51PM +0100, Stefan Priebe wrote:
> Hi,
> 
> i'm not quite sure if this is an XFS thing or a tcp thing. As the
> stacktrace confuses me a little but as it contains
> xfs_bmap_search_extents and xfs_iunlock. Kernel is 3.0.11 running as
> 2.6.40.11.
> 
> [171464.091567] BUG: unable to handle kernel NULL pointer
> dereference at 000000000000002c
> [171464.092073] IP: [<ffffffff815494f6>] ipv4_dst_check+0xb6/0x190
> [171464.092073] PGD 15344e067 PUD 14c821067 PMD 0
> [171464.092073] Oops: 0002 [#1] SMP
> 
> Full Stacktrace:
> http://pastebin.com/raw.php?i=QNg6jD2t

The ? entries mean even the backtrace code things they are unreliable,
and mos of the cases I've seen they are wrong.  In this case it looks
like the process was doing XFS work before, but the current system call
indeed is purely in the networking code.

I've changed the cc list to the netdev list which is more appropinquate.
