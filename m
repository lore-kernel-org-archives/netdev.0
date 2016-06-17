From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] mpls: allow routes on ipgre devices
Date: Thu, 16 Jun 2016 17:14:11 -0700 (PDT)
Message-ID: <20160616.171411.1102610413053475579.davem@davemloft.net>
References: <1466064549-32647-1-git-send-email-simon.horman@netronome.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, rshearma@brocade.com,
	roopa@cumulusnetworks.com
To: simon.horman@netronome.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:44468 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753830AbcFQAON (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 16 Jun 2016 20:14:13 -0400
In-Reply-To: <1466064549-32647-1-git-send-email-simon.horman@netronome.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Simon Horman <simon.horman@netronome.com>
Date: Thu, 16 Jun 2016 17:09:09 +0900

> This appears to be necessary and sufficient to provide
> MPLS in GRE (RFC4023) support.
> 
> This can be used by establishing an ipgre tunnel device
> and then routing MPLS over it.
> 
> The following example will forward MPLS frames received with an outermost
> MPLS label 100 over tun1, a GRE tunnel. The forwarded packet will have the
> outermost MPLS LSE removed and two new LSEs added with labels 200
> (outermost) and 300 (next).
> 
> ip link add name tun1 type gre remote 10.0.99.193 local 10.0.99.192 ttl 225
> ip link set up dev tun1
> ip addr add 10.0.98.192/24 dev tun1
> ip route sh
> 
> echo 1 > /proc/sys/net/mpls/conf/eth0/input
> echo 101 > /proc/sys/net/mpls/platform_labels
> ip -f mpls route add 100 as 200/300 via inet 10.0.98.193
> ip -f mpls route sh
> 
> Also remove unnecessary braces.
> 
> Reviewed-by: Dinan Gunawardena <dinan.gunawardena@netronome.com>
> Signed-off-by: Simon Horman <simon.horman@netronome.com>

Applied, thanks Simon.
