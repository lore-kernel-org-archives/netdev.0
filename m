From: Alexander Duyck <alexander.duyck@gmail.com>
Subject: Looking for a lost patch
Date: Wed, 13 May 2015 10:47:11 -0700
Message-ID: <55538E1F.2020505@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
To: steffen.klassert@secunet.com, David Miller <davem@davemloft.net>,
	NetDev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f174.google.com ([209.85.223.174]:35417 "EHLO
	mail-ie0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754636AbbEMRrN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 13 May 2015 13:47:13 -0400
Received: by iebpz10 with SMTP id pz10so39234549ieb.2
        for <netdev@vger.kernel.org>; Wed, 13 May 2015 10:47:13 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

So I am in the process of trying to do some work on VTI6 and in the 
process of doing so I am trying to setup an IPv4 VTI tunnel and I have 
come across what appears to be a lost patch.

So in commit a32452366b72 ("vti4: Don't count header length twice.") the 
following change was made:

diff --git a/net/ipv4/ip_vti.c b/net/ipv4/ip_vti.c
index 687ddef..cd62596 100644
--- a/net/ipv4/ip_vti.c
+++ b/net/ipv4/ip_vti.c
@@ -349,7 +349,6 @@ static int vti_tunnel_init(struct net_device *dev)
  	memcpy(dev->broadcast, &iph->daddr, 4);

  	dev->type		= ARPHRD_TUNNEL;
-	dev->hard_header_len	= LL_MAX_HEADER + sizeof(struct iphdr);
  	dev->mtu		= ETH_DATA_LEN;
  	dev->flags		= IFF_NOARP;
  	dev->iflink		= 0;

However in commit f895f0cfbb77 ("Merge branch 'master' of 
git://git.kernel.org/pub/scm/linux/kernel/git/klassert/ipsec") the 
change appears to have been undone as a result of a merge commit.

I'm just wondering which is correct.  Should the hard_header_len be set 
or unset in vti_tunnel_init?  I ask because I have two kernels and one 
has the patch and one does not and I am seeing an MTU of 1332 for a VTI 
tunnel without, and 1480 for a VTI tunnel with.

- Alex
