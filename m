From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: Re: [PATCH] vxlan: Accept user specified MTU value when create new
 vxlan link
Date: Fri, 27 May 2016 09:09:01 -0700
Message-ID: <CAM_iQpULCyju9vor74ygcv5FcqFeoq9KthRuCYfo4=tF0ieHrg@mail.gmail.com>
References: <1464317351-22316-1-git-send-email-oc@yunify.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Linux Kernel Network Developers <netdev@vger.kernel.org>
To: Chen Haiquan <oc@yunify.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yw0-f193.google.com ([209.85.161.193]:33323 "EHLO
	mail-yw0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751307AbcE0QJV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 27 May 2016 12:09:21 -0400
Received: by mail-yw0-f193.google.com with SMTP id y6so6856163ywe.0
        for <netdev@vger.kernel.org>; Fri, 27 May 2016 09:09:21 -0700 (PDT)
In-Reply-To: <1464317351-22316-1-git-send-email-oc@yunify.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, May 26, 2016 at 7:49 PM, Chen Haiquan <oc@yunify.com> wrote:
> When create a new vxlan link, example:
>   ip link add vtap mtu 1440 type vxlan vni 1 dev eth0
>
> The argument "mtu" has no effect, because it is not set to conf->mtu. The
> default value is used in vxlan_dev_configure function.
>
> This problem was introduced by commit 0dfbdf4102b9 (vxlan: Factor out device
> configuration).
>
> Fixes: 0dfbdf4102b9 (vxlan: Factor out device configuration)
>
> Signed-off-by:  Chen Haiquan <oc@yunify.com>
> ---
>  drivers/net/vxlan.c | 3 +++
>  1 file changed, 3 insertions(+)
>
> diff --git a/drivers/net/vxlan.c b/drivers/net/vxlan.c
> index 8ff30c3..f999db2 100644
> --- a/drivers/net/vxlan.c
> +++ b/drivers/net/vxlan.c
> @@ -3086,6 +3086,9 @@ static int vxlan_newlink(struct net *src_net, struct net_device *dev,
>         if (data[IFLA_VXLAN_REMCSUM_NOPARTIAL])
>                 conf.flags |= VXLAN_F_REMCSUM_NOPARTIAL;
>
> +       if (tb[IFLA_MTU])
> +               conf.mtu = nla_get_u32(tb[IFLA_MTU]);
> +

IFLA_MTU is already parsed in rtnl_create_link(),
so just use dev->mtu here? conf.mtu = dev->mtu?
