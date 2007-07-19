From: Krzysztof Halasa <khc@pm.waw.pl>
Subject: Re: Linux, tcpdump and vlan
Date: Thu, 19 Jul 2007 16:23:48 +0200
Message-ID: <m3k5swbhfv.fsf@maximus.localdomain>
References: <878246.51044.qm@web56608.mail.re3.yahoo.com>
	<469E9AC8.3090603@trash.net> <m3zm1sbjzl.fsf@maximus.localdomain>
	<20070719144131.0c230c8f@oldman.hamilton.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Patrick McHardy <kaber@trash.net>,
	andrei radulescu-banu <iubica2@yahoo.com>,
	linux-kernel@vger.kernel.org,
	Linux Netdev List <netdev@vger.kernel.org>
To: Stephen Hemminger <shemminger@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from khc.piap.pl ([195.187.100.11]:57650 "EHLO khc.piap.pl"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755886AbXGSOXu (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 19 Jul 2007 10:23:50 -0400
In-Reply-To: <20070719144131.0c230c8f@oldman.hamilton.local> (Stephen Hemminger's message of "Thu, 19 Jul 2007 14:41:31 +0100")
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Stephen Hemminger <shemminger@linux-foundation.org> writes:

> 1) non-accelerated device 
>     * all frames show in promiscious mode
>     * tag is part of the frame that shows up
>        in tcpdump, and then gets stripped by the 8021q module.

Sure. It's IMHO good and working, modulo the tag being removed
on the master device (optional cloning or something, IIRC).

> 2) rx tag stripping device
>      * all frames show in promiscious mode
>      * tag is in skb but NOT passed to tcpdump
> 3) rx vlan acceleration
>      * only frames that for vlan's that are registered show up
>         in promisicous mode
>      * tag is in skb but NOT passed to tcpdump

I wasn't aware of devices doing 3. Aren't we able to tell them
to receive all packets anyway (even unknown VLANs#)?

> Unfortunately, the tag is lost as part of the VLAN acceleration process
> so it is not a simple matter of changing code in AF_PACKET receive
> to restore the tag.

I'm not sure if we really want it. If needed we can disable
acceleration, can't we? While accelerated we can see the packets
(without tags) on logical devices.

However seeing unknown tags on master device (with tcpdump etc)
would certainly be useful.
-- 
Krzysztof Halasa
