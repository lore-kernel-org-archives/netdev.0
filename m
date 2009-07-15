From: Jeremy Fitzhardinge <jeremy@goop.org>
Subject: Using splice to carry Xen granted pages through the
	network stack?
Date: Wed, 15 Jul 2009 10:14:09 -0700
Message-ID: <4A5E0E61.6020704@goop.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: Andrew Warfield <andy@cs.ubc.ca>, Xen-devel <xen-devel@lists.xensource.com>,
	Jake Wires <Jake.Wires@citrix.com>,
	Herbert Xu <herbert@gondor.apana.org.au>, NetDev <netdev@vger.kernel.org>,
	Rusty Russell <rusty@rustcorp.com.au>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	Chris Mason <chris.mason@oracle.com>,
	Daniel Stodden <Daniel.Stodden@citrix.com>
To: Jens Axboe <jens.axboe@oracle.com>
Return-path: <xen-devel-bounces@lists.xensource.com>
List-Unsubscribe: <http://lists.xensource.com/mailman/listinfo/xen-devel>,
	<mailto:xen-devel-request@lists.xensource.com?subject=unsubscribe>
List-Post: <mailto:xen-devel@lists.xensource.com>
List-Help: <mailto:xen-devel-request@lists.xensource.com?subject=help>
List-Subscribe: <http://lists.xensource.com/mailman/listinfo/xen-devel>,
	<mailto:xen-devel-request@lists.xensource.com?subject=subscribe>
Sender: xen-devel-bounces@lists.xensource.com
Errors-To: xen-devel-bounces@lists.xensource.com
List-Id: netdev.vger.kernel.org

[ I originally sent this in March or so, but I don't think you
responded, and this still seems like an interesting idea. ]

Hi Jens,

In a thread from December last year ("Support for zero-copy TCP transmit
of user space data") you suggested using the splice machinery as a way
to implement zero-copy transmit for iscsi data.

I have a similar problem relating to doing zero-copy transmit of pages
granted from another Xen domain.  These are pages which are in some ways
similar to device mappings (they have no struct page unless we jump
through some hoops to give them one, for example) which are given to us
by another domain (virtual machine)'s network stack since they contain
data they want to transmit through our stack.  Once the stack has
finished with the pages we need to get them back to return to the
original domain (and definitely not let them get freed into the normal
kernel pool).

I've been looking a little bit at the splice stuff to work out how it
might be useful in this case.  One issue struct page; I guess we really
can't get away from having one for granted pages and still get the full
value of using splice (especially I can see also see it being useful on
the block side of the world as well).  So, we can jump through hoops for
that.

But the general plumbing of splice into the network stack seems to have
been an open issue since you introduced it 3 years ago (using as a
reference http://lwn.net/Articles/181169/).  Has any work been done on
this aspect since?  What would need to be done to do it?  Would it mean
wiring up a pipe_buffer_operations to operate with something like
Rusty's skb_shared_info destructor?

Thanks,
   J
