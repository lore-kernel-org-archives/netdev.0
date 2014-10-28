From: Lorenzo Colitti <lorenzo@google.com>
Subject: Re: [PATCH net-next] net: ipv6: Add a sysctl to make optimistic
 addresses useful candidates
Date: Tue, 28 Oct 2014 17:19:44 +0900
Message-ID: <CAKD1Yr13oLyBsbuh92F91Fjno3Xv4vBQ1B__8Csoi0XUjJv9nw@mail.gmail.com>
References: <1414482141-27912-1-git-send-email-ek@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>,
	Ben Hutchings <ben@decadent.org.uk>,
	Hannes Frederic Sowa <hannes@stressinduktion.org>
To: Erik Kline <ek@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f182.google.com ([209.85.213.182]:46829 "EHLO
	mail-ig0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756586AbaJ1IUG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 28 Oct 2014 04:20:06 -0400
Received: by mail-ig0-f182.google.com with SMTP id hn18so571942igb.9
        for <netdev@vger.kernel.org>; Tue, 28 Oct 2014 01:20:04 -0700 (PDT)
In-Reply-To: <1414482141-27912-1-git-send-email-ek@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Oct 28, 2014 at 4:42 PM, Erik Kline <ek@google.com> wrote:
>          *      Configure the address for reception. Now it is valid.
>          */
>
> -       ipv6_ifa_notify(RTM_NEWADDR, ifp);
> +       /* If optimistic DAD is in use, the notification was already sent
> +        * in addrconf_dad_begin().
> +        */
> +       if (!ipv6_use_optimistic_addr(ifp->idev))
> +               ipv6_ifa_notify(RTM_NEWADDR, ifp);

Won't this result in not sending RTM_NEWADDR messages if
use_optimistic is enabled on the interface, but the IP address that
has just completed DAD is not an optimistic address (e.g., if it's a
manually-configured address)?
