From: Dan Carpenter <dan.carpenter@oracle.com>
Subject: re: udp_tunnel: Pass UDP socket down through udp_tunnel{,
 6}_xmit_skb().
Date: Wed, 8 Apr 2015 21:48:05 +0300
Message-ID: <20150408184805.GA12952@mwanda>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org,
	Hannes Frederic Sowa <hannes@stressinduktion.org>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from userp1040.oracle.com ([156.151.31.81]:24754 "EHLO
	userp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753192AbbDHSsY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 8 Apr 2015 14:48:24 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello David Miller,

The patch 79b16aadea32: "udp_tunnel: Pass UDP socket down through
udp_tunnel{, 6}_xmit_skb()." from Apr 5, 2015, leads to the following
static checker warning:

	net/ipv4/ip_tunnel.c:785 ip_tunnel_xmit()
	error: NULL dereference inside function.

net/ipv4/ip_tunnel.c
   781                  kfree_skb(skb);
   782                  return;
   783          }
   784  
   785          err = iptunnel_xmit(NULL, rt, skb, fl4.saddr, fl4.daddr, protocol,
                                    ^^^^
This doesn't work.  It will Oops in iptunnel_xmit() when it does
sock_net(sk).

   786                              tos, ttl, df, !net_eq(tunnel->net, dev_net(dev)));
   787          iptunnel_xmit_stats(err, &dev->stats, dev->tstats);
   788  
   789          return;

regards,
dan carpenter
