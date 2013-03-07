From: Glen Turner <gdt@gdt.id.au>
Subject: Re: [PATCH net-next] bond: add support to read speed and duplex via ethtool
Date: Thu, 7 Mar 2013 22:41:57 +1030
Message-ID: <58A138EA-ADB5-4DFC-AA35-2D0E578483FD@gdt.id.au>
References: <1362595173-11442-1-git-send-email-andy@greyhouse.net> <22416.1362597912@death.nxdomain> <20130306200140.GB19544@gospo.rdu.redhat.com> <27035.1362606373@death.nxdomain>
Mime-Version: 1.0 (Apple Message framework v1283)
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 8BIT
Cc: netdev@vger.kernel.org
To: Andy Gospodarek <andy@greyhouse.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from eth6445.sa.adsl.internode.on.net ([150.101.30.44]:36778 "EHLO
	aix.gdt.id.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751226Ab3CGMMI convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 7 Mar 2013 07:12:08 -0500
In-Reply-To: <27035.1362606373@death.nxdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Andy,

How does this relate to the bandwidth metric for an interface as seen by routing daemons?

An interface bandwidth as seen by routing daemons cannot change once carrier is up. Otherwise flaps of a link within a bond will cause routing protocol flaps; which they do not do at the moment, and which would be deeply, deeply undesirable.

I'd just add the maximum possible bandwidth of the interfaces, rather than the negotiated value. That's enough to get SNMP graphs working reasonably. It's not clear that a SNMP grapher will have reasonable behaviour with a changing bandwidth -- you'll end up with graphs where absolute throughput appears to fall, but what has happened is that a link has come online and utilisation has fallen. That's not a useful graph, as it's very much the "shape" of the traffic which is useful.

Checked IOS and JUNOS. In the absence of nerd knobs, both report the sum of the maximum possible interface bandwidths. So that's probably the behaviour SNMP graphing tools expect in any case.

Cheers, glen