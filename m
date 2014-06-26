From: Maxime Bizon <mbizon@freebox.fr>
Subject: Re: [PATCH] bridge: mark packets sent to any local mac address as
 PACKET_HOST
Date: Thu, 26 Jun 2014 13:15:52 +0200
Message-ID: <1403781352.52578.103.camel@sakura.staff.proxad.net>
References: <1403534015-28496-1-git-send-email-mbizon@freebox.fr>
	 <20140625161335.11598f09@haswell>
Reply-To: mbizon@freebox.fr
Mime-Version: 1.0
Content-Type: text/plain; charset="ANSI_X3.4-1968"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	bridge@lists.linux-foundation.org
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ns.iliad.fr ([212.27.33.1]:36542 "EHLO ns.iliad.fr"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755679AbaFZLPy (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 26 Jun 2014 07:15:54 -0400
In-Reply-To: <20140625161335.11598f09@haswell>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


On Wed, 2014-06-25 at 16:13 -0700, Stephen Hemminger wrote:

> > The bridge code only set PACKET_HOST on packets sent to the bridge mac
> > address, packets sent to other local mac addresses are sent to upper
> > layers, but ignored because they are marked as PACKET_OTHERHOST.
> > 
> > Signed-off-by: Maxime Bizon <mbizon@freebox.fr>
> 
> What are you trying to do? Bridge device itself only has one MAC address.
> Are you trying to run macvlan on top of bridge?
> We only respond to ARP with bridge's MAC address.

host1 uses a bridge with two interfaces: ethernet and wireless (AP mode
using hostapd)

for some reasons, hostapd kept adding and removing the interface from
the bridge, triggering a mac address of the bridge change each time (I
did not notice that).

Another host had a static arp entry for host1, using the ethernet mac
address, so its packets to host1 were randomly trashed depending on the
current mac of the bridge.

I have since fixed this by setting a static mac address on the bridge to
prevent dynamic change, but I thought this patch would prevent other
people from having the same bug in the future.

What do you think ?

-- 
Maxime
