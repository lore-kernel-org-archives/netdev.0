From: David Ahern <dsahern@gmail.com>
Subject: Re: [Patch net] ipv6: only call ip6_route_dev_notify() once for
 NETDEV_UNREGISTER
Date: Tue, 20 Jun 2017 23:16:29 -0400
Message-ID: <18b0fdf4-f967-9a04-91d6-597848f073a9@gmail.com>
References: <1497984147-15011-1-git-send-email-xiyou.wangcong@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: jeffy.chen@rock-chips.com
To: Cong Wang <xiyou.wangcong@gmail.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f193.google.com ([209.85.223.193]:35312 "EHLO
        mail-io0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751175AbdFUDQ2 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 20 Jun 2017 23:16:28 -0400
Received: by mail-io0-f193.google.com with SMTP id f79so548327ioi.2
        for <netdev@vger.kernel.org>; Tue, 20 Jun 2017 20:16:28 -0700 (PDT)
In-Reply-To: <1497984147-15011-1-git-send-email-xiyou.wangcong@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 6/20/17 2:42 PM, Cong Wang wrote:
> In commit 242d3a49a2a1 ("ipv6: reorder ip6_route_dev_notifier after ipv6_dev_notf")
> I assumed NETDEV_REGISTER and NETDEV_UNREGISTER are paired,
> unfortunately, as reported by jeffy, netdev_wait_allrefs()
> could rebroadcast NETDEV_UNREGISTER event until all refs are
> gone.
> 
> We have to add an additional check to avoid this corner case.
> For netdev_wait_allrefs() dev->reg_state is NETREG_UNREGISTERED,
> for dev_change_net_namespace(), dev->reg_state is
> NETREG_REGISTERED. So check for dev->reg_state != NETREG_UNREGISTERED.
> 
> Fixes: 242d3a49a2a1 ("ipv6: reorder ip6_route_dev_notifier after ipv6_dev_notf")
> Reported-by: jeffy <jeffy.chen@rock-chips.com>
> Cc: David Ahern <dsahern@gmail.com>
> Signed-off-by: Cong Wang <xiyou.wangcong@gmail.com>
> ---
>  net/ipv6/route.c | 6 +++++-
>  1 file changed, 5 insertions(+), 1 deletion(-)

Acked-by: David Ahern <dsahern@gmail.com>
