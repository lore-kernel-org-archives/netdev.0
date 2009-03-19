From: Jeremy Fitzhardinge <jeremy@goop.org>
Subject: Using splice to carry Xen granted pages through the network stack?
Date: Wed, 18 Mar 2009 17:04:52 -0700
Message-ID: <49C18C24.6000601@goop.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	NetDev <netdev@vger.kernel.org>,
	Evgeniy Polyakov <johnpol@2ka.mipt.ru>,
	Herbert Xu <herbert@gondor.apana.org.au>,
	Vladislav Bolkhovitin <vst@vlnb.net>,
	Xen-devel <xen-devel@lists.xensource.com>,
	Rusty Russell <rusty@rustcorp.com.au>
To: Jens Axboe <jens.axboe@oracle.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw.goop.org ([64.81.55.164]:57821 "EHLO mail.goop.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752192AbZCSAE4 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 18 Mar 2009 20:04:56 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

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
