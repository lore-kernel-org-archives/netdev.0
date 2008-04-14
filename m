From: Eus <eus@member.fsf.org>
Subject: proto_register() - the justification for requesting slab allocation
Date: Sun, 13 Apr 2008 22:26:54 -0700 (PDT)
Message-ID: <919776.54892.qm@web37608.mail.mud.yahoo.com>
Reply-To: eus@member.fsf.org
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7BIT
To: Linux Networking Mailing List <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from web37608.mail.mud.yahoo.com ([209.191.87.91]:23636 "HELO
	web37608.mail.mud.yahoo.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1751849AbYDNFdh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 14 Apr 2008 01:33:37 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Ho!

Currently I am trying to implement a new type of socket in Linux kernel 2.6.21.5.
I am really curious about this function:
        int proto_register(struct proto *prot, int alloc_slab)

I have investigated the source code and knew that, if alloc_slab is set to a
non-zero integer, kmem_cache_create() will create a memory slab for prot->slab.
At the end, when a socket needs to be created and sk_alloc() is invoked to create
the socket object, if prot->slab has been initialized with kmem_cache_create(),
sk_alloc() will simply create the socket object in the slab with
kmem_cache_alloc. Otherwise, sk_alloc() will create the socket object in the
ordinary way with kmalloc().

IMO, kmem_cache_alloc() should be less expensive than kmalloc() and, therefore,
it is a good thing to request slab allocation when invoking proto_register().
But, from all networking protocols that invoke proto_register(), 50% of them,
most of them are data link protocols, does not request slab allocation. The rest
that request slab allocation mainly is network layer protocols. That is why I
wonder whether or not there is an advantage of using kmalloc() over using
kmem_cache_alloc().

A friend of mine said that those that do not request slab allocation do so
because they are rarely used. But, I disagree because, although they are rarely
used, once they are used, they are used heavily, for example AF_PACKET, so that
it is a good idea to request slab allocation.

Therefore, what is the justification for requesting slab allocation or not?

Please put me in the CC list when replying.

Thank you very much.

Best regards,
Eus


      ____________________________________________________________________________________
Be a better friend, newshound, and 
know-it-all with Yahoo! Mobile.  Try it now.  http://mobile.yahoo.com/;_ylt=Ahu06i62sR8HDtDypao8Wcj9tAcJ
