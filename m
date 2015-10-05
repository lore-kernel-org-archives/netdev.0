From: David Miller <davem@davemloft.net>
Subject: Re: [net] i40e: fix offload of GRE tunnels
Date: Mon, 05 Oct 2015 04:32:02 -0700 (PDT)
Message-ID: <20151005.043202.1092370306439477882.davem@davemloft.net>
References: <1443749142-40988-1-git-send-email-jeffrey.t.kirsher@intel.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jesse.brandeburg@intel.com, netdev@vger.kernel.org,
	nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com
To: jeffrey.t.kirsher@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:39316 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750938AbbJELQX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 5 Oct 2015 07:16:23 -0400
In-Reply-To: <1443749142-40988-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Date: Thu,  1 Oct 2015 18:25:42 -0700

> From: Jesse Brandeburg <jesse.brandeburg@intel.com>
> 
> The driver still was not offloading TSO on GRE tunnels because
> it forgot to set the GSO_GRE flag, causing lots of retransmits.
> 
> This fixes generic GRE traffic (like a tunnel added like below)
> whereas before it would get 1Gb/s or less, now on a 10G adapter
> it gets 8.7Gb/s.
> 
> ip ad ad 11.1.0.2/24 dev ens2f0
> ip l set ens2f0 up
> ip link add gre2 type gretap remote 11.1.0.1 local 11.1.0.2 dev ens2f0
> ip l set gre2 up
> ip ad ad 192.168.124.2/24 dev gre2
> ping 192.168.124.1
> netperf -H 192.168.124.1
> 
> Signed-off-by: Jesse Brandeburg <jesse.brandeburg@intel.com>
> Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>

Applied, thanks.
