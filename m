From: James Cameron <quozl@laptop.org>
Subject: Re: [ldv-project] [net] libertas: potential race condition
Date: Wed, 8 Jun 2016 08:51:14 +1000
Message-ID: <20160607225114.GA21437@us.netrek.org>
References: <57569424.9040906@ispras.ru>
 <1465310395.29158.2.camel@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Pavel Andrianov <andrianov@ispras.ru>,
	Kalle Valo <kvalo@codeaurora.org>,
	libertas-dev@lists.infradead.org, LDV list <ldv-project@ispras.ru>,
	netdev@vger.kernel.org, linux-wireless@vger.kernel.org,
	linux-kernel@vger.kernel.org, vaishali.thakkar@oracle.com
To: Dan Williams <dcbw@redhat.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1465310395.29158.2.camel@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Jun 07, 2016 at 09:39:55AM -0500, Dan Williams wrote:
> On Tue, 2016-06-07 at 13:30 +0400, Pavel Andrianov wrote:
> > Hi!
> >=20
> > There is a potential race condition in=A0
> > drivers/net/wireless/libertas/libertas.ko.
> > In the function lbs_hard_start_xmit(..), line 159, a socket buffer
> > is=A0
> > written to priv->current_skb with a spin_lock protection.
> > In the function lbs_mac_event_disconnected(..), lines 50-51, the
> > field=A0
> > current_skb is cleaned. There is no protection used. The
> > corresponding=A0
> > handlers are activated at the same time in lbs_start_card(..) and
> > then=A0
> > may be executed simultaneously. Note, there are two structures=A0
> > lbs_netdev_ops and mesh_netdev_ops, which have the target handler=A0
> > lbs_hard_start_xmit.
> > Is it a real race or I have missed something?
>=20
> Yeah, it looks like it should be grabbing priv->driver_lock before
> clearing priv->currenttxskb in=A0lbs_mac_event_disconnected(). =A0Car=
e to
> submit a patch after testing? =A0Do you have any of that hardware?

I've hardware, with serial console.

Can test any patch, on USB (8388) or SDIO (8686).

--=20
James Cameron
http://quozl.netrek.org/
