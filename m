From: Scott Feldman <sfeldma@gmail.com>
Subject: Re: [patch net-next v4 20/21] rocker: Add proper validation of
 Netlink attributes
Date: Thu, 27 Nov 2014 11:04:01 -1000
Message-ID: <CAE4R7bDnQtgxyyP-Pfy3UVb-dJ0k+yYmpfuMKF6jEUNk=PC4NQ@mail.gmail.com>
References: <1417084826-9875-1-git-send-email-jiri@resnulli.us>
	<1417084826-9875-21-git-send-email-jiri@resnulli.us>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Netdev <netdev@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>,
	"nhorman@tuxdriver.com" <nhorman@tuxdriver.com>,
	Andy Gospodarek <andy@greyhouse.net>,
	Thomas Graf <tgraf@suug.ch>,
	"dborkman@redhat.com" <dborkman@redhat.com>,
	"ogerlitz@mellanox.com" <ogerlitz@mellanox.com>,
	"jesse@nicira.com" <jesse@nicira.com>,
	"pshelar@nicira.com" <pshelar@nicira.com>,
	"azhou@nicira.com" <azhou@nicira.com>,
	"ben@decadent.org.uk" <ben@decadent.org.uk>,
	"stephen@networkplumber.org" <stephen@networkplumber.org>,
	"Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>,
	"vyasevic@redhat.com" <vyasevic@redhat.com>,
	Cong Wang <xiyou.wangcong@gmail.com>,
	"Fastabend, John R" <john.r.fastabend@intel.com>,
	Eric Dumazet <edumazet@google.com>,
	Jamal Hadi Salim <jhs@mojatatu.com>,
	Florian Fainelli <f.fainelli@gmail.com>,
	Roopa Prabhu <roopa@cumulusnetworks.com>,
	John Linville <linville@tu
To: Jiri Pirko <jiri@resnulli.us>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f182.google.com ([209.85.212.182]:57862 "EHLO
	mail-wi0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751111AbaK0VED (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 27 Nov 2014 16:04:03 -0500
Received: by mail-wi0-f182.google.com with SMTP id h11so9442536wiw.3
        for <netdev@vger.kernel.org>; Thu, 27 Nov 2014 13:04:01 -0800 (PST)
In-Reply-To: <1417084826-9875-21-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Scott Feldman <sfeldma@gmail.com>

On Thu, Nov 27, 2014 at 12:40 AM, Jiri Pirko <jiri@resnulli.us> wrote:
> From: Thomas Graf <tgraf@suug.ch>
>
> Signed-off-by: Thomas Graf <tgraf@suug.ch>
> Signed-off-by: Jiri Pirko <jiri@resnulli.us>
> ---
> new in v4
> ---
>  drivers/net/ethernet/rocker/rocker.c | 9 +++++++++
>  1 file changed, 9 insertions(+)
>
> diff --git a/drivers/net/ethernet/rocker/rocker.c b/drivers/net/ethernet/rocker/rocker.c
> index 61cfdbf..30687bf 100644
> --- a/drivers/net/ethernet/rocker/rocker.c
> +++ b/drivers/net/ethernet/rocker/rocker.c
> @@ -3712,6 +3712,9 @@ static int rocker_port_bridge_setlink(struct net_device *dev,
>         if (afspec) {
>                 attr = nla_find_nested(afspec, IFLA_BRIDGE_MODE);
>                 if (attr) {
> +                       if (nla_len(attr) < sizeof(mode))
> +                               return -EINVAL;
> +
>                         mode = nla_get_u16(attr);
>                         if (mode != BRIDGE_MODE_SWDEV)
>                                 return -EINVAL;
> @@ -3721,6 +3724,9 @@ static int rocker_port_bridge_setlink(struct net_device *dev,
>         if (protinfo) {
>                 attr = nla_find_nested(protinfo, IFLA_BRPORT_LEARNING);
>                 if (attr) {
> +                       if (nla_len(attr) < sizeof(u8))
> +                               return -EINVAL;
> +
>                         if (nla_get_u8(attr))
>                                 rocker_port->brport_flags |= BR_LEARNING;
>                         else
> @@ -3731,6 +3737,9 @@ static int rocker_port_bridge_setlink(struct net_device *dev,
>                 }
>                 attr = nla_find_nested(protinfo, IFLA_BRPORT_LEARNING_SYNC);
>                 if (attr) {
> +                       if (nla_len(attr) < sizeof(u8))
> +                               return -EINVAL;
> +
>                         if (nla_get_u8(attr))
>                                 rocker_port->brport_flags |= BR_LEARNING_SYNC;
>                         else
> --
> 1.9.3
>
