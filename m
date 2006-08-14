From: David Miller <davem@davemloft.net>
Subject: Re: [2.6.17.8] NFS stall / BUG in UDP fragment processing / SKB
 trimming
Date: Sun, 13 Aug 2006 20:19:34 -0700 (PDT)
Message-ID: <20060813.201934.32734362.davem@davemloft.net>
References: <87zme9fy94.fsf@hades.wkstn.nix>
	<20060813125910.GA18463@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: greg@kroah.com, nix@esperi.org.uk, linux-kernel@vger.kernel.org,
	neilb@suse.de, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:60379
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S1751809AbWHNDTL (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 13 Aug 2006 23:19:11 -0400
To: herbert@gondor.apana.org.au
In-Reply-To: <20060813125910.GA18463@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Herbert Xu <herbert@gondor.apana.org.au>
Date: Sun, 13 Aug 2006 22:59:11 +1000

> On Sat, Aug 12, 2006 at 09:19:19PM +0000, Nix wrote:
> > 
> > The kernel log showed a heap of BUGs from somewhere inside the skb
> > management layer, somewhere in UDP fragment processing while
> > handling NFS requests. It starts like this:
> > 
> > Aug 12 21:31:08 hades warning: kernel: BUG: warning at include/linux/skbuff.h:975/__skb_trim()
> > Aug 12 21:31:08 hades warning: kernel: <c030ed39> ip_append_data+0x5b3/0x951  <c030fc18> ip_generic_getfrag+0x0/0x96
> 
> Oops, I missed this code path when I disallowed skb_trim from operating
> on a paged skb.  This patch should fix the problem.
> 
> Greg, we need this for 2.6.17 stable as well if Dave is OK with it.
> 
> [INET]: Use pskb_trim_unique when trimming paged unique skbs
 ...
> Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

Signed-off-by: David S. Miller <davem@davemloft.net>

Looks good, Greg please push to -stable.  I'll push this into
2.6.18 under seperate cover.

