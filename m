From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [PATCH net] vxlan: fix missing options_len update on RX with
 collect metadata
Date: Thu, 3 Mar 2016 11:33:57 +0100
Message-ID: <20160303103357.GB18334@pox.localdomain>
References: <ea834e5ecd014f50f9d979ee869f96e5508f8d9c.1456880721.git.daniel@iogearbox.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, pshelar@nicira.com, jesse@kernel.org,
	netdev@vger.kernel.org
To: Daniel Borkmann <daniel@iogearbox.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f47.google.com ([74.125.82.47]:37388 "EHLO
	mail-wm0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751272AbcCCKeA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 Mar 2016 05:34:00 -0500
Received: by mail-wm0-f47.google.com with SMTP id p65so25541614wmp.0
        for <netdev@vger.kernel.org>; Thu, 03 Mar 2016 02:33:59 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <ea834e5ecd014f50f9d979ee869f96e5508f8d9c.1456880721.git.daniel@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 03/02/16 at 02:32am, Daniel Borkmann wrote:
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

Acked-by: Thomas Graf <tgraf@suug.ch>
