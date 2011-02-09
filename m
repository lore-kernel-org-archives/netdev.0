From: Joakim Tjernlund <joakim.tjernlund@transmode.se>
Subject: MSG_DONTROUTE with IP_PKTINFO(ipi_ifindex)
Date: Wed, 9 Feb 2011 11:36:21 +0100
Message-ID: <OFFF525B4A.0F24F2C7-ONC1257832.0038126B-C1257832.003A428E@transmode.se>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-2022-JP
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.transmode.se ([213.115.205.20]:48901 "EHLO gw1.transmode.se"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754238Ab1BIKg0 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 9 Feb 2011 05:36:26 -0500
Received: from sesr04.transmode.se (sesr04.transmode.se [192.168.201.15])
	by gw1.transmode.se (Postfix) with ESMTP id 5DF0B650006
	for <netdev@vger.kernel.org>; Wed,  9 Feb 2011 11:36:22 +0100 (CET)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


How does sendmsg(2) work w.r.t IP_PKTINFO(ipi_ifindex) != 0
and MSG_DONTROUTE set?

man 7 ip has this to say about ipi_ifindex:

       IP_PKTINFO (since Linux 2.2)
              Pass  an  IP_PKTINFO  ancillary  message that contains a pktinfo
              structure that supplies  some  information  about  the  incoming
              packet.   This  only  works  for datagram oriented sockets.  The
              argument is a flag that tells the socket whether the  IP_PKTINFO
              message should be passed or not.  The message itself can only be
              sent/retrieved as control message with a packet using recvmsg(2)
              or sendmsg(2).

                  struct in_pktinfo {
                      unsigned int   ipi_ifindex;  /* Interface index */
                      struct in_addr ipi_spec_dst; /* Local address */
                      struct in_addr ipi_addr;     /* Header Destination
                                                      address */
                  };

              ipi_ifindex  is the unique index of the interface the packet was
              received on.  ipi_spec_dst is the local address  of  the  packet
              and  ipi_addr  is  the destination address in the packet header.
              If IP_PKTINFO is passed to sendmsg(2) and  ipi_spec_dst  is  not
              zero,  then it is used as the local source address for the rout‐
              ing table lookup and for setting up  IP  source  route  options.
              When  ipi_ifindex  is not zero, the primary local address of the
              interface specified by the index overwrites ipi_spec_dst for the
              routing table lookup.

So if ipi_ifindex is set with MSG_DONTROUTE, will linux use the I/F in ipi_index
or will it still lookup the dst address and use that instead?

I am asking as I got multiple ppp I/F between the same 2 routers which have
the same local and remote address(unnumbered ppp interfaces) and I want
to specify the interface to use as src and dst addr aren't unique.

Also, suppose I only have ipi_spec_dst and ipi_addr set and multiple interfaces match,
will the packet be sent on one of the matching interfaces or on all matching interfaces?

 Jocke

