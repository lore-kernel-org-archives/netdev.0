From: David Ahern <dsa@cumulusnetworks.com>
Subject: Re: [PATCH net] net: Flush local routes when device changes vrf
 association
Date: Thu, 10 Dec 2015 09:43:00 -0700
Message-ID: <5669AB94.30706@cumulusnetworks.com>
References: <1449711308-35842-1-git-send-email-dsa@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: ja@ssi.bg
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f51.google.com ([209.85.218.51]:34560 "EHLO
	mail-oi0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753048AbbLJQnD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 10 Dec 2015 11:43:03 -0500
Received: by oigl9 with SMTP id l9so9768224oig.1
        for <netdev@vger.kernel.org>; Thu, 10 Dec 2015 08:43:02 -0800 (PST)
In-Reply-To: <1449711308-35842-1-git-send-email-dsa@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 12/9/15 6:35 PM, David Ahern wrote:
> The VRF driver cycles netdevs when an interface is enslaved or released:
> the down event is used to flush neighbor and route tables and the up
> event (if the interface was already up) effectively moves local and
> connected routes to the proper table.
>
> As of 4f823defdd5b the local route is left hanging around after a link
> down, so when a netdev is moved from one VRF to another (or released
> from a VRF altogether) local routes are left in the wrong table.
>
> Fix by introducing a NETDEV_VRF_CHANGE event that can be used to trigger
> the flush of all routes, including local ones.
>
> Fixes: 4f823defdd5b ("ipv4: fix to not remove local route on link down")
> Cc: Julian Anastasov <ja@ssi.bg>
> Signed-off-by: David Ahern <dsa@cumulusnetworks.com>

At Nik's pushing I see that I can do this without adding a new netdev 
event; the NETDEV_CHANGEUPPER can be used for this as well.

Please disregard this patch.
