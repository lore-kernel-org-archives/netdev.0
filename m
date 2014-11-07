From: Al Viro <viro@ZenIV.linux.org.uk>
Subject: Re: [PATCH 1/4] inet: Add skb_copy_datagram_iter
Date: Fri, 7 Nov 2014 22:31:53 +0000
Message-ID: <20141107223153.GC7996@ZenIV.linux.org.uk>
References: <20141105210745.GT7996@ZenIV.linux.org.uk>
 <20141105.165719.835728206041332333.davem@davemloft.net>
 <20141106032533.GU7996@ZenIV.linux.org.uk>
 <20141107.164859.951682597018909290.davem@redhat.com>
 <20141107221114.GB7996@ZenIV.linux.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: herbert@gondor.apana.org.au, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, bcrl@kvack.org
To: David Miller <davem@redhat.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20141107221114.GB7996@ZenIV.linux.org.uk>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Nov 07, 2014 at 10:11:14PM +0000, Al Viro wrote:

> I'm looking through the tree right now; so far it looks like we can just
> move those suckers to the point where we validate iovec and lose them
> from low-level iovec and csum copying completely.  I still haven't finished
> tracing all possible paths for address to arrive at the points where we
> currently check that stuff, but so far it looks very doable.

BTW, csum side of that is also chock-full of duplicate access_ok() -
e.g. generic csum_and_copy_from_user() checks before calling
csum_partial_copy_from_user().  And generic instance of that is using
__copy_from_user(), all right, but a _lot_ of non-default instances
repeat that access_ok().
