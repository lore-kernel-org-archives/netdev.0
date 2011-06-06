From: =?UTF-8?Q?Am=C3=A9rico_Wang?= <xiyou.wangcong@gmail.com>
Subject: Re: [PATCH net-next] bonding: make 802.3ad use update lacp_rate (v2)
Date: Tue, 7 Jun 2011 00:24:04 +0800
Message-ID: <BANLkTi=9HbFEM0WxTX+gbiB8J37mW+PCUA@mail.gmail.com>
References: <19046.1307130148@death>
	<1307243793-31007-1-git-send-email-panweiping3@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Jay Vosburgh <fubar@us.ibm.com>,
	Andy Gospodarek <andy@greyhouse.net>,
	"open list:BONDING DRIVER" <netdev@vger.kernel.org>,
	open list <linux-kernel@vger.kernel.org>
To: Weiping Pan <panweiping3@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-iw0-f174.google.com ([209.85.214.174]:62210 "EHLO
	mail-iw0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754236Ab1FFQYF convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 6 Jun 2011 12:24:05 -0400
In-Reply-To: <1307243793-31007-1-git-send-email-panweiping3@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Jun 5, 2011 at 11:16 AM, Weiping Pan <panweiping3@gmail.com> wr=
ote:
> There is a bug that when you modify lacp_rate via sysfs,
> 802.3ad won't use the new value of lacp_rate to transmit packets.
> That is because port->actor_oper_port_state isn't changed.
>
> Change Notes:
> v2)
> 1 Hold read_lock(&bond->lock) when iterate slaves, suggested by Jiri =
Pirko.
> 2 Modify actor_oper_port_state via a helper function in bond_3ad.c,
> suggested by Jay Vosburgh.
> 3 Hold slave->state_machine_lock,
> so we can modify port->actor_oper_port_state, no matter bond is up or=
 down.
>
> Signed-off-by: Weiping Pan <panweiping3@gmail.com>
> ---
> =C2=A0drivers/net/bonding/bond_3ad.c =C2=A0 | =C2=A0 27 +++++++++++++=
++++++++++++++
> =C2=A0drivers/net/bonding/bond_3ad.h =C2=A0 | =C2=A0 =C2=A01 +
> =C2=A0drivers/net/bonding/bond_sysfs.c | =C2=A0 =C2=A01 +
> =C2=A03 files changed, 29 insertions(+), 0 deletions(-)
>
> diff --git a/drivers/net/bonding/bond_3ad.c b/drivers/net/bonding/bon=
d_3ad.c
> index c7537abc..5111e0d 100644
> --- a/drivers/net/bonding/bond_3ad.c
> +++ b/drivers/net/bonding/bond_3ad.c
> @@ -2473,3 +2473,30 @@ void bond_3ad_lacpdu_recv(struct sk_buff *skb,=
 struct bonding *bond,
> =C2=A0 =C2=A0 =C2=A0 =C2=A0bond_3ad_rx_indication((struct lacpdu *) s=
kb->data, slave, skb->len);
> =C2=A0 =C2=A0 =C2=A0 =C2=A0read_unlock(&bond->lock);
> =C2=A0}
> +
> +/*
> + * When modify lacp_rate parameter via sysfs,
> + * update actor_oper_port_state of each port.
> + *
> + * Hold slave->state_machine_lock,
> + * so we can modify port->actor_oper_port_state,
> + * no matter bond is up or down.
> + */
> +void bond_3ad_update_lacp_rate(struct bonding *bond)
> +{
> + =C2=A0 =C2=A0 =C2=A0 int i;
> + =C2=A0 =C2=A0 =C2=A0 struct slave *slave;
> + =C2=A0 =C2=A0 =C2=A0 struct port *port =3D NULL;
> +
> + =C2=A0 =C2=A0 =C2=A0 read_lock(&bond->lock);
> + =C2=A0 =C2=A0 =C2=A0 bond_for_each_slave(bond, slave, i) {
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 port =3D &(slave->=
ad_info.port);

Please use SLAVE_AD_INFO().

Other than this, it looks good to me,

Reviewed-by: WANG Cong <xiyou.wangcong@gmail.com>

Thanks!
