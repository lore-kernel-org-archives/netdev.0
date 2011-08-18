From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [RFC PATCH] net: vlan: 802.1ad S-VLAN support
Date: Thu, 18 Aug 2011 15:38:02 +0100
Message-ID: <1313678282.2739.16.camel@bwh-desktop>
References: <1310936105-3494206-1-git-send-email-equinox@diac24.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Patrick McHardy <kaber@trash.net>
To: David Lamparter <equinox@diac24.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.solarflare.com ([216.237.3.220]:43054 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755295Ab1HROiG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 18 Aug 2011 10:38:06 -0400
In-Reply-To: <1310936105-3494206-1-git-send-email-equinox@diac24.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, 2011-07-17 at 22:55 +0200, David Lamparter wrote:
> this adds support for 802.1ad S-VLANs, which basically are regular VLANs
> with a different protocol field. also supported are the legacy QinQ
> 9100/9200/9300 ethertypes. as with the CFI bit for 802.1Q, the DEI bit
> is blissfully ignored.
> 
> this patch modifies the 802.1Q code, but keeps the regular VLAN
> acceleration architecture unchanged. the S-VLAN code does not use that;
> I am not aware of any NIC implementing it for ethertypes other than
> 8100.
[...]

I've not heard of multiple-VLAN-tag-insertion, but any controller that
implements a generic 16-bit checksum should be able to do TX checksum
offload regardless of the number of tags present.  So I think VLAN
devices should have their own vlan_features set to at least:
    NETIF_F_HW_CSUM | NETIF_F_SG | NETIF_F_FRAGLIST | NETIF_F_HIGHDM

Some controllers that rely on header parsing for TX checksum offload can
also handle multiple VLAN tags; our current chips recognise up to 3 VLAN
tags with any of those Ethertypes.  It would be good to have some way
for physical device drivers to advertise this feature so that nested
VLAN devices can take advantage of it.  (I am definitely *not* proposing
vlan2_features, vlan3_features, which wouldn't even be sufficient to
represent Ethertype constraints.)

Ben.

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

