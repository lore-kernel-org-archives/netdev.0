From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 3/4] PPPOE: memory leak when socket is release()d
 before PPPIOCGCHAN has been called on it
Date: Fri, 20 Apr 2007 16:58:24 -0700 (PDT)
Message-ID: <20070420.165824.54951504.davem@davemloft.net>
References: <11737949753580-git-send-email-mostrows@earthlink.net>
	<1173794975536-git-send-email-mostrows@earthlink.net>
	<11737949751582-git-send-email-mostrows@earthlink.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: mostrows@watson.ibm.com, netdev@vger.kernel.org, florz@florz.de
To: mostrows@earthlink.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:45927
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752670AbXDTX6V (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 20 Apr 2007 19:58:21 -0400
In-Reply-To: <11737949751582-git-send-email-mostrows@earthlink.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Michal Ostrowski <mostrows@earthlink.net>
Date: Tue, 13 Mar 2007 09:09:34 -0500

> below you find a patch that fixes a memory leak when a PPPoE socket is
> release()d after it has been connect()ed, but before the PPPIOCGCHAN ioctl
> ever has been called on it.
> 
> This is somewhat of a security problem, too, since PPPoE sockets can be
> created by any user, so any user can easily allocate all the machine's
> RAM to non-swappable address space and thus DoS the system.
> 
> Is there any specific reason for PPPoE sockets being available to any
> unprivileged process, BTW? After all, you need a packet socket for the
> discovery stage anyway, so it's unlikely that any unprivileged process
> will ever need to create a PPPoE socket, no? Allocating all session IDs
> for a known AC is a kind of DoS, too, after all - with Juniper ERXes,
> this is really easy, actually, since they don't ever assign session ids
> above 8000 ...
> 
> Signed-off-by: Florian Zumbiehl <florz@florz.de>
> Acked-by: Michal Ostrowski <mostrows@earthlink.net>

Applied to net-2.6.22
