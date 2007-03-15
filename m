From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: [PATCH] skge: set mac address bonding fix
Date: Thu, 15 Mar 2007 10:35:19 -0400
Message-ID: <45F959A7.1090604@pobox.com>
References: <Pine.LNX.4.64.0703081101390.21717@potato.cts.ucla.edu> <20070308113427.6344a7f6@freekitty> <Pine.LNX.4.64.0703081256440.25051@potato.cts.ucla.edu> <20070308134811.38a8ec81@freekitty> <Pine.LNX.4.64.0703081350510.25051@potato.cts.ucla.edu> <23552.1173395045@death> <Pine.LNX.4.64.0703081509110.28233@potato.cts.ucla.edu> <Pine.LNX.4.64.0703121504590.25767@potato.cts.ucla.edu> <20070312151626.60d00e30@dxpl.pdx.osdl.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Chris Stromsoe <cbs@cts.ucla.edu>, Jay Vosburgh <fubar@us.ibm.com>,
	netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:49940 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1422729AbXCOOfa (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 15 Mar 2007 10:35:30 -0400
In-Reply-To: <20070312151626.60d00e30@dxpl.pdx.osdl.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Stephen Hemminger wrote:
> When bonding does fail over it calls set_mac_address.  When this happens
> as the result of another port going down, the phy_mutex that is common to
> both ports is held, so it deadlocks. Setting the address doesn't need to do
> anything that needs the phy_mutex, it already has the RTNL to protect against
> other admin actions.
> 
> This change just disables the receiver to avoid any hardware confusion
> while address is changing.
> 
> Signed-off-by: Stephen Hemminger <shemminger@linux-foundation.org>

applied, because:

Rather than guessing about whether hardware confusion would occur, it is 
best to disable the receiver (for any hardware) unless we are CERTAIN 
that the hardware RX filter can be updated without stopping RX.

Motivated people should check this on other hardware too.

	Jeff




