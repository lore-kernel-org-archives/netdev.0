From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH iproute2 net-next] bridge: vlan: add support to display
 per-vlan statistics
Date: Tue, 21 Jun 2016 09:01:41 -0700
Message-ID: <20160621090141.0c13d12d@xeon-e3>
References: <1466417599-12940-1-git-send-email-nikolay@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, roopa@cumulusnetworks.com
To: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f180.google.com ([209.85.192.180]:35737 "EHLO
	mail-pf0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750707AbcFUQIX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 21 Jun 2016 12:08:23 -0400
Received: by mail-pf0-f180.google.com with SMTP id c2so8001564pfa.2
        for <netdev@vger.kernel.org>; Tue, 21 Jun 2016 09:08:22 -0700 (PDT)
In-Reply-To: <1466417599-12940-1-git-send-email-nikolay@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 20 Jun 2016 12:13:19 +0200
Nikolay Aleksandrov <nikolay@cumulusnetworks.com> wrote:

> This patch adds support for the -statistics (-s) argument to the bridge
> vlan show command which will display the per-vlan statistics and the bridge
> device each vlan belongs to. The show command filtering options are both
> supported, also the man page is updated to explain the new option.
> This patch uses the new RTM_GETSTATS interface with a filter_mask to dump
> only the bridge vlans. Later we can add support for using the per-device
> dump and filter it in the kernel instead.
> 
> Example:
> $ bridge -s vlan
> port	vlan id	stats
> br0	 1	 RX: 33724730 bytes 492075 packets TX: 67409922 bytes 984029 packets
> 	 100	 RX: 0 bytes 0 packets TX: 0 bytes 0 packets
> 	 200	 RX: 0 bytes 0 packets TX: 0 bytes 0 packets
> 	 300	 RX: 0 bytes 0 packets TX: 0 bytes 0 packets
> 	 301	 RX: 169562135 bytes 790877 packets TX: 169550926 bytes 790824 packets
> br1	 1	 RX: 0 bytes 0 packets TX: 0 bytes 0 packets
> 
> Note that it will print the per-vlan statistics for all vlans in a bridge
> even if the vlan is only added to ports. Later when we add per-port
> per-vlan statistics support, we'll be able to print the exact ports each
> vlan belongs to, not only the bridge.
> 
> Signed-off-by: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>

Thanks, this is a useful tool, but I think the formatting of output may need to be
reworked.  The bridge tool works similar to ip command. And in the ip command the
-s flag causes additional lines, but does not change the output format.

There is also double line spacing in current output, which scrolls off when
managing in little VM windows. Plush the port name is too narrow a field width

Why not something like:

$ bridge vlan
port	   vlan ids
virbr1	   1 PVID Egress Untagged
virbr4	   1 PVID Egress Untagged
virbr0	   1 PVID Egress Untagged

$ bridge -s vlan
virbr1	   1 PVID Egress Untagged
             RX: 33724730 bytes 492075 packets
             TX: 67409922 bytes 984029 packets
virbr0	   1 PVID Egress Untagged
             RX: 169562135 bytes 790877 packets 
             TX: 169550926 bytes 790824 packets

The -d detail flag would also be useful to implement
