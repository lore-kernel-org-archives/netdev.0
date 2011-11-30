From: Dmitry Eremin-Solenikov <dbaryshkov@gmail.com>
Subject: Re: [PATCH 07/12] [IEEE802154] ieee802154: define simplified mlme interface
Date: Wed, 30 Nov 2011 20:22:02 +0400
Message-ID: <CALT56yNd3d-KnDXC+yS1vPohmUG6YgB+wb-Vg_=zg0gVrs6nWw@mail.gmail.com>
References: <20111130141827.GA3739@avtobot.cybertron>
	<1322663126-3987-1-git-send-email-alex.bluesman.smirnov@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-zigbee-devel@lists.sourceforge.net, netdev@vger.kernel.org,
	davem@davemloft.net
To: Alexander Smirnov <alex.bluesman.smirnov@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gx0-f174.google.com ([209.85.161.174]:44436 "EHLO
	mail-gx0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757490Ab1K3QWD convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 30 Nov 2011 11:22:03 -0500
Received: by ggnr5 with SMTP id r5so775217ggn.19
        for <netdev@vger.kernel.org>; Wed, 30 Nov 2011 08:22:02 -0800 (PST)
In-Reply-To: <1322663126-3987-1-git-send-email-alex.bluesman.smirnov@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Nov 30, 2011 at 6:25 PM, Alexander Smirnov
<alex.bluesman.smirnov@gmail.com> wrote:
> Define light-weight mlme interface.

Could you please elaborate, why it is necessary? I created it for the
sub-devices
which didn't have full IEEE 802.15.4 MLME (like monitoring devices,
SMAC or MiWi,
or other proprietary protocols), but I don't see support for those
coming in this patch set.

>
> Signed-off-by: Alexander Smirnov <alex.bluesman.smirnov@gmail.com>
> ---
> =A0include/net/ieee802154_netdev.h | =A0 11 +++++++++++
> =A0net/ieee802154/nl-mac.c =A0 =A0 =A0 =A0 | =A0 =A02 +-
> =A02 files changed, 12 insertions(+), 1 deletions(-)
>
> diff --git a/include/net/ieee802154_netdev.h b/include/net/ieee802154=
_netdev.h
> index 12a7ee4..5264b00 100644
> --- a/include/net/ieee802154_netdev.h
> +++ b/include/net/ieee802154_netdev.h
> @@ -83,7 +83,12 @@ struct wpan_phy;
> =A0* get_phy should increment the reference counting on returned phy.
> =A0* Use wpan_wpy_put to put that reference.
> =A0*/
> +struct simple_mlme_ops {
> + =A0 =A0 =A0 struct wpan_phy *(*get_phy)(const struct net_device *de=
v);
> +};
> =A0struct ieee802154_mlme_ops {
> + =A0 =A0 =A0 struct simple_mlme_ops wpan_ops;
> +
> =A0 =A0 =A0 =A0int (*assoc_req)(struct net_device *dev,
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0struct ieee802154_addr=
 *addr,
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0u8 channel, u8 page, u=
8 cap);
> @@ -112,6 +117,12 @@ struct ieee802154_mlme_ops {
> =A0 =A0 =A0 =A0u8 (*get_bsn)(const struct net_device *dev);
> =A0};
>
> +static inline struct simple_mlme_ops *simple_mlme_ops(
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 const struct net_device *dev)
> +{
> + =A0 =A0 =A0 return dev->ml_priv;
> +}
> +
> =A0static inline struct ieee802154_mlme_ops *ieee802154_mlme_ops(
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0const struct net_device *dev)
> =A0{
> diff --git a/net/ieee802154/nl-mac.c b/net/ieee802154/nl-mac.c
> index adaf462..1d23aa6 100644
> --- a/net/ieee802154/nl-mac.c
> +++ b/net/ieee802154/nl-mac.c
> @@ -263,7 +263,7 @@ static int ieee802154_nl_fill_iface(struct sk_buf=
f *msg, u32 pid,
> =A0 =A0 =A0 =A0if (!hdr)
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0goto out;
>
> - =A0 =A0 =A0 phy =3D ieee802154_mlme_ops(dev)->get_phy(dev);
> + =A0 =A0 =A0 phy =3D simple_mlme_ops(dev)->get_phy(dev);
> =A0 =A0 =A0 =A0BUG_ON(!phy);
>
> =A0 =A0 =A0 =A0NLA_PUT_STRING(msg, IEEE802154_ATTR_DEV_NAME, dev->nam=
e);
> --
> 1.7.2.3
>
>



--=20
With best wishes
Dmitry
