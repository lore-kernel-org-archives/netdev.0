From: David Ahern <dsahern@gmail.com>
Subject: Re: [PATCH net] vrf: fix bug_on triggered by rx when destroying a vrf
Date: Thu, 6 Jul 2017 09:32:24 -0600
Message-ID: <9f9c57d6-78db-7038-1992-7c4841b22ce9@gmail.com>
References: <1499343880-30421-1-git-send-email-nikolay@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: chriscormier@cumulusnetworks.com, davem@davemloft.net
To: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>,
        netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-it0-f65.google.com ([209.85.214.65]:36690 "EHLO
        mail-it0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750970AbdGFPc1 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 6 Jul 2017 11:32:27 -0400
Received: by mail-it0-f65.google.com with SMTP id k3so954385ita.3
        for <netdev@vger.kernel.org>; Thu, 06 Jul 2017 08:32:26 -0700 (PDT)
In-Reply-To: <1499343880-30421-1-git-send-email-nikolay@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 7/6/17 6:24 AM, Nikolay Aleksandrov wrote:
> When destroying a VRF device we cleanup the slaves in its ndo_uninit()
> function, but that causes packets to be switched (skb->dev == vrf being
> destroyed) even though we're pass the point where the VRF should be
> receiving any packets while it is being dismantled. This causes a BUG_ON
> to trigger if we have raw sockets (trace below).
> The reason is that the inetdev of the VRF has been destroyed but we're
> still sending packets up the stack with it, so let's free the slaves in
> the dellink callback as David Ahern suggested.
...

> Fixes: 193125dbd8eb ("net: Introduce VRF device driver")
> Reported-by: Chris Cormier <chriscormier@cumulusnetworks.com>
> Signed-off-by: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
> ---
>  drivers/net/vrf.c | 11 ++++++-----
>  1 file changed, 6 insertions(+), 5 deletions(-)
> 

Thanks for the fix.

Acked-by: David Ahern <dsahern@gmail.com>
