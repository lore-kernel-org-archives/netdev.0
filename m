From: Yinghai Lu <yinghai@kernel.org>
Subject: Re: ixgbe dump
Date: Mon, 22 Nov 2010 20:15:34 -0800
Message-ID: <AANLkTi=ceFYmLuqYhWxyoQ2A3Wev6Dw7V2U+sc-D8d9_@mail.gmail.com>
References: <4CE47FA6.8050600@kernel.org>
	<29F4ED941D916B48B88B4D2A4F3D1B9C01CBFC68C5@orsmsx509.amr.corp.intel.com>
	<AANLkTinQ-6CaUY3bYd+SMBCaNvU5YiXL2P+gh7N1tM-x@mail.gmail.com>
	<1290468133.2603.2.camel@jtkirshe-MOBL1>
	<AANLkTi=Esp=y2ci=RrCeXYVaxnbrJY3NXpaBgPOBqc7p@mail.gmail.com>
	<29F4ED941D916B48B88B4D2A4F3D1B9C01CC08FBCF@orsmsx509.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>,
	"Brandeburg, Jesse" <jesse.brandeburg@intel.com>,
	David Miller <davem@davemloft.net>,
	NetDev <netdev@vger.kernel.org>
To: "Skidmore, Donald C" <donald.c.skidmore@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qy0-f174.google.com ([209.85.216.174]:64375 "EHLO
	mail-qy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751350Ab0KWEPf convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 22 Nov 2010 23:15:35 -0500
Received: by qyk11 with SMTP id 11so1207120qyk.19
        for <netdev@vger.kernel.org>; Mon, 22 Nov 2010 20:15:34 -0800 (PST)
In-Reply-To: <29F4ED941D916B48B88B4D2A4F3D1B9C01CC08FBCF@orsmsx509.amr.corp.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Nov 22, 2010 at 7:31 PM, Skidmore, Donald C
<donald.c.skidmore@intel.com> wrote:
>
> Hi Yinghai,
>
> I was hoping we could have had this patch pushed upstream sooner, but=
 we have quite a few in our internal queue right now.
>
> If this doesn't solve your issue please let me know.
>
> Thanks,
> -Don Skidmore <donald.c.skidmore@intel.com>
>
>
>
>
> After freeing the rings we were not zeroing out the ring count values=
=2E
> This patch now clears these counts correctly.
>
> Reported-by: Yinghai Lu <yinghai@kernel.org>
> Signed-off-by: Don Skidmore <donald.c.skidmore@intel.com>
> ---
>
> =A0drivers/net/ixgbe/ixgbe_main.c | =A0 =A03 +++
> =A01 files changed, 3 insertions(+), 0 deletions(-)
>
> diff --git a/drivers/net/ixgbe/ixgbe_main.c b/drivers/net/ixgbe/ixgbe=
_main.c
> index fbad4d8..eee0b29 100644
> --- a/drivers/net/ixgbe/ixgbe_main.c
> +++ b/drivers/net/ixgbe/ixgbe_main.c
> @@ -4771,6 +4771,9 @@ void ixgbe_clear_interrupt_scheme(struct ixgbe_=
adapter *adapter)
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0adapter->rx_ring[i] =3D NULL;
> =A0 =A0 =A0 =A0}
>
> + =A0 =A0 =A0 adapter->num_tx_queues =3D 0;
> + =A0 =A0 =A0 adapter->num_rx_queues =3D 0;
> +
> =A0 =A0 =A0 =A0ixgbe_free_q_vectors(adapter);
> =A0 =A0 =A0 =A0ixgbe_reset_interrupt_capability(adapter);
> =A0}

OK, that fix the problem.

Thanks

Yinghai
