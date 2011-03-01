From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [PATCH] bonding: added 802.3ad round-robin hashing policy and
 source mac selection mode
Date: Tue, 1 Mar 2011 15:29:51 -0800
Message-ID: <20110301152951.646451c6@nehalam>
References: <20110301223458.GA24403@yandex-team.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Jay Vosburgh <fubar@us.ibm.com>,
	"David S. Miller" <davem@davemloft.net>
To: "Oleg V. Ukhno" <olegu@yandex-team.ru>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:43949 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757592Ab1CAX3x (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 1 Mar 2011 18:29:53 -0500
In-Reply-To: <20110301223458.GA24403@yandex-team.ru>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2 Mar 2011 01:34:58 +0300
"Oleg V. Ukhno" <olegu@yandex-team.ru> wrote:

> Patch introduces two new (related) features to bonding module.
> First feature is round-robin hashing policy, which is primarily
> intended for use with 802.3ad mode, and puts every next IPv4 and
> IPv6 packet into  next availables slave without taling into account
> which layer3 and above protocol is used.
> Second feature makes possible choosing which MAC-address will be set
> in the transmitted packet - when set to src-mac it will force setting
> slave's interface real MAC address as source MAC address in every
> packet, sent via this slave interface.
> Main goal of this patch is to make possible single TCP stream
> equally striped for both transmitted and received packets over all
> available slaves.
> This operating mode is not fully 802.3ad compliant, and will cause
> some packet reordering in TCP stream, to some kernel tuning may be
> required.
> For correct working enabling round-robin hashing policy plus using
> real slave's MAC addresses as source MAC addresses in transmitted
> packets requires specific switch setting)hashing mode for port-channel
> ("etherchannel) should be set to src-mac or src-dst-mac to get
> correct load-striping on the receiving host's etherchannel.
> General requirements for using bonding in this operating mode are:
> - even and preferrably equal number of slaves on sending and receiving
> hosts;
> - equal RTT between sending and receiving hosts on all slaves;
> - switch capable of doing etherchannels and using src-mac or src-dst-mac
> hashing policy for egress load striping
> 
> Signed-off-by: Oleg V. Ukhno <olegu@yandex-team.ru>

It seems to me the whole bonding policy is getting so complex
that the code is a mess. Perhaps it should be somehow linked into
existing packet classification or firewall mechanisms.  This would
increase the flexibility and reduce the amount of policy code
in the bonding driver itself.



-- 
