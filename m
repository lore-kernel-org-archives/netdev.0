From: Or Gerlitz <ogerlitz@voltaire.com>
Subject: Re: [evb] RE: [PATCH][RFC] net/bridge: add basic VEPA support
Date: Thu, 27 Aug 2009 15:35:55 +0300
Message-ID: <4A967DAB.2010209@voltaire.com>
References: <D2E118A1E7268F449C469EA2F301D92902BC39B2@exil.voltaire.com>	<000001ca17a3$03f841f0$0be8c5d0$@edu> <20090807143652.1659ac57@nehalam>	<4A7EB0AC.2030104@Voltaire.com> <20090810082037.17b352c2@nehalam>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "Paul Congdon (UC Davis)" <ptcongdon@ucdavis.edu>, arnd@arndb.de,
	anna.fischer@hp.com, netdev@vger.kernel.org,
	bridge@lists.linux-foundation.org, davem@davemloft.net,
	adobriyan@gmail.com, virtualization@lists.linux-foundation.org,
	"evb@yahoogroups.com" <evb@yahoogroups.com>
To: Stephen Hemminger <shemminger@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from fwil.voltaire.com ([193.47.165.2]:43529 "EHLO exil.voltaire.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751476AbZH0MgG (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 27 Aug 2009 08:36:06 -0400
In-Reply-To: <20090810082037.17b352c2@nehalam>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Stephen Hemminger wrote:
> Or Gerlitz <ogerlitz@voltaire.com> wrote:
>> Looking in macvlan_set_multicast_list() it acts in a similar manner to macvlan_set_mac_address() in the sense that it calls dev_mc_sync(). I assume what's left is to add macvlan_hash_xxx multicast logic to map/unmap multicast groups to what macvlan devices want to receive them and this way the flooding can be removed, correct?
> The device can just flood all multicast packets, since the filtering is done on the receive path anyway.
for each multicast packet, macvlan_broadcast is invoked and calls 
skb_clone/ netif_rx for each device, now a smart scheme that takes into 
account (hash) the multicast list of the different macvlan  devices 
would save the skb_clone call, isn't it?

Or.

