From: "David S. Miller" <davem@redhat.com>
Subject: Re: Route cache performance under stress
Date: Mon, 26 May 2003 00:29:34 -0700 (PDT)
Sender: linux-net-owner@vger.kernel.org
Message-ID: <20030526.002934.132904126.davem@redhat.com>
References: <20030519.181405.35017608.davem@redhat.com>
	<20030519212209.P39592@shell.cyberus.ca>
	<87adda6uro.fsf@deneb.enyo.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: hadi@shell.cyberus.ca, netdev@oss.sgi.com,
	linux-net@vger.kernel.org
Return-path: <linux-net-owner@vger.kernel.org>
To: fw@deneb.enyo.de
In-Reply-To: <87adda6uro.fsf@deneb.enyo.de>
List-Id: netdev.vger.kernel.org

   From: Florian Weimer <fw@deneb.enyo.de>
   Date: Mon, 26 May 2003 09:18:19 +0200
   
   Cisco IOS doesn't have this hash collisions problem, they have
   moved away from hash tables ages ago.
   
Let their loss be our gain :-)  No, I am serious, their solution to
misbehaving flows seems to be just using slow path always and
continually optimize the slow path.

   the data structure are changed when updated routing information is
   encountered and not when packets are received which need to be
   routed.

Yes, they say this in the marketing literature too. :)

Now, how about some real explanation about what they are actually
doing?  Are they replicating the routing table all over the place?
That's one possibility, and would match up to their saying that more
router memory is required when using CEF.

The other possibility is that it's a faster-trie thing generated
from the normal routing tables.  Since CEF aparently works with QoS
and other features, the key must be many bits wide.  Probably similar
in size to our flowi's.

So some bit branching trie based upon flow parameters.  There are
hundreds of patented such schemes :-)

Anyways, you keep saying that flow hashing is stupid, can you propose
an alternative?  Really, I don't mean to be rude, but you do a lot of
complaining about how what we have now sucks and zero of actually
suggesting a usable alternative.
