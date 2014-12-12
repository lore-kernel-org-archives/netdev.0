From: Lorenzo Colitti <lorenzo@google.com>
Subject: Re: [PATCH net] net: ipv6: allow explicitly choosing optimistic addresses
Date: Fri, 12 Dec 2014 16:37:46 +0900
Message-ID: <CAKD1Yr3+S81mKbVdQ-P6byx-e2Hfn8GJz+Jr7SLWrRjkfpD2qA@mail.gmail.com>
References: <1418356200-7457-1-git-send-email-ek@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>,
	Hannes Frederic Sowa <hannes@stressinduktion.org>
To: Erik Kline <ek@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f171.google.com ([209.85.223.171]:42025 "EHLO
	mail-ie0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757597AbaLLHiK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 12 Dec 2014 02:38:10 -0500
Received: by mail-ie0-f171.google.com with SMTP id rl12so6354295iec.2
        for <netdev@vger.kernel.org>; Thu, 11 Dec 2014 23:38:09 -0800 (PST)
In-Reply-To: <1418356200-7457-1-git-send-email-ek@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Dec 12, 2014 at 12:50 PM, Erik Kline <ek@google.com> wrote:
>
> @@ -1527,7 +1527,8 @@ int ipv6_chk_addr(struct net *net, const struct in6_addr *addr,
>                 if (!net_eq(dev_net(ifp->idev->dev), net))
>                         continue;
>                 if (ipv6_addr_equal(&ifp->addr, addr) &&
> -                   !(ifp->flags&IFA_F_TENTATIVE) &&
> +                   (!(ifp->flags&IFA_F_TENTATIVE) ||
> +                    ifp->flags&IFA_F_OPTIMISTIC) &&
>                     (dev == NULL || ifp->idev->dev == dev ||
>                      !(ifp->scope&(IFA_LINK|IFA_HOST) || strict))) {
>                         rcu_read_unlock_bh();

I looked at the callers of ipv6_chk_addr (lxr finds 19 files); from
what I saw, this change will make all of them more correct except for
ndisc_solicit. With this change, ndisc_solicit could now send
neighbour solicitations from optimistic addresses, which is not
allowed by the RFC.
