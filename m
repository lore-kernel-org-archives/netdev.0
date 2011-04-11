From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH net-next-2.6] ethtool: Compat handling for struct
 ethtool_rxnfc
Date: Mon, 11 Apr 2011 18:10:57 +0100
Message-ID: <1302541857.3680.1.camel@bwh-desktop>
References: <1298917347.2569.5.camel@bwh-desktop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Alexander Duyck <alexander.h.duyck@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exchange.solarflare.com ([216.237.3.220]:35719 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751990Ab1DKRLA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 11 Apr 2011 13:11:00 -0400
In-Reply-To: <1298917347.2569.5.camel@bwh-desktop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2011-02-28 at 18:22 +0000, Ben Hutchings wrote:
> This structure was accidentally defined such that its layout can
> differ between 32-bit and 64-bit processes.  Add compat structure
> definitions and functions to copy from/to user-space with the
> necessary adjustments.

Damnit, we have to do the same thing for struct ethtool_rx_ntuple:

$ cc -m64 test.c
$ ./a.out
sizeof(struct ethtool_rx_ntuple) = 184
offsetof(ethtool_rx_ntuple, fs) = 8
offsetof(ethtool_rx_ntuple_flow_spec, vlan_tag) = 148
offsetof(ethtool_rx_ntuple_flow_spec, data) = 152
$ cc -m32 test.c
$ ./a.out
sizeof(struct ethtool_rx_ntuple) = 176
offsetof(ethtool_rx_ntuple, fs) = 4
offsetof(ethtool_rx_ntuple_flow_spec, vlan_tag) = 148
offsetof(ethtool_rx_ntuple_flow_spec, data) = 152

At least there's only one hole to deal with in this case.

Ben.

-- 
Ben Hutchings, Senior Software Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

