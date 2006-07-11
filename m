From: Stefan Rompf <stefan@loplof.de>
Subject: Re: [RFC] vlan handling of up/down
Date: Wed, 12 Jul 2006 00:19:22 +0200
Message-ID: <200607120019.22821.stefan@loplof.de>
References: <200603211829.k2LITMNR029085@hera.kernel.org> <200607110001.14812.stefan@loplof.de> <20060711142808.1a6a47bb@dxpl.pdx.osdl.net>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Patrick McHardy <kaber@trash.net>,
	Ben Greear <greearb@candelatech.com>,
	Linux Netdev List <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from natlemon.rzone.de ([81.169.145.170]:48374 "EHLO
	natlemon.rzone.de") by vger.kernel.org with ESMTP id S932193AbWGKWQP
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 11 Jul 2006 18:16:15 -0400
To: Stephen Hemminger <shemminger@osdl.org>
In-Reply-To: <20060711142808.1a6a47bb@dxpl.pdx.osdl.net>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Am Dienstag, 11. Juli 2006 23:28 schrieb Stephen Hemminger:

> Untested, but here is the basic idea of how I think up/down should be
> handled.  Basically, rather than changing the flags directly the VLAN code
> should call dev_open/dev_close.  The notifier end's up recursively calling
> but this is okay.

Seems false alarm. I've just tested 2.6.16(-Suse), and new VLAN devices have 
been registered as admin down. Same for 2.6.17 as even with my change 
__LINK_STATE_START was not transferred.

> -	new_dev->state = real_dev->state & ~(1<<__LINK_STATE_START);

No reason to change this behaviour, we just need to stop messing with 
new_dev->state (IMHO too late for 2.6.18, but I've already been wrong ;-)

Stefan
