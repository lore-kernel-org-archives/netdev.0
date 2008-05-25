From: Glen Turner <gdt@gdt.id.au>
Subject: Re: [PATCH] drivers/net: remove network drivers' last few uses of
	IRQF_SAMPLE_RANDOM
Date: Mon, 26 May 2008 00:25:28 +0930
Message-ID: <1211727328.5913.58.camel@andromache>
References: <Pine.LNX.4.62.0805150009060.18303@ikari.dreamhost.com>
	 <20080515142154.0595e475@core>
	 <36D9DB17C6DE9E40B059440DB8D95F52052D71BB@orsmsx418.amr.corp.intel.com>
	 <482C7B18.6060003@garzik.org> <482C7E53.3050300@hp.com>
	 <482C8184.2030906@garzik.org>  <482C8550.5000909@intel.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Jeff Garzik <jeff@garzik.org>, Rick Jones <rick.jones2@hp.com>,
	"Brandeburg, Jesse" <jesse.brandeburg@intel.com>,
	Alan Cox <alan@lxorguk.ukuu.org.uk>,
	Chris Peterson <cpeterso@cpeterso.com>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: "Kok, Auke" <auke-jan.h.kok@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from eth6445.sa.adsl.internode.on.net ([150.101.30.44]:39064 "EHLO
	aix.gdt.id.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1754304AbYEYPfA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 25 May 2008 11:35:00 -0400
In-Reply-To: <482C8550.5000909@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2008-05-15 at 11:47 -0700, Kok, Auke wrote:

> How about the non-NAPI and non-throttled case? I would argue that without any irq
> mitigation we can still use SA_RANDOM.

You don't know what packet-shaping us upstream ISPs are using.
If we're shaping then we're moving packets in time so that they
arrive upon the ticking of a output queue playout clock.  That
is, packet arrival becomes periodic not random.

Linux has a class-based queuing implementation and this would
have a similar effect on outbound packets.

Nearby microwave ovens will add periodicy to the arrival
of WLAN data. It wouldn't shock me if multicast traffic
over WLANs (even if not addressed to the host in question)
had the same effect on unicast data.

TCP's behaviour hardly leads to random packet arrival times.
Take the probability of TCP data inter-packet arrival times.
It is at least a binomial distribution (and thus not a random
distribution, and thus not suitable for /dev/random):
 - Case A: first packet in a TCP window transmission
 - Case B: subsequent packets in a TCP window transmission
           (probability rises to near 1 that another packet
            will shortly follow this one).
TCP packet transmission times are also binomial and strongly
self-correlated.

Worst of all, packet arrivals and departures are remotely observable,
both to a classic remote attacker with access to the comms channel and
to another user on a multiuser host.  So even if packet arrivals and
departures were totally random they would not be of use, since the
"random" numbers which contribute to the key would be known to the
attacker.

Regards, Glen

