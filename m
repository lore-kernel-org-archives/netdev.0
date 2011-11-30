From: Dmitry Eremin-Solenikov <dbaryshkov@gmail.com>
Subject: Re: [PATCH 04/12] [MAC802154] mac802154: TX data path
Date: Wed, 30 Nov 2011 19:56:16 +0400
Message-ID: <CALT56yNu4qALw5QbwAhVficw8SGun+EpuaAiwP4fbEMJ1O4kNw@mail.gmail.com>
References: <20111130141827.GA3739@avtobot.cybertron>
	<1322663029-3880-1-git-send-email-alex.bluesman.smirnov@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-zigbee-devel@lists.sourceforge.net, netdev@vger.kernel.org,
	davem@davemloft.net
To: Alexander Smirnov <alex.bluesman.smirnov@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qw0-f46.google.com ([209.85.216.46]:44665 "EHLO
	mail-qw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753286Ab1K3P4R convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 30 Nov 2011 10:56:17 -0500
Received: by qadc14 with SMTP id c14so3040521qad.19
        for <netdev@vger.kernel.org>; Wed, 30 Nov 2011 07:56:16 -0800 (PST)
In-Reply-To: <1322663029-3880-1-git-send-email-alex.bluesman.smirnov@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello,

On Wed, Nov 30, 2011 at 6:23 PM, Alexander Smirnov
<alex.bluesman.smirnov@gmail.com> wrote:
> Main TX data path implementation between upper and physical layers.
>
> Signed-off-by: Alexander Smirnov <alex.bluesman.smirnov@gmail.com>
> ---
> =A0net/mac802154/Makefile =A0 =A0 =A0 =A0 | =A0 =A02 +-
> =A0net/mac802154/ieee802154_dev.c | =A0 =A03 +-
> =A0net/mac802154/tx.c =A0 =A0 =A0 =A0 =A0 =A0 | =A0102 ++++++++++++++=
++++++++++++++++++++++++++
> =A03 files changed, 105 insertions(+), 2 deletions(-)
> =A0create mode 100644 net/mac802154/tx.c
>
> diff --git a/net/mac802154/Makefile b/net/mac802154/Makefile
> index e00fe47..490beef 100644
> --- a/net/mac802154/Makefile
> +++ b/net/mac802154/Makefile
> @@ -1,2 +1,2 @@
> =A0obj-$(CONFIG_MAC802154) =A0 =A0 =A0 =A0+=3D mac802154.o
> -mac802154-objs =A0 =A0 =A0 =A0 :=3D ieee802154_dev.o rx.o
> +mac802154-objs =A0 =A0 =A0 =A0 :=3D ieee802154_dev.o rx.o tx.o
> diff --git a/net/mac802154/ieee802154_dev.c b/net/mac802154/ieee80215=
4_dev.c
> index 42f95b2..e90d336 100644
> --- a/net/mac802154/ieee802154_dev.c
> +++ b/net/mac802154/ieee802154_dev.c
> @@ -31,7 +31,8 @@ struct ieee802154_dev *ieee802154_alloc_device(size=
_t priv_size,
> =A0 =A0 =A0 =A0struct wpan_phy *phy;
> =A0 =A0 =A0 =A0struct mac802154_priv *priv;
>
> - =A0 =A0 =A0 if (!ops || !ops->xmit || !ops->ed || !ops->start || !o=
ps->stop) {
> + =A0 =A0 =A0 if (!ops || !ops->xmit || !ops->ed || !ops->start || !o=
ps->stop ||
> + =A0 =A0 =A0 =A0 =A0 !ops->set_channel) {
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0printk(KERN_ERR
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0"Undefined IEEE802.15.=
4 device operations\n");
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0return NULL;

Shan't this be present in one of the previous patches instead? Because
it's illogical to include the check here and not before, if you define
set_channel
operation in previous patch.

--=20
With best wishes
Dmitry
