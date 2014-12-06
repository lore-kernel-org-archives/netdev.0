From: Scott Feldman <sfeldma@gmail.com>
Subject: Re: [PATCH net-next v2 2/2] rocker: remove swdev mode
Date: Fri, 5 Dec 2014 21:44:47 -0800
Message-ID: <CAE4R7bC11ne2eoFUjMhFtJWU+asw8-sUd5e_ZdZ-T=oti_CRdg@mail.gmail.com>
References: <1417828604-42722-3-git-send-email-roopa@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: =?UTF-8?B?SmnFmcOtIFDDrXJrbw==?= <jiri@resnulli.us>,
	Jamal Hadi Salim <jhs@mojatatu.com>,
	Benjamin LaHaise <bcrl@kvack.org>, Thomas Graf <tgraf@suug.ch>,
	john fastabend <john.fastabend@gmail.com>,
	"stephen@networkplumber.org" <stephen@networkplumber.org>,
	John Linville <linville@tuxdriver.com>,
	"vyasevic@redhat.com" <vyasevic@redhat.com>,
	Netdev <netdev@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>, shm@cumulusnetworks.com,
	Andy Gospodarek <gospo@cumulusnetworks.com>
To: Roopa Prabhu <roopa@cumulusnetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wg0-f49.google.com ([74.125.82.49]:47924 "EHLO
	mail-wg0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750746AbaLFFos (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 6 Dec 2014 00:44:48 -0500
Received: by mail-wg0-f49.google.com with SMTP id n12so2448871wgh.8
        for <netdev@vger.kernel.org>; Fri, 05 Dec 2014 21:44:47 -0800 (PST)
In-Reply-To: <1417828604-42722-3-git-send-email-roopa@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Dec 5, 2014 at 5:16 PM,  <roopa@cumulusnetworks.com> wrote:
> From: Roopa Prabhu <roopa@cumulusnetworks.com>
>
> This resets rocker mode to zero (vepa) during gets.
> This is because the default getlink handler that rocker
> uses today always takes a mode.
>
> Will fix that in a subsequent patch.

One patch set with that fix would be better, otherwise your patch here
will show rocker port running in VEB mode, which is wrong.  Maybe
return mode=-1 for unspecified, or something like that?

>
> Signed-off-by: Roopa Prabhu <roopa@cumulusnetworks.com>
> ---
>  drivers/net/ethernet/rocker/rocker.c |   18 +-----------------
>  1 file changed, 1 insertion(+), 17 deletions(-)
>
> diff --git a/drivers/net/ethernet/rocker/rocker.c b/drivers/net/ethernet/rocker/rocker.c
> index fded127..391077c 100644
> --- a/drivers/net/ethernet/rocker/rocker.c
> +++ b/drivers/net/ethernet/rocker/rocker.c
> @@ -3700,27 +3700,11 @@ static int rocker_port_bridge_setlink(struct net_device *dev,
>  {
>         struct rocker_port *rocker_port = netdev_priv(dev);
>         struct nlattr *protinfo;
> -       struct nlattr *afspec;
>         struct nlattr *attr;
> -       u16 mode;
>         int err;
>
>         protinfo = nlmsg_find_attr(nlh, sizeof(struct ifinfomsg),
>                                    IFLA_PROTINFO);
> -       afspec = nlmsg_find_attr(nlh, sizeof(struct ifinfomsg), IFLA_AF_SPEC);
> -
> -       if (afspec) {
> -               attr = nla_find_nested(afspec, IFLA_BRIDGE_MODE);
> -               if (attr) {
> -                       if (nla_len(attr) < sizeof(mode))
> -                               return -EINVAL;
> -
> -                       mode = nla_get_u16(attr);
> -                       if (mode != BRIDGE_MODE_SWDEV)
> -                               return -EINVAL;
> -               }
> -       }
> -
>         if (protinfo) {
>                 attr = nla_find_nested(protinfo, IFLA_BRPORT_LEARNING);
>                 if (attr) {
> @@ -3755,7 +3739,7 @@ static int rocker_port_bridge_getlink(struct sk_buff *skb, u32 pid, u32 seq,
>                                       u32 filter_mask)
>  {
>         struct rocker_port *rocker_port = netdev_priv(dev);
> -       u16 mode = BRIDGE_MODE_SWDEV;
> +       u16 mode = 0;
>         u32 mask = BR_LEARNING | BR_LEARNING_SYNC;
>
>         return ndo_dflt_bridge_getlink(skb, pid, seq, dev, mode,
> --
> 1.7.10.4
>
