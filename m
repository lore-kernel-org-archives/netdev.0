From: Or Gerlitz <ogerlitz@mellanox.com>
Subject: [PATCH net 0/2] net/bonding: fixes related to neigh
Date: Mon,  2 Apr 2012 19:17:08 +0300
Message-ID: <1333383430-17456-1-git-send-email-ogerlitz@mellanox.com>
Cc: roland@kernel.org, netdev@vger.kernel.org, fubar@us.ibm.com,
	Or Gerlitz <ogerlitz@mellanox.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from eu1sys200aog118.obsmtp.com ([207.126.144.145]:49534 "HELO
	eu1sys200aog118.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1751566Ab2DBQRW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 2 Apr 2012 12:17:22 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Shlomo Pongratz <shlomop@mellanox.com>

Dave, 

This small patch set fixes some issues we stepped on when preparing 
for some IPoIB changes. 

With the 1st patch, the kernel networking code of arp_netdev_event calls 
neigh_changeaddr which further flashes the boding neighbours in some more 
cases which weren't covered by commit 7d26bb103 "bonding: emit event when 
bonding changes MAC"

The 2nd patch fixes a bug where under bonding, the IPoIB neigh cleanup
function wasn't called.

Or.


Shlomo Pongratz (2):
  net/bonding: emit address change event in more places
  net/bonding: correctly proxy slave neigh param setup ndo function

 drivers/net/bonding/bond_main.c |   56 +++++++++++++++++++++++++++++++++-----
 1 files changed, 48 insertions(+), 8 deletions(-)
