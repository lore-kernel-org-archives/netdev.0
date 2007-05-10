From: jamal <hadi@cyberus.ca>
Subject: RE: [PATCH] IPROUTE: Modify tc for new PRIO multiqueue behavior
Date: Thu, 10 May 2007 08:35:51 -0400
Message-ID: <1178800551.4074.34.camel@localhost>
References: <D5C1322C3E673F459512FB59E0DDC32902CDF558@orsmsx414.amr.corp.intel.com>
	 <1178666902.4055.28.camel@localhost>
	 <1178766140.3045.24.camel@debian.sh.intel.com>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: "Waskiewicz Jr, Peter P" <peter.p.waskiewicz.jr@intel.com>,
	Johannes Berg <johannes@sipsolutions.net>,
	Stephen Hemminger <shemminger@linux-foundation.org>,
	Patrick McHardy <kaber@trash.net>, netdev@vger.kernel.org,
	jgarzik@pobox.com, cramerj <cramerj@intel.com>,
	"Kok, Auke-jan H" <auke-jan.h.kok@intel.com>,
	"Leech, Christopher" <christopher.leech@intel.com>,
	davem@davemloft.net
To: Zhu Yi <yi.zhu@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from wx-out-0506.google.com ([66.249.82.234]:36205 "EHLO
	wx-out-0506.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751349AbXEJMf4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 10 May 2007 08:35:56 -0400
Received: by wx-out-0506.google.com with SMTP id h31so519256wxd
        for <netdev@vger.kernel.org>; Thu, 10 May 2007 05:35:56 -0700 (PDT)
In-Reply-To: <1178766140.3045.24.camel@debian.sh.intel.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 2007-10-05 at 11:02 +0800, Zhu Yi wrote:

> The difference is the hub provides the same transmission chance for all
> the packets but in wireless, high priority packets will block low
> priority packets transmission. You can argue there is still chances a
> low priority packet is sent first before a high priority one. But this
> is not the point of wireless QoS. It rarely happens and should be avoid
> at best effort in the implementation.

So we may be agreeing then?
In other words, if you had both low prio and high prio in WMM scheduler
(in wireless hardware) then the station favors a higher priority packet
over at low priority packet at ALL times.
IOW:
Given the default 802.11e AIFS, CWmin/max and PF (and TXOP) parameters
used for the different WMM queues there is no way that a lower prio
packet will ever be allowed to leave when it is competing with a higher
prio packet. 
This approach is what the strict prio qdisc already does. The slight
difference is the prio qdisc is deterministic and the WMM is statistical
(strict prio) in nature -  i.e there is a statiscal "luck" possibility
(not design intent) for an lower prio packet to go out.

Does this make sense?

cheers,
jamal



