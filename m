From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: [net-next-2.6 PATCH v2 1/3] net: implement mechanism for HW
 based QOS
Date: Wed, 22 Dec 2010 10:12:29 +0100
Message-ID: <1293009149.3531.12.camel@jlt3.sipsolutions.net>
References: <20101221192831.9703.56356.stgit@jf-dev1-dcblab>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org, hadi@cyberus.ca,
	shemminger@vyatta.com, tgraf@infradead.org, eric.dumazet@gmail.com,
	bhutchings@solarflare.com, nhorman@tuxdriver.com
To: John Fastabend <john.r.fastabend@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from he.sipsolutions.net ([78.46.109.217]:35641 "EHLO
	sipsolutions.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751290Ab0LVJMU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 22 Dec 2010 04:12:20 -0500
In-Reply-To: <20101221192831.9703.56356.stgit@jf-dev1-dcblab>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2010-12-21 at 11:28 -0800, John Fastabend wrote:
> This patch provides a mechanism for lower layer devices to
> steer traffic using skb->priority to tx queues. This allows
> for hardware based QOS schemes to use the default qdisc without
> incurring the penalties related to global state and the qdisc
> lock. While reliably receiving skbs on the correct tx ring
> to avoid head of line blocking resulting from shuffling in
> the LLD. Finally, all the goodness from txq caching and xps/rps
> can still be leveraged.

Is there any chance this might be applicable to the 802.11 layer as
well? We will definitely still need an ndo_select_queue handler to reset
in the case where the peer doesn't support QoS, but it seems the part
that depends on the frame itself could be pushed out to the generic
framework instead of having net/wireless/util.c:cfg80211_classify8021d?

johannes

