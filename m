From: Alexander Duyck <aduyck@mirantis.com>
Subject: [next-queue PATCH 0/3] Add support for GSO partial to Intel NIC
 drivers
Date: Fri, 08 Apr 2016 17:06:34 -0400
Message-ID: <20160408210103.13096.77973.stgit@ahduyck-xeon-server>
References: <20160408203013.12838.63429.stgit@ahduyck-xeon-server>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
To: herbert@gondor.apana.org.au, tom@herbertland.com, jesse@kernel.org,
	alexander.duyck@gmail.com, edumazet@google.com,
	intel-wired-lan@lists.osuosl.org, jeffrey.t.kirsher@intel.com,
	netdev@vger.kernel.org, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f170.google.com ([209.85.192.170]:33890 "EHLO
	mail-pf0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750819AbcDHVGj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 8 Apr 2016 17:06:39 -0400
Received: by mail-pf0-f170.google.com with SMTP id c20so82557903pfc.1
        for <netdev@vger.kernel.org>; Fri, 08 Apr 2016 14:06:38 -0700 (PDT)
In-Reply-To: <20160408203013.12838.63429.stgit@ahduyck-xeon-server>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

So these are the patches needed to enable tunnel segmentation offloads on
the igb, igbvf, ixgbe, and ixgbevf drivers.  In addition this patch extends
the i40e and i40evf drivers to include segmentation support for tunnels
with outer checksums.

The net performance gain for these patches are pretty significant.  In the
case of i40e a tunnel with outer checksums showed the following
improvement:
Throughput Throughput  Local Local   Result 
           Units       CPU   Service Tag    
                       Util  Demand         
                       %                    
14066.29   10^6bits/s  3.49  0.651   "before" 
20618.16   10^6bits/s  3.09  0.393   "after"

For ixgbe similar results were seen:
Throughput Throughput  Local  Local   Result 
           Units       CPU    Service Tag    
                       Util   Demand         
                       %               
12879.89   10^6bits/s  10.00  0.763   "before"
14286.77   10^6bits/s  5.74   0.395   "after" 

These patches all rely on the TSO_MANGLEID and GSO_PARTIAL patches so I
would not recommend applying them until those patches have first been
applied.

---

Alexander Duyck (3):
      i40e/i40evf: Add support for GSO partial with UDP_TUNNEL_CSUM and GRE_CSUM
      ixgbe/ixgbevf: Add support for GSO partial
      igb/igbvf: Add support for GSO partial


 drivers/net/ethernet/intel/i40e/i40e_main.c       |   10 +
 drivers/net/ethernet/intel/i40e/i40e_txrx.c       |    7 +
 drivers/net/ethernet/intel/i40evf/i40e_txrx.c     |    7 +
 drivers/net/ethernet/intel/i40evf/i40evf_main.c   |   10 +
 drivers/net/ethernet/intel/igb/igb_main.c         |  112 ++++++++++----
 drivers/net/ethernet/intel/igbvf/netdev.c         |  173 +++++++++++++--------
 drivers/net/ethernet/intel/ixgbe/ixgbe_main.c     |  105 +++++++++----
 drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c |  123 ++++++++++++---
 8 files changed, 391 insertions(+), 156 deletions(-)
