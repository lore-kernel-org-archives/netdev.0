From: Al Viro <viro@ZenIV.linux.org.uk>
Subject: Re: [PATCH] ATM: misplaced parentheses?
Date: Mon, 16 Feb 2009 22:30:01 +0000
Message-ID: <20090216223001.GW28946@ZenIV.linux.org.uk>
References: <49983DB0.6040008@gmail.com> <200902162202.n1GM2aI0009056@cmf.nrl.navy.mil>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Roel Kluin <roel.kluin@gmail.com>, netdev@vger.kernel.org,
	Andrew Morton <akpm@linux-foundation.org>
To: chas3@users.sourceforge.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from zeniv.linux.org.uk ([195.92.253.2]:53726 "EHLO
	ZenIV.linux.org.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750909AbZBPWaE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 16 Feb 2009 17:30:04 -0500
Content-Disposition: inline
In-Reply-To: <200902162202.n1GM2aI0009056@cmf.nrl.navy.mil>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Feb 16, 2009 at 05:02:36PM -0500, Chas Williams (CONTRACTOR) wrote:
> that doesnt seem to make sense either.  the original code
> is:
> 
>  		for (i = 128; i != 0; i >>= 1) {   /* write command out */
> ...
>  			tmp = (lanai->conf1 & ~CONFIG1_PROMDATA) |
> 			    (data & i) ? CONFIG1_PROMDATA : 0;
> 
> since i is always positive here, you wouldnt need the ?: if your suggested
> fix is the original intent.  it looks like setting CONFIG1_PROMDATA
> means '1' and not setting it means '0' when writing the value of data
> to the register.

What the hell does it have to do with i being positive?  || variant is,
of course, silly; it's very obvious what's going on here.  Garden-variety
bit-banging, IOW
  			tmp = (lanai->conf1 & ~CONFIG1_PROMDATA) |
 			    ((data & i) ? CONFIG1_PROMDATA : 0);
and while you technically only need parens around ?:, in this case it's
better to keep it fully parenthesised - more readable that way.

The lack of parens around ?: in the current tree is an obvious bug.
