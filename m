From: Denys Fedoryshchenko <denys@visp.net.lb>
Subject: REDIRECT in nat OUTPUT
Date: Sat, 12 Jul 2008 04:24:56 +0300
Message-ID: <200807120424.56462.denys@visp.net.lb>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netfilter-devel@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay2.globalproof.net ([194.146.153.25]:42375 "EHLO
	relay2.globalproof.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754934AbYGLBZE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 11 Jul 2008 21:25:04 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I notice TX performance issues while using REDIRECT rule in -t nat -I OUTPUT chain.

To reproduce:
First let's test network and HDD speed 
homecore ~ # scp PSA_schematique_07H.iso root@127.0.0.1:/tmp
PSA_schematique_07H.iso                                                                                                      7%  335MB  25.7MB/s   02:39 ETA
^C
Killed by signal 2. (i kill it)


Second let's do the trick
iptables -t nat -I OUTPUT -p tcp --dport 23 -j REDIRECT --to-ports 22
scp -P 23 PSA_schematique_07H.iso root@anyhost:/tmp
PSA_schematique_07H.iso                                                                                                      0% 8728KB 121.3KB/s 10:22:05 ETA
^C
Killed by signal 2.

Always all rules with REDIRECT to local port is dropping speed around 100Kbyte/s. What can be the problem?

-- 
------
Technical Manager
Virtual ISP S.A.L.
Lebanon
