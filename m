From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH][NEIGH]: Fix race between pneigh deletion and ipv6's
 ndisc_recv_ns (v3).
Date: Mon, 24 Mar 2008 14:50:10 -0700 (PDT)
Message-ID: <20080324.145010.02903594.davem@davemloft.net>
References: <47E76525.9010807@openvz.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: yoshfuji@linux-ipv6.org, dlezcano@fr.ibm.com,
	netdev@vger.kernel.org
To: xemul@openvz.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:55787
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751162AbYCXVuL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 24 Mar 2008 17:50:11 -0400
In-Reply-To: <47E76525.9010807@openvz.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Pavel Emelyanov <xemul@openvz.org>
Date: Mon, 24 Mar 2008 11:24:05 +0300

> Proxy neighbors do not have any reference counting, so any caller
> of pneigh_lookup (unless it's a netlink triggered add/del routine)
> should _not_ perform any actions on the found proxy entry. 
> 
> There's one exception from this rule - the ipv6's ndisc_recv_ns() 
> uses found entry to check the flags for NTF_ROUTER.
> 
> This creates a race between the ndisc and pneigh_delete - after 
> the pneigh is returned to the caller, the nd_tbl.lock is dropped 
> and the deleting procedure may proceed.
> 
> One of the fixes would be to add a reference counting, but this
> problem exists for ndisc only. Besides such a patch would be too 
> big for -rc4.
> 
> So I propose to introduce a __pneigh_lookup() which is supposed
> to be called with the lock held and use it in ndisc code to check
> the flags on alive pneigh entry.
> 
> 
> Changes from v2:
> As David noticed, Exported the __pneigh_lookup() to ipv6 module. 
> The checkpatch generates a warning on it, since the EXPORT_SYMBOL 
> does not follow the symbol itself, but in this file all the 
> exports come at the end, so I decided no to break this harmony.
> 
> Changes from v1:
> Fixed comments from YOSHIFUJI - indentation of prototype in header
> and the pndisc_check_router() name - and a compilation fix, pointed
> by Daniel - the is_routed was (falsely) considered as uninitialized
> by gcc.
> 
> Signed-off-by: Pavel Emelyanov <xemul@openvz.org>

Applied, thanks!
