From: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Subject: Re: [PATCH] usbnet: Fix tx_bytes statistic running backward in
 cdc_ncm
Date: Sun, 29 Mar 2015 12:07:20 -0700 (PDT)
Message-ID: <20150329.120720.1482940954016865143.davem@davemloft.net>
References: <1427316093-13595-1-git-send-email-bjorn@mork.no>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	oliver-GvhC2dPhHPQdnm+yROfE0A@public.gmane.org, ben.hutchings-4yDnlxn2s6sWdaTGBSpHTA@public.gmane.org
To: bjorn-yOkvZcmFvRU@public.gmane.org
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1427316093-13595-1-git-send-email-bjorn-yOkvZcmFvRU@public.gmane.org>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

=46rom: Bj=F8rn Mork <bjorn-yOkvZcmFvRU@public.gmane.org>
Date: Wed, 25 Mar 2015 21:41:33 +0100

> From: Ben Hutchings <ben.hutchings-4yDnlxn2s6sWdaTGBSpHTA@public.gmane.org>
>=20
> cdc_ncm disagrees with usbnet about how much framing overhead should
> be counted in the tx_bytes statistics, and tries 'fix' this by
> decrementing tx_bytes on the transmit path.  But statistics must neve=
r
> be decremented except due to roll-over; this will thoroughly confuse
> user-space.  Also, tx_bytes is only incremented by usbnet in the
> completion path.
>=20
> Fix this by requiring drivers that set FLAG_MULTI_FRAME to set a
> tx_bytes delta along with the tx_packets count.
>=20
> Fixes: beeecd42c3b4 ("net: cdc_ncm/cdc_mbim: adding NCM protocol stat=
istics")
> Signed-off-by: Ben Hutchings <ben.hutchings-4yDnlxn2s6sWdaTGBSpHTA@public.gmane.org>
> Signed-off-by: Bj=F8rn Mork <bjorn-yOkvZcmFvRU@public.gmane.org>
> ---
> This should really go to stable-3.19 and 4.0, but since it depends on
> 6588af614e7b ("usbnet: Fix tx_packets stat for FLAG_MULTI_FRAME drive=
rs")
> already in net-next, then I guess it is net-next for this patch as we=
ll.

I cherry picked 6588af614e7b ("usbnet: Fix tx_packets stat for
=46LAG_MULTI_FRAME drivers") and put it into 'net', along with
this fix.
--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
