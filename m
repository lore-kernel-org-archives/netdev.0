From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Subject: Re: [PATCH] SNMPv2 udpInDatagrams counter error
Date: Mon, 31 Jul 2006 09:57:50 +0100
Message-ID: <200607310957.50332@strip-the-willow>
References: <1154335874.3194.3.camel@LINE> <200607310919.02824@strip-the-willow> <075801c6b47d$08c49350$6004a8c0@WeiYongjun>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, "David Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from dee.erg.abdn.ac.uk ([139.133.204.82]:1968 "EHLO erg.abdn.ac.uk")
	by vger.kernel.org with ESMTP id S1751349AbWGaI6Y (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 31 Jul 2006 04:58:24 -0400
To: "Wei Yongjun" <yjwei@nanjing-fnst.com>
In-Reply-To: <075801c6b47d$08c49350$6004a8c0@WeiYongjun>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi,
  
|  if (!sk->sk_filter && skb->ip_summed != CHECKSUM_UNNECESSARY) {
|  
|  IPv6 doesn't do this, so I think delete condition 'sk->sk_filter' is better. 
|  Do you think so?
I think the sk->sk_filter is there for a good reason. If you delete it, that routine
is forced to always compute UDP checksums, even if the only receiving application is 
a tcpdump process. I may be wrong here, but I think that deleting the sk_filter statement
is not at a good idea. 

The other alternatives discussed (afaik) so far were:

1) Move the increment of UDP_MIB_INDATAGRAMS from udp_queue_rcv_skb() to udp_recvmsg()
   (first patch uploaded to  http://bugzilla.kernel.org/show_bug.cgi?id=6660). This
   was discussed: not a good idea, since in-kernel applications may use the data_ready
   handler rather than udp_recvmsg().

2) Decrement UDP_MIB_INDATAGRAMS in udp_recvmsg() when the checksum turns out to be
   wrong (second patch uploaded to above address). This would be a fix to the problem 
   you are stating, it also solves the problem of missing out the data_ready handlers in
   (1), and was suggested earlier on this mailing list.
  
-- Gerrit
