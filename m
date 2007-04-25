From: Andi Kleen <andi@firstfloor.org>
Subject: Re: 2.6.20.7 mss negotiation and path mtu discovery mostly broken?
Date: 25 Apr 2007 17:10:56 +0200
Message-ID: <p73k5w032wv.fsf@bingen.suse.de>
References: <7CCD07160348804497EF29E9EA5560D7020F6203@exchtewks2.starentnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: <linux-kernel@vger.kernel.org>, netdev@vger.kernel.org
To: "Ristuccia, Brian" <bristuccia@starentnetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ns1.suse.de ([195.135.220.2]:37725 "EHLO mx1.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753875AbXDYONJ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 25 Apr 2007 10:13:09 -0400
In-Reply-To: <7CCD07160348804497EF29E9EA5560D7020F6203@exchtewks2.starentnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

"Ristuccia, Brian" <bristuccia@starentnetworks.com> writes:

> I'm seeing a problem where the kernel attempts to send packets with a
> MSS larger than the one negotiated when the TCP connection is
> established. Even after ICMP "can't fragment" messages arrive, the
> kernel still attempts to increase the MSS rather aggressively. The end
> result is extremely poor throughput when sending to a network with a
> smaller MTU. 
> 
> In /proc/sys/net/ipv4:
> ip_no_pmtu_disc:0
> tcp_mtu_probing:0
> 
> The sending host (10.2.10.254) has an MTU of 9000. The destination host
> (12.33.234.69) has an MTU of 1500. There is one router between the hosts
> which will drop packets with the "DF" flag when they don't fit the
> destination interface's MTU and generates the required icmp can't
> fragment message. 
> 
> The dump shows the initial handshake with correct mss options sent:
> 
> 08:39:55.493029 IP 12.33.234.69.35026 > 10.2.10.254.22: S
> 2768979373:2768979373(
> 0) win 5840 <mss 1460,sackOK,timestamp 3873837730 0,nop,wscale 2>
> 08:39:55.493119 IP 10.2.10.254.22 > 12.33.234.69.35026: S
> 963242385:963242385(0)
>  ack 2768979374 win 17896 <mss 8960,sackOK,timestamp 413751

The MSS clamp for sending to 10.2.10.254.22 is 8960. MSS is only
one way -- each uses what the other tells it.

> In the following dump, the system eventually gets in a state where it
> oscillates between sendng undeliverable 2896 byte packets and
> deliverable 1448 byte ones. 

This should only happen on PMTU expire, which is normally ~15mins.
Perhaps you misconfigured it manually using sysctl.

-And
