From: Dan Williams <dcbw@redhat.com>
Subject: Re: [ldv-project] [net] libertas: potential race condition
Date: Tue, 07 Jun 2016 09:39:55 -0500
Message-ID: <1465310395.29158.2.camel@redhat.com>
References: <57569424.9040906@ispras.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: libertas-dev@lists.infradead.org, LDV list <ldv-project@ispras.ru>,
	netdev@vger.kernel.org, linux-wireless@vger.kernel.org,
	linux-kernel@vger.kernel.org, vaishali.thakkar@oracle.com
To: Pavel Andrianov <andrianov@ispras.ru>,
	Kalle Valo <kvalo@codeaurora.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <57569424.9040906@ispras.ru>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 2016-06-07 at 13:30 +0400, Pavel Andrianov wrote:
> Hi!
>=20
> There is a potential race condition in=C2=A0
> drivers/net/wireless/libertas/libertas.ko.
> In the function lbs_hard_start_xmit(..), line 159, a socket buffer
> is=C2=A0
> written to priv->current_skb with a spin_lock protection.
> In the function lbs_mac_event_disconnected(..), lines 50-51, the
> field=C2=A0
> current_skb is cleaned. There is no protection used. The
> corresponding=C2=A0
> handlers are activated at the same time in lbs_start_card(..) and
> then=C2=A0
> may be executed simultaneously. Note, there are two structures=C2=A0
> lbs_netdev_ops and mesh_netdev_ops, which have the target handler=C2=A0
> lbs_hard_start_xmit.
> Is it a real race or I have missed something?

Yeah, it looks like it should be grabbing priv->driver_lock before
clearing priv->currenttxskb in=C2=A0lbs_mac_event_disconnected(). =C2=A0=
Care to
submit a patch after testing? =C2=A0Do you have any of that hardware?

Dan
