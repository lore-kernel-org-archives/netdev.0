From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Subject: Re: [patch net-next] openvswitch: introduce rtnl ops stub
Date: Thu, 12 Jun 2014 16:46:05 +0200
Message-ID: <5399BD2D.6050609@6wind.com>
References: <1402582808-10443-1-git-send-email-jiri@resnulli.us>
Reply-To: nicolas.dichtel@6wind.com
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: davem@davemloft.net, pshelar@nicira.com, cwang@twopensource.com,
	ebiederm@xmission.com, david@gibson.dropbear.id.au,
	sfeldma@cumulusnetworks.com, sucheta.chakraborty@qlogic.com,
	stephen@networkplumber.org
To: Jiri Pirko <jiri@resnulli.us>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f180.google.com ([209.85.212.180]:37115 "EHLO
	mail-wi0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752898AbaFLOqO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 12 Jun 2014 10:46:14 -0400
Received: by mail-wi0-f180.google.com with SMTP id hi2so3125600wib.7
        for <netdev@vger.kernel.org>; Thu, 12 Jun 2014 07:46:09 -0700 (PDT)
In-Reply-To: <1402582808-10443-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le 12/06/2014 16:20, Jiri Pirko a =C3=A9crit :
> This stub now allows userspace to see IFLA_INFO_KIND for ovs master a=
nd
> IFLA_INFO_SLAVE_KIND for slave.
>
> Note that I added ops->setup check into newlink and dellink in order =
to
> prevent creating and deleting openvswitch instances using rtnl for no=
w.
>
> Signed-off-by: Jiri Pirko <jiri@resnulli.us>
net-next is closed ;-)

> ---
>   net/core/rtnetlink.c                 |  5 ++++-
>   net/openvswitch/datapath.c           |  9 ++++++++-
>   net/openvswitch/vport-internal_dev.c | 16 ++++++++++++++++
>   net/openvswitch/vport-internal_dev.h |  2 ++
>   4 files changed, 30 insertions(+), 2 deletions(-)
>
> diff --git a/net/core/rtnetlink.c b/net/core/rtnetlink.c
> index 233b5ae..b874139 100644
> --- a/net/core/rtnetlink.c
> +++ b/net/core/rtnetlink.c
> @@ -1767,7 +1767,7 @@ static int rtnl_dellink(struct sk_buff *skb, st=
ruct nlmsghdr *nlh)
>   		return -ENODEV;
>
>   	ops =3D dev->rtnl_link_ops;
> -	if (!ops)
> +	if (!ops || !ops->setup)
>   		return -EOPNOTSUPP;
>
>   	ops->dellink(dev, &list_kill);
> @@ -2028,6 +2028,9 @@ replay:
>   			return -EOPNOTSUPP;
>   		}
>
> +		if (!ops->setup)
> +			return -EOPNOTSUPP;
> +
=46or this one, you could just add a ops->validate in openvswitch which=
 returns
always -EOPNOTSUPP.
