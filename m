From: Christoph Hellwig <hch@infradead.org>
Subject: Re: [PATCH] vfs: avoid taking locks if inode not in lists
Date: Wed, 27 Jul 2011 17:01:04 -0400
Message-ID: <20110727210104.GA9066@infradead.org>
References: <1311633550.2576.33.camel@schen9-DESK>
 <20110725225154.GD22133@ZenIV.linux.org.uk>
 <1311636178.2576.34.camel@schen9-DESK>
 <1311660013.2996.6.camel@edumazet-laptop>
 <1311668466.2355.12.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
 <20110726090357.GA13013@infradead.org>
 <1311672994.2355.17.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
 <1311780065.2356.18.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
 <20110727204415.GA13308@infradead.org>
 <20110727205957.GC8006@one.firstfloor.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Christoph Hellwig <hch@infradead.org>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Tim Chen <tim.c.chen@linux.intel.com>,
	Al Viro <viro@ZenIV.linux.org.uk>,
	David Miller <davem@davemloft.net>,
	Matthew Wilcox <matthew@wil.cx>,
	Anton Blanchard <anton@samba.org>, npiggin@kernel.dk,
	linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org,
	netdev <netdev@vger.kernel.org>
To: Andi Kleen <andi@firstfloor.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from 173-166-109-252-newengland.hfc.comcastbusiness.net ([173.166.109.252]:55153
	"EHLO bombadil.infradead.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754614Ab1G0VBL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 27 Jul 2011 17:01:11 -0400
Content-Disposition: inline
In-Reply-To: <20110727205957.GC8006@one.firstfloor.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jul 27, 2011 at 10:59:57PM +0200, Andi Kleen wrote:
> > Btw, I wonder if you should micro-optimize things a bit further by
> > moving the unhashed checks from the deletion functions into the callers
> > and thus save a function call for each of them.
> 
> If the caller is in the same file modern gcc is able to do that automatically
> if you're lucky enough ("partial inlining")
> 
> I would not uglify the code for it.

Depending on how you look at it the code might actually be a tad
cleaner.  One of called functions is outside of inode.c.

