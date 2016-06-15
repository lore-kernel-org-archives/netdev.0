From: James Cameron <quozl@laptop.org>
Subject: Re: [ldv-project] [net] libertas: potential race condition
Date: Wed, 15 Jun 2016 10:46:55 +1000
Message-ID: <20160615004655.GE5852@us.netrek.org>
References: <57569424.9040906@ispras.ru>
 <1465310395.29158.2.camel@redhat.com>
 <20160607225114.GA21437@us.netrek.org>
 <5760039B.4050902@ispras.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Dan Williams <dcbw@redhat.com>, Kalle Valo <kvalo@codeaurora.org>,
	libertas-dev@lists.infradead.org, LDV list <ldv-project@ispras.ru>,
	netdev@vger.kernel.org, linux-wireless@vger.kernel.org,
	linux-kernel@vger.kernel.org, vaishali.thakkar@oracle.com
To: Pavel Andrianov <andrianov@ispras.ru>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <5760039B.4050902@ispras.ru>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Jun 14, 2016 at 05:16:11PM +0400, Pavel Andrianov wrote:
> 08.06.2016 02:51, James Cameron =D0=BF=D0=B8=D1=88=D0=B5=D1=82:
> >On Tue, Jun 07, 2016 at 09:39:55AM -0500, Dan Williams wrote:
> >>On Tue, 2016-06-07 at 13:30 +0400, Pavel Andrianov wrote:
> >>>Hi!
> >>>
> >>>There is a potential race condition in
> >>>drivers/net/wireless/libertas/libertas.ko.
> >>>In the function lbs_hard_start_xmit(..), line 159, a socket buffer
> >>>is
> >>>written to priv->current_skb with a spin_lock protection.
> >>>In the function lbs_mac_event_disconnected(..), lines 50-51, the
> >>>field
> >>>current_skb is cleaned. There is no protection used. The
> >>>corresponding
> >>>handlers are activated at the same time in lbs_start_card(..) and
> >>>then
> >>>may be executed simultaneously. Note, there are two structures
> >>>lbs_netdev_ops and mesh_netdev_ops, which have the target handler
> >>>lbs_hard_start_xmit.
> >>>Is it a real race or I have missed something?
> >>Yeah, it looks like it should be grabbing priv->driver_lock before
> >>clearing priv->currenttxskb in lbs_mac_event_disconnected().  Care =
to
> >>submit a patch after testing?  Do you have any of that hardware?
> >I've hardware, with serial console.
> >
> >Can test any patch, on USB (8388) or SDIO (8686).
> >
> Hi!
>=20
> I've prepare the patch for this issue. Could you test it?
>=20
> Thank you.

Tested on OLPC XO-1 (usb8388) and XO-1.5 (sd8686) with v4.7-rc3.

Confirmed that lbs_mac_event_disconnected is being called on the
station when hostapd on access point is given SIGHUP.

Longer duration test was;

- SSH to station and run "top -d 0.2",

- send SIGHUP every six seconds, for 300 cycles,

You may add my;

Tested-by: James Cameron <quozl@laptop.org>

--=20
James Cameron
http://quozl.netrek.org/
