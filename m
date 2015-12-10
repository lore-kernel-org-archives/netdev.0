From: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
Subject: Re: [PATCH net v2] net: Flush local routes when device changes vrf
 association
Date: Thu, 10 Dec 2015 19:30:18 +0100
Message-ID: <5669C4BA.6020500@cumulusnetworks.com>
References: <1449771924-21775-1-git-send-email-dsa@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: ja@ssi.bg
To: David Ahern <dsa@cumulusnetworks.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f47.google.com ([74.125.82.47]:38183 "EHLO
	mail-wm0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750783AbbLJSar (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 10 Dec 2015 13:30:47 -0500
Received: by wmec201 with SMTP id c201so36938135wme.1
        for <netdev@vger.kernel.org>; Thu, 10 Dec 2015 10:30:45 -0800 (PST)
In-Reply-To: <1449771924-21775-1-git-send-email-dsa@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 12/10/2015 07:25 PM, David Ahern wrote:
> The VRF driver cycles netdevs when an interface is enslaved or released:
> the down event is used to flush neighbor and route tables and the up
> event (if the interface was already up) effectively moves local and
> connected routes to the proper table.
> 
> As of 4f823defdd5b the local route is left hanging around after a link
> down, so when a netdev is moved from one VRF to another (or released
> from a VRF altogether) local routes are left in the wrong table.
> 
> Fix by handling the NETDEV_CHANGEUPPER event. When the upper dev is
> an L3mdev then call fib_disable_ip to flush all routes, local ones
> to.
> 
> Fixes: 4f823defdd5b ("ipv4: fix to not remove local route on link down")
> Cc: Julian Anastasov <ja@ssi.bg>
> Signed-off-by: David Ahern <dsa@cumulusnetworks.com>
> ---
> v2
> - key off NETDEV_CHANGEUPPER event vs using a new event
> 
>  net/ipv4/fib_frontend.c | 9 +++++++++
>  1 file changed, 9 insertions(+)
> 

Looks much better to me, thanks!

Signed-off-by: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
