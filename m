From: Krzysztof Halasa <khc@pm.waw.pl>
Subject: Re: Linux, tcpdump and vlan
Date: Thu, 19 Jul 2007 15:28:46 +0200
Message-ID: <m3zm1sbjzl.fsf@maximus.localdomain>
References: <878246.51044.qm@web56608.mail.re3.yahoo.com>
	<469E9AC8.3090603@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: andrei radulescu-banu <iubica2@yahoo.com>,
	linux-kernel@vger.kernel.org,
	Linux Netdev List <netdev@vger.kernel.org>
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from khc.piap.pl ([195.187.100.11]:34655 "EHLO khc.piap.pl"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754016AbXGSN2u (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 19 Jul 2007 09:28:50 -0400
In-Reply-To: <469E9AC8.3090603@trash.net> (Patrick McHardy's message of "Thu, 19 Jul 2007 00:57:12 +0200")
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Patrick McHardy <kaber@trash.net> writes:

> Your suggestion of disabling VLAN acceleration in promiscous
> mode sounds like a reasonable solution until then ..

>From a user perspective:

I'm not sure promiscous mode is related to the problem.
Tcpdump without promiscous mode makes perfect sense.

I don't know very well VLAN code internals, but I think
the VLAN # is used for looking up the interface, so
presenting the "original" packet on the trunk device
would IMHO involve some skb cloning, and perhaps some
ethtool option could probably control that.

Not sure about untagged frames vs. tagged frames with
the default VLAN id - can the hardware at all differentiate
between them?


Or, perhaps it should be left (almost) as is - with "software"
VLANs the traffic always goes through the master interface,
but with "accelerated" mode it only goes through logical
interfaces and doesn't show up on master? Probably with
exception of invalid VLANs, which could be injected back to
master (because no logical device exists)?
-- 
Krzysztof Halasa
