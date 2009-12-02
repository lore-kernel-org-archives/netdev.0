From: "Eilon Greenstein" <eilong@broadcom.com>
Subject: Re: "NIG timer max" messages from bnx2x
Date: Wed, 2 Dec 2009 20:41:03 +0200
Message-ID: <1259779263.2020.6.camel@lb-tlvb-eilong>
References: <4B168F04.60309@redpill-linpro.com>
Reply-To: eilong@broadcom.com
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"Benjamin Li" <benli@broadcom.com>
To: "Tore Anderson" <tore.anderson@redpill-linpro.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms3.broadcom.com ([216.31.210.19]:2521 "EHLO MMS3.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755187AbZLBSlE (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 2 Dec 2009 13:41:04 -0500
In-Reply-To: <4B168F04.60309@redpill-linpro.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2009-12-02 at 08:00 -0800, Tore Anderson wrote:
> Hello list,
> 
> I'm having a strange error condition I'm hoping someone here might be
> able to help me get to the bottom of.  I've got a HP blade enclosure
> with a Nortel switch module, and one of the blades are running VMWare
> ESX.  When I turn on this blade (or enable its switch port), the entire
> network stops working after a short while.  Other server blades can no
> longer communicate, for instance.  The only clue I've found so far is
> the following error message from one of the other blades that's running
> CentOS 5.4:
> 
> [bnx2x_hw_stats_update:3701(eth0)]NIG timer max (426)
> 
> The line is logged every two seconds and the number in parenthesis is
> incrementing each time.  Once I disable the port to the ESX server, the
> network instantly recovers.
> 
> I have no reason to believe the Linux kernel/bnx2x is doing anything
> wrong here, but I'm wondering if anybody has any idea on what this error
> message means and what could be causing it?  I can't see anything
> unusual going on with tcpdump, and the error counters in "ip -s -s link
> show eth0" are all zero.

This message indicates that for over 1 second, the device could not
transmit anything to the network (the same packet was not transmitted
for over one second) - this usually happens when the network is in fatal
condition - usually because some device is sending constant pause stream
that halts all traffic. In this case, the device is incrementing the
counter and drains outgoing traffic - without this action, the device
will not be able to unload since even the commands from the driver will
not be processed due to this excessive back pressure.

As you indicated - once you remove the server that halts all other
traffic, everything else resumes - that indicates that this server is
sending constant pause that ultimately halts the entire switch.

Regards,
Eilon


