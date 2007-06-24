From: Mark Smith <ipng@69706e6720323030352d30312d31340a.nosense.org>
Subject: Re: [NET 00/02]: MACVLAN driver
Date: Sun, 24 Jun 2007 14:22:48 +0930
Message-ID: <20070624142248.4ac405e2.ipng@69706e6720323030352d30312d31340a.nosense.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Jeff Garzik <jeff@garzik.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from levanto.mail.adnap.net.au ([203.6.132.83]:4565 "EHLO
	levanto.mail.adnap.net.au" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752980AbXFXFoA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 24 Jun 2007 01:44:00 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

(Applogies for not maintaining thread id, I'm not subscribed.)

>> We don't have any clean interfaces by which to do this MAC
>> programming, and we do need something for it soon.


>Yep, that's been on my long term wish list for a while, as well.

>Overall I would like to see a more flexible way of allowing the net 
>stack to learn each NIC's RX filter capabilities, and exploiting them. 
>Plenty of NICs, even 100Mbps ones, support RX filter management that 
>allows scanning for $hw_limit unicast addresses, before having to put 
>the hardware into promisc mode.
>

A thought I had when I discovered this ability in the
Natsemi/NS83815 chip was to use these RX filters for perfect multicast
DA matching until they ran out, and then reverting to the normal
Multicast DA matching mechanisms.

Another alternative use I thought of was to use these filters to filter
out different ethernet protocol types e.g. if an interface is only
going to be processing IPv4 packets, program these filters to only
accept frames with type 0800 for IP and 0806 for ARP, reverting to
non-filtering if there are too many protocol types, as per the way the
interfaces operate today.

I think it could be useful to expose the ability to have the NIC ignore
broadcast packets, or more generally, expose the three catagories of
address recognition that NICs seem to allow to be enabled / disabled -
unicast, multicast and broadcast.

If an interface then didn't need to have broadcast reception enabled
e.g. an IPv6 only interface (or Appletalk), then it wouldn't be,
preventing the host from having to process broadcasts it's going to
ignore anyway.

A future common scenario where this ability might be useful would be
LANs with a mix of IPv4 only, IPv4/IPv6 and IPv6-only nodes.

The ability to enable/disable unicast, multicast and broadcast address
recognition individually on a NIC seems to be widespread -  I've found
that the original early to mid 90s Ne2K chip, the NS8390D, the Netgear
FA311/FA312 chip, the NS83815 and the SMC Epic/100 chip all have
specific individual register values for those three types of addresses.

Regards,
Mark.
