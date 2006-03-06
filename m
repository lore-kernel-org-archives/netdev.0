From: "Michael S. Tsirkin" <mst@mellanox.co.il>
Subject: RFC: move SDP from AF_INET_SDP to IPPROTO_SDP
Date: Mon, 6 Mar 2006 21:06:36 +0200
Message-ID: <20060306190636.GA14849@mellanox.co.il>
Reply-To: "Michael S. Tsirkin" <mst@mellanox.co.il>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S932215AbWCFTGb@vger.kernel.org>
To: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	netdev@vger.kernel.org
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi!
I am working on implementing the Sockets Direct Protocol (SDP) for InfiniBand on
Linux. SDP uses the regular IPv4/IPv6 addresses and utilizes the IPv4/IPv6 layer
on top of InfiniBand for address resolution. However, all data is transferred by
means of an infiniband reliable connection.

Some existing SDP implementations posted on the openib.org subversion tree
create a new address family in a free slot, for this purpose.

Would it make sense to move SDP from using a separate address family to
a separate protocol under AF_INET and AF_INET6?
Something like IPPROTO_SDP?

The main advantages of this approach are
- IPv6 support will come more naturally and without further extending
  to a yet another address family
- We could use a protocol number > 255 to avoid conflicting
  with any IP based protocol.
  There are much more free protocol numbers that free family numbers
  (which only go up to 32 in linux for now).
- I could reuse more code for creating connections from af_inet.c

I also have a hunch this might make getaddrinfo and friends work better on sdp
selecting IPv4/IPv6 as appropriate but I'm not sure.

Comments? Are there disadvantages to this approach that someone can see?

Thanks,

-- 
Michael S. Tsirkin
Staff Engineer, Mellanox Technologies
_______________________________________________
openib-general mailing list
openib-general@openib.org
http://openib.org/mailman/listinfo/openib-general

To unsubscribe, please visit http://openib.org/mailman/listinfo/openib-general

----- End forwarded message -----

-- 
Michael S. Tsirkin
Staff Engineer, Mellanox Technologies
