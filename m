From: David Miller <davem@davemloft.net>
Subject: Re: [Bug #12805] QinQ vlan trunking regression
Date: Sat, 14 Mar 2009 15:04:20 -0700 (PDT)
Message-ID: <20090314.150420.149174658.davem@davemloft.net>
References: <MiincthRUSI.A.eKC.F4BvJB@chimera>
	<GCLaknAim2M.A.RgD.w4BvJB@chimera>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, kernel-testers@vger.kernel.org,
	bart@jukie.net, netdev@vger.kernel.org
To: rjw@sisk.pl
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:43749
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751238AbZCNWEe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 14 Mar 2009 18:04:34 -0400
In-Reply-To: <GCLaknAim2M.A.RgD.w4BvJB@chimera>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Rafael J. Wysocki" <rjw@sisk.pl>
Date: Sat, 14 Mar 2009 20:05:33 +0100 (CET)

> This message has been generated automatically as a part of a report
> of recent regressions.
> 
> The following bug entry is on the current list of known regressions
> from 2.6.28.  Please verify if it still should be listed and let me know
> (either way).
> 
> 
> Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=12805
> Subject		: QinQ vlan trunking regression
> Submitter	: Bart Trojanowski <bart@jukie.net>
> Date		: 2009-02-28 18:05 (15 days old)
> References	: http://marc.info/?l=linux-kernel&m=123584439115868&w=4

Fixed by:

commit 9d40bbda599def1e1d155d7f7dca14fe8744bd2b
Author: David S. Miller <davem@davemloft.net>
Date:   Wed Mar 4 23:46:25 2009 -0800

    vlan: Fix vlan-in-vlan crashes.
    
    As analyzed by Patrick McHardy, vlan needs to reset it's
    netdev_ops pointer in it's ->init() function but this
    leaves the compat method pointers stale.
    
    Add a netdev_resync_ops() and call it from the vlan code.
    
    Any other driver which changes ->netdev_ops after register_netdevice()
    will need to call this new function after doing so too.
    
    With help from Patrick McHardy.
    
    Tested-by: Patrick McHardy <kaber@trash.net>
    Signed-off-by: David S. Miller <davem@davemloft.net>

