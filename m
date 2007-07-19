From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: Re: Linux, tcpdump and vlan
Date: Thu, 19 Jul 2007 16:00:33 +0100
Message-ID: <20070719160033.628f39e1@oldman.hamilton.local>
References: <878246.51044.qm@web56608.mail.re3.yahoo.com>
	<469E9AC8.3090603@trash.net>
	<m3zm1sbjzl.fsf@maximus.localdomain>
	<20070719144131.0c230c8f@oldman.hamilton.local>
	<m3k5swbhfv.fsf@maximus.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Patrick McHardy <kaber@trash.net>,
	andrei radulescu-banu <iubica2@yahoo.com>,
	linux-kernel@vger.kernel.org,
	Linux Netdev List <netdev@vger.kernel.org>
To: Krzysztof Halasa <khc@pm.waw.pl>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2.linux-foundation.org ([207.189.120.14]:34232 "EHLO
	smtp2.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754928AbXGSPBP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 Jul 2007 11:01:15 -0400
In-Reply-To: <m3k5swbhfv.fsf@maximus.localdomain>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 19 Jul 2007 16:23:48 +0200
Krzysztof Halasa <khc@pm.waw.pl> wrote:

> Stephen Hemminger <shemminger@linux-foundation.org> writes:
> 
> > 1) non-accelerated device 
> >     * all frames show in promiscious mode
> >     * tag is part of the frame that shows up
> >        in tcpdump, and then gets stripped by the 8021q module.
> 
> Sure. It's IMHO good and working, modulo the tag being removed
> on the master device (optional cloning or something, IIRC).
> 
> > 2) rx tag stripping device
> >      * all frames show in promiscious mode
> >      * tag is in skb but NOT passed to tcpdump
> > 3) rx vlan acceleration
> >      * only frames that for vlan's that are registered show up
> >         in promisicous mode
> >      * tag is in skb but NOT passed to tcpdump
> 
> I wasn't aware of devices doing 3. Aren't we able to tell them
> to receive all packets anyway (even unknown VLANs#)?

See NETIF_F_HW_VLAN_FILTER (e1000, etc).

> > Unfortunately, the tag is lost as part of the VLAN acceleration process
> > so it is not a simple matter of changing code in AF_PACKET receive
> > to restore the tag.
> 
> I'm not sure if we really want it. If needed we can disable
> acceleration, can't we? While accelerated we can see the packets
> (without tags) on logical devices.

Not at runtime, acceleration is always on if you compile kernel with vlan
support.  That is a design mistake as far as I can tell.

> However seeing unknown tags on master device (with tcpdump etc)
> would certainly be useful.

Only in promiscuous mode. In some sense tag is part of the mac address.
