From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Subject: Re: Zero checksum in netconsole/netdump packets
Date: Tue, 7 Nov 2006 10:09:02 +0000
Message-ID: <200611071009.02424@strip-the-willow>
References: <454FC80B.9090001@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-6"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from dee.erg.abdn.ac.uk ([139.133.204.82]:62659 "EHLO erg.abdn.ac.uk")
	by vger.kernel.org with ESMTP id S1753914AbWKGKJ3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 7 Nov 2006 05:09:29 -0500
To: Chris Lalancette <clalance@redhat.com>
In-Reply-To: <454FC80B.9090001@redhat.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Quoting Chris Lalancette:
|  Hello,
|       I realized that all of the packets that go from the crashing machine to the netdump server have a zero checksum. 
<snip>
|       Assuming that this is just an oversight, attached is a simple patch to compute the UDP checksum in netpoll_send_udp.
|  
|  Signed-off-by: Chris Lalancette <clalance@redhat.com>
|  
RFC 768 allows to not compute the checksum by leaving uh->check at 0 - hence it is not illegal.
But without David's suggestion the code is not valid, since otherwise there is no way of 
distinguishing a computed `0' from an ignored `0' field:
 if ( udph->check == 0 )
	udph->check = -1;
