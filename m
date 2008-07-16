From: "Jeff Kirsher" <jeffrey.t.kirsher@intel.com>
Subject: Re: [PATCH 0/2]: VLAN filtering fixes
Date: Wed, 16 Jul 2008 14:03:33 -0700
Message-ID: <9929d2390807161403g6db1247due0a209a088846a89@mail.gmail.com>
References: <487DC2C4.9030006@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: "Jeff Garzik" <jgarzik@pobox.com>,
	"Linux Netdev List" <netdev@vger.kernel.org>,
	"Brandeburg, Jesse" <jesse.brandeburg@intel.com>,
	"Allan, Bruce W" <bruce.w.allan@intel.com>,
	"Peter P Waskiewicz Jr" <peter.p.waskiewicz.jr@intel.com>,
	"Ronciak, John" <john.ronciak@intel.com>
To: "Patrick McHardy" <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from wa-out-1112.google.com ([209.85.146.178]:61561 "EHLO
	wa-out-1112.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754102AbYGPVDs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 16 Jul 2008 17:03:48 -0400
Received: by wa-out-1112.google.com with SMTP id j37so3329862waf.23
        for <netdev@vger.kernel.org>; Wed, 16 Jul 2008 14:03:47 -0700 (PDT)
In-Reply-To: <487DC2C4.9030006@trash.net>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jul 16, 2008 at 2:43 AM, Patrick McHardy <kaber@trash.net> wrote:
> These two patches contain the last bits of my VLAN + tcpdump fixes.
> Currently some (all?) drivers have inconsistent behaviour wrt. VLAN
> filtering and promiscous mode:
>
> They start with disabled VLAN filtering, meaning all VLAN packets
> are received on packet sockets. When adding the first VLAN, VLAN
> filtering is enabled and only packets for locally configured VLANs
> are received, even in promiscous mode. In most cases VLAN filtering
> is disabled again when removing the last VLAN, igxbe keeps it enabled
> permanently however.
>
> These patches change the Intel drivers to always enable VLAN filtering
> while not in promiscous mode since there is little point in receiving
> VLAN packets while nothing is interested in them, but disable filtering
> while in promiscous mode so all VLANs are visible to packet sockets.
>
> There are four more drivers that support VLAN filtering that I didn't
> adapt to this behaviour since I'm not sure about what exactly they
> currently do. All four of tehuti, starfire, ehea and via-velocity
> have a flag for the hardware to enable promiscous mode, its unknown
> to me whether this also automatically disables VLAN filtering.
> Any information on this someone might have is appreciated.
>
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>

Acked-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Acked-by: Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>


-- 
Cheers,
Jeff
