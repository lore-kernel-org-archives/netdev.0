From: Michal Kubecek <mkubecek@suse.cz>
Subject: Re: Fw: [Bug 82471] New: net/core/dev.c skb_war_bad_offload
Date: Wed, 17 Dec 2014 10:55:53 +0100
Message-ID: <20141217095552.GB27966@unicorn.suse.cz>
References: <1418805852.5277.25.camel@watermelon.coderich.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Richard Laager <rlaager@wiktel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cantor2.suse.de ([195.135.220.15]:42496 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751033AbaLQJzy (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 17 Dec 2014 04:55:54 -0500
Content-Disposition: inline
In-Reply-To: <1418805852.5277.25.camel@watermelon.coderich.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Dec 17, 2014 at 02:44:12AM -0600, Richard Laager wrote:
> Previous history of this thread:
> http://thread.gmane.org/gmane.linux.network/326672
> 
> On 2014-11-04 22:57:19, Tom Herbert wrote:
> > Using vlan and bonding? vlan_dev_hard_start_xmit called. A possible
> > cause is that bonding interface is out of sync with slave interface
> > w.r.t. GSO features. Do we know if this worked in 3.14, 3.15?
> 
> I'm seeing the same sort of crash/warning (skb_war_bad_offload). It's
> happening on Intel 10 Gig NICs using the ixgbe driver. I'm using bridges
> (for virtual machines) on top of VLANs on top of 802.3ad bonding. I'm
> using an MTU of 9000 on the bond0 interface, but 1500 everywhere else.
> 
> I'm always bonding two ports: one one system, I'm bonding two ports on
> identical one-port NICs; on another system, I'm bonding two ports on a
> single two-port NIC. Both systems exhibit the same behavior.
> 
> Everything has worked fine for a couple years on Ubuntu 12.04 Precise
> (Linux 3.2.0). It immediately broke when I upgraded to Ubuntu 14.04
> Trusty (Linux 3.13.0). I can also reproduce this using the packaged
> version of Linux 3.16.0 on Trusty.

Would it be possible that the kernel you are using has

  da08143b8520 ("vlan: more careful checksum features handling")

(and possibly also a9b3ace44c7d and 3625920b62c3) but not

  db115037bb57 ("net: fix checksum features handling in netif_skb_features()")

?

Michal Kubecek
