From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: Re: [PATCH]: sky2: Fix VLAN unregistration
Date: Thu, 31 May 2007 11:21:17 -0700
Message-ID: <20070531112117.584141d6@freepuppy>
References: <4659D174.70301@trash.net>
	<20070531101945.2b19faa7@freepuppy>
	<465F07C3.2090503@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Linux Netdev List <netdev@vger.kernel.org>,
	Ben Greear <greearb@candelatech.com>
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([207.189.120.12]:46671 "EHLO smtp.osdl.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1761586AbXEaScn (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 31 May 2007 14:32:43 -0400
In-Reply-To: <465F07C3.2090503@trash.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 31 May 2007 19:37:07 +0200
Patrick McHardy <kaber@trash.net> wrote:

> Stephen Hemminger wrote:
> > On Sun, 27 May 2007 20:44:04 +0200
> > Patrick McHardy <kaber@trash.net> wrote:
> > 
> > 
> >>Fix sky2 disabling VLAN completely when the first vid is unregistered.
> >>
> >>For some reason the VLAN code insists on the driver providing a
> >>vlan_rx_kill_vid function even if only NETIF_F_HW_VLAN_RX and not
> >>NETIF_F_HW_VLAN_FILTER is set, so this patch keeps an empty
> >>function. This seems to be a bug though, vlan_rx_add_vid is only
> >>required with NETIF_F_HW_VLAN_FILTER. Ben?
> >>
> > 
> > 
> > Reading other drivers, it looks like a better patch would be to
> > handle mode change in both set and kill.
> 
> 
> The VLAN code tracks registered VIDs and will always call
> vlan_rx_register(NULL) when the last VID is unregistered,
> so this is not necessary.
> 

Then should others be fixed...
	tg3, bnx2, r8169, gianfar, s2io, 8139cp, acenic, ...

-- 
Stephen Hemminger <shemminger@linux-foundation.org>
