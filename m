From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] vxlan: fix missing options_len update on RX with
 collect metadata
Date: Thu, 03 Mar 2016 17:11:14 -0500 (EST)
Message-ID: <20160303.171114.930416753645685563.davem@davemloft.net>
References: <ea834e5ecd014f50f9d979ee869f96e5508f8d9c.1456880721.git.daniel@iogearbox.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: tgraf@suug.ch, pshelar@nicira.com, jesse@kernel.org,
	netdev@vger.kernel.org
To: daniel@iogearbox.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:48190 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752032AbcCCWLQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 Mar 2016 17:11:16 -0500
In-Reply-To: <ea834e5ecd014f50f9d979ee869f96e5508f8d9c.1456880721.git.daniel@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Daniel Borkmann <daniel@iogearbox.net>
Date: Wed,  2 Mar 2016 02:32:08 +0100

> When signalling to metadata consumers that the metadata_dst entry
> carries additional GBP extension data for vxlan (TUNNEL_VXLAN_OPT),
> the dst's vxlan_metadata information is populated, but options_len
> is left to zero. F.e. in ovs, ovs_flow_key_extract() checks for
> options_len before extracting the data through ip_tunnel_info_opts_get().
> 
> Geneve uses ip_tunnel_info_opts_set() helper in receive path, which
> sets options_len internally, vxlan however uses ip_tunnel_info_opts(),
> so when filling vxlan_metadata, we do need to update options_len.
> 
> Fixes: 4c22279848c5 ("ip-tunnel: Use API to access tunnel metadata options.")
> Signed-off-by: Daniel Borkmann <daniel@iogearbox.net>

Applied and queued up for -stable, thanks Daniel.
