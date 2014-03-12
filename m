From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: [PATCH net-next 02/10] 8139too: Call dev_kfree_skby_any instead
 of dev_kfree_skb.
Date: Wed, 12 Mar 2014 22:24:29 +0100
Message-ID: <20140312212429.GA14893@electric-eye.fr.zoreil.com>
References: <87a9cxf7mp.fsf_-_@xmission.com>
 <20140311.124907.1180556684992271103.davem@davemloft.net>
 <87wqg0cy9d.fsf@xmission.com>
 <20140311.160931.1395978386605601765.davem@davemloft.net>
 <87r468bfqj.fsf_-_@xmission.com>
 <87fvmobfnr.fsf_-_@xmission.com>
 <1394589986.21721.37.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "Eric W. Biederman" <ebiederm@xmission.com>,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	xiyou.wangcong@gmail.com, mpm@selenic.com, satyam.sharma@gmail.com
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from violet.fr.zoreil.com ([92.243.8.30]:44776 "EHLO
	violet.fr.zoreil.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751244AbaCLVYj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 12 Mar 2014 17:24:39 -0400
Content-Disposition: inline
In-Reply-To: <1394589986.21721.37.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Eric Dumazet <eric.dumazet@gmail.com> :
[...]
> Same u64_stats_fetch_begin_bh() problem for this driver to fetch TX
> stats.

Same problem for any NAPI context Tx completing driver that claims
netpoll support. For instance:
drivers/net/ethernet/emulex/benet
drivers/net/ethernet/intel/i40e
drivers/net/ethernet/intel/igb
drivers/net/ethernet/intel/ixgbe
drivers/net/ethernet/marvell/sky2.c
drivers/net/ethernet/neterion/vxge ?

Similar problem for the drivers below. They update Tx stats in start_xmit
and use u64_.*_bh:
drivers/net/ethernet/tile/tilepro.c
drivers/net/team/team.c
drivers/net/virtio_net.c

-- 
Ueimor
