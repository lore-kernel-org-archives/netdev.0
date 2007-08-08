From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Subject: IPV6_PKTINFO socket option
Date: Wed, 8 Aug 2007 12:16:51 +0100
Message-ID: <200708081216.51283@strip-the-willow>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: yoshfuji@linux-ipv6.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from dee.erg.abdn.ac.uk ([139.133.204.82]:62269 "EHLO erg.abdn.ac.uk"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1756199AbXHHLUp (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 8 Aug 2007 07:20:45 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Yoshifuji-san,

a few weeks earlier I enquired about the IPV6_PKTINFO socket option to get at the
destination address of datagrams, where you replied that this option is `deprecated'.

There are three problems:
 
 1. On i386 it works as described in section 4 of RFC 3542, using IPV6_RECVPKTINFO
    as sticky socket option to pull out the IPV6_PKTINFO cmsg header fields.
   
 2. On sparc64 with the same kernel IPV6_PKTINFO works without problems, even pulls
    out the cmsg fields correctly. Conversely, when trying to set the IPV6_RECVPKTINFO
    sticky option on the socket, no cmsg fields are generated. 
    The kernel is of the same date and revision as the i386 kernel - library issue ???
    It is very annoying, since the application needs to run on both architectures.

 3. Misc:
    * The option is mentioned 9 times in the index of "Unix Network Programming"
      (3rd ed., p. 969). Moreover, an entire section (27.7) is devoted to this topic.
    * It might be good to give at least a warning message in the syslog that the
      IPV6_PKTINFO socket option is no longer supported. That would save many users
      grief. An example how this was done in DCCP is in net/dccp/proto.c:

        case DCCP_SOCKOPT_PACKET_SIZE:
                DCCP_WARN("sockopt(PACKET_SIZE) is deprecated: fix your app");
   

Maybe this is due to a misunderstanding - in which case I'd be grateful for any clarifications.

Thanks
Gerrit
