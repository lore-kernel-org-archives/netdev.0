From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] bridge: allow local delivery when port is
 disabled
Date: Thu, 12 Dec 2013 23:52:28 -0500 (EST)
Message-ID: <20131212.235228.1750048814040164603.davem@davemloft.net>
References: <20131212134159.5bc985a9@nehalam.linuxnetplumber.net>
	<20131212.172637.1846400994523481783.davem@davemloft.net>
	<20131212150523.3c2abeca@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: stephen@networkplumber.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:42165 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750746Ab3LMFFM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 13 Dec 2013 00:05:12 -0500
In-Reply-To: <20131212150523.3c2abeca@nehalam.linuxnetplumber.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stephen Hemminger <stephen@networkplumber.org>
Date: Thu, 12 Dec 2013 15:05:23 -0800

> On Thu, 12 Dec 2013 17:26:37 -0500 (EST)
> David Miller <davem@davemloft.net> wrote:
> 
>> From: Stephen Hemminger <stephen@networkplumber.org>
>> Date: Thu, 12 Dec 2013 13:41:59 -0800
>> 
>> > When an Ethernet device is enslaved to a bridge, and the bridge STP
>> > detects loss of carrier (or operational state down), then normally
>> > packet reception is blocked.
>> > 
>> > This breaks control applications like WPA which maybe expecting to
>> > receive packets to negotiate to bring link up. The bridge needs to
>> > block forwarding packets from these disabled ports, but there is no
>> > hard requirement to not allow local packet delivery.
>> > 
>> > In this special case, packets are not forwarded (local delivery only),
>> > and only packet directed at the address of the Ethernet device are
>> > accepted (no promiscuous or other ports in bridge).
>> > 
>> > The existing code already allowed link-local-address packets in
>> > which is what STP uses to communicate with other bridges.
>> > 
>> > Signed-off-by: Stephen Hemminger <stephen@networkplumber.org>
>> > Signed-off-by: Felix Fietkau <nbd@openwrt.org>
>> 
>> I think this change needs to be more careful about the setting of
>> *pskb.  It should not be assigned if we return RX_HANDLER_CONSUMED.
> 
> It was already in the existing code path for link local.

That's not true, the "*pskb = skb;" assignment was only done when the
code retuned RX_HANDLER_PASS.  You are changing it to unconditionally
make this assignment.
