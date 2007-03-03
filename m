From: Andi Kleen <andi@firstfloor.org>
Subject: Re: Network activity LED trigger
Date: 03 Mar 2007 03:20:00 +0100
Message-ID: <p73y7mfax0v.fsf@bingen.suse.de>
References: <200703012241.49165.florian.fainelli@int-evry.fr>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, Richard Purdie <rpurdie@rpsys.net>
To: Florian Fainelli <florian.fainelli@int-evry.fr>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.suse.de ([195.135.220.2]:58174 "EHLO mx1.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S2992857AbXCCBUi (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 2 Mar 2007 20:20:38 -0500
In-Reply-To: <200703012241.49165.florian.fainelli@int-evry.fr>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Florian Fainelli <florian.fainelli@int-evry.fr> writes:

> Hi All,
> 
> I have been talking a bit with Richard, who is the LED API maintainer, and a 
> LED trigger based on network activity would be something great.

You should be aware that normally the kernel doesn't see all packets
on a ethernet unless promiscuous mode is enabled (which it is normally 
not). That is because the hardware filters out all packets
not for this host. A software controlled LED wouldn't be equivalent
to the activity LEDs you normally have on network cards,
but only show local traffic.

That said if you want to get events for any in/outgoing packets
you can use the same hooks as PF_PACKET uses for sniffing;
using dev_add_pack with ETH_P_ALL.
That will get you all incoming and outgoing packets that 
are local.

And when someone runs tcpdump it will suddenly see all which
might be unexpected.

-Andi
