From: Cong Wang <cwang@twopensource.com>
Subject: Re: [PATCH] netpoll: fix the skb check in pkt_is_ns
Date: Fri, 21 Mar 2014 09:47:26 -0700
Message-ID: <CAHA+R7Mwa_De9_vY32LdqxPDQqUnd6vBXMxh1jA2+s1kWNuD6A@mail.gmail.com>
References: <1395406437-19834-1-git-send-email-roy.qing.li@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: netdev <netdev@vger.kernel.org>, Cong Wang <amwang@redhat.com>
To: roy.qing.li@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-la0-f54.google.com ([209.85.215.54]:44155 "EHLO
	mail-la0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751848AbaCUQr2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 21 Mar 2014 12:47:28 -0400
Received: by mail-la0-f54.google.com with SMTP id mc6so1873056lab.13
        for <netdev@vger.kernel.org>; Fri, 21 Mar 2014 09:47:26 -0700 (PDT)
In-Reply-To: <1395406437-19834-1-git-send-email-roy.qing.li@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Mar 21, 2014 at 5:53 AM,  <roy.qing.li@gmail.com> wrote:
> diff --git a/net/core/netpoll.c b/net/core/netpoll.c
> index a664f78..df9e6b1 100644
> --- a/net/core/netpoll.c
> +++ b/net/core/netpoll.c
> @@ -742,7 +742,7 @@ static bool pkt_is_ns(struct sk_buff *skb)
>         struct nd_msg *msg;
>         struct ipv6hdr *hdr;
>
> -       if (skb->protocol != htons(ETH_P_ARP))
> +       if (skb->protocol != htons(ETH_P_IPV6))

But this code was just removed by:

commit 9c62a68d13119a1ca9718381d97b0cb415ff4e9d
Author: Eric W. Biederman <ebiederm@xmission.com>
Date:   Fri Mar 14 20:51:52 2014 -0700

    netpoll: Remove dead packet receive code (CONFIG_NETPOLL_TRAP)


Or your patch is for -net? But CONFIG_NETPOLL_TRAP doesn't
have any in-tree users, so we probably don't care.
