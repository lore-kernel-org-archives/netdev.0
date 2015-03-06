From: Scott Feldman <sfeldma@gmail.com>
Subject: Re: [PATCH net-next 1/3] switchdev: fix stp update API to work with
 layered netdevices
Date: Fri, 6 Mar 2015 01:30:43 -0800
Message-ID: <CAE4R7bAHABpfNU9LK7GtKNMZHfdAWwg5u8R7kRH4upKpy2fOsQ@mail.gmail.com>
References: <1425614658-43701-2-git-send-email-roopa@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: =?UTF-8?B?SmnFmcOtIFDDrXJrbw==?= <jiri@resnulli.us>,
	"David S. Miller" <davem@davemloft.net>,
	Netdev <netdev@vger.kernel.org>
To: Roopa Prabhu <roopa@cumulusnetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qc0-f181.google.com ([209.85.216.181]:35098 "EHLO
	mail-qc0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751021AbbCFJao (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 6 Mar 2015 04:30:44 -0500
Received: by qcyl6 with SMTP id l6so49345620qcy.2
        for <netdev@vger.kernel.org>; Fri, 06 Mar 2015 01:30:44 -0800 (PST)
In-Reply-To: <1425614658-43701-2-git-send-email-roopa@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Mar 5, 2015 at 8:04 PM,  <roopa@cumulusnetworks.com> wrote:
> From: Roopa Prabhu <roopa@cumulusnetworks.com>
>
> make it same as the netdev_switch_port_bridge_setlink/dellink
> api (ie traverse lowerdevs to get to the switch port).
>
> removes "WARN_ON(!ops->ndo_switch_parent_id_get)" because bridge ports
> can be bonds and teams which might not implement this ndo.
>
> Signed-off-by: Roopa Prabhu <roopa@cumulusnetworks.com>
> ---
>  include/net/switchdev.h   |    7 +++++++
>  net/switchdev/switchdev.c |   30 +++++++++++++++++++++++++++++-
>  2 files changed, 36 insertions(+), 1 deletion(-)
>
> diff --git a/include/net/switchdev.h b/include/net/switchdev.h
> index cfcdac2..a93279b 100644
> --- a/include/net/switchdev.h
> +++ b/include/net/switchdev.h
> @@ -51,6 +51,7 @@ int ndo_dflt_netdev_switch_port_bridge_dellink(struct net_device *dev,
>                                                struct nlmsghdr *nlh, u16 flags);
>  int ndo_dflt_netdev_switch_port_bridge_setlink(struct net_device *dev,
>                                                struct nlmsghdr *nlh, u16 flags);
> +int ndo_dflt_netdev_switch_port_stp_update(struct net_device *dev, u8 state);
>  #else
>
>  static inline int netdev_switch_parent_id_get(struct net_device *dev,
> @@ -109,6 +110,12 @@ static inline int ndo_dflt_netdev_switch_port_bridge_setlink(struct net_device *
>         return 0;
>  }
>
> +static inline int ndo_dflt_netdev_switch_port_stp_update(struct net_device *dev,
> +                                                        u8 state)
> +{
> +       return 0;

Shouldn't this be return -EOPNOTSUPP to be consistent with
netdev_switch_port_stp_update() when CONFIG_NET_SWITCHDEV is not
defined?

The rest looks good, thanks Roopa.
