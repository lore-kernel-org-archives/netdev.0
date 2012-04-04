From: Or Gerlitz <ogerlitz@mellanox.com>
Subject: [PATCH net V1 0/2] net/bonding: fixes related to neigh
Date: Wed,  4 Apr 2012 11:56:18 +0300
Message-ID: <1333529780-28421-1-git-send-email-ogerlitz@mellanox.com>
Cc: roland@kernel.org, netdev@vger.kernel.org, fubar@us.ibm.com,
	Or Gerlitz <ogerlitz@mellanox.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from eu1sys200aog101.obsmtp.com ([207.126.144.111]:44212 "HELO
	eu1sys200aog101.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1752447Ab2DDI4f (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 4 Apr 2012 04:56:35 -0400
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

changes from V0: applied feedback from Jay Vosburgh
  - emit the address change in bond_release but not in bond_release_all
    where its unneeded.
  - rephrase the comment in bond_neigh_init on why we need to pre-proxy 
    the cleanup function. Also removed a comment which isn't needed there.
  

Shlomo Pongratz (2):
  net/bonding: emit address change event also in bond_release
  net/bonding: correctly proxy slave neigh param setup ndo function

 drivers/net/bonding/bond_main.c |   54 +++++++++++++++++++++++++++++++++------
 1 files changed, 46 insertions(+), 8 deletions(-)
