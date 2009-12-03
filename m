From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: [PATCH v4] net: Introduce realloc_netdev_mq()
Date: Thu, 3 Dec 2009 23:47:42 +0100
Message-ID: <20091203224742.GA16646@ami.dom.local>
References: <4B17EFE3.4080301@gmail.com>
 <20091203202937.GA11436@ami.dom.local>
 <4B182DC6.5030800@gmail.com>
 <20091203.133108.254093305.davem@davemloft.net>
 <4B1832DD.1070805@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, mchan@broadcom.com,
	kaber@trash.net, netdev@vger.kernel.org,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f227.google.com ([209.85.218.227]:63846 "EHLO
	mail-bw0-f227.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753111AbZLCWrp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 Dec 2009 17:47:45 -0500
Received: by bwz27 with SMTP id 27so1564792bwz.21
        for <netdev@vger.kernel.org>; Thu, 03 Dec 2009 14:47:51 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <4B1832DD.1070805@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Dec 03, 2009 at 10:51:25PM +0100, Eric Dumazet wrote:
> David Miller a =E9crit :
> > From: Eric Dumazet <eric.dumazet@gmail.com>
> > Date: Thu, 03 Dec 2009 22:29:42 +0100
> >=20
> >> Nice patch, thanks :)
> >>
> >> Acked-by: Eric Dumazet <eric.dumazet@gmail.com>
> >=20
> > I like it too, but please resubmit once we have at least
> > one example user submitted.
> >=20
>=20
> I successfully tested following patch.

Great! But, I see, checking if realloc_netdev_mq() use is always legal
(before register_netdev()) is not trivial in this driver. (I have some
suspicions around ixgbe_resume().) I wonder, if there should be added
some debugging for this.

Thanks,
Jarek P.

>=20
> Thanks !
>=20
> [PATCH] ixgbe: Use realloc_netdev_mq() helper
>=20
> Instead of 128 tx queues, we can cap the tx queue number to what driv=
er really uses.
>=20
> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
> ---
>=20
> diff --git a/drivers/net/ixgbe/ixgbe_main.c b/drivers/net/ixgbe/ixgbe=
_main.c
> index 9ba506f..e524d0d 100644
> --- a/drivers/net/ixgbe/ixgbe_main.c
> +++ b/drivers/net/ixgbe/ixgbe_main.c
> @@ -3306,7 +3306,7 @@ static void ixgbe_set_num_queues(struct ixgbe_a=
dapter *adapter)
> =20
>  done:
>  	/* Notify the stack of the (possibly) reduced Tx Queue count. */
> -	adapter->netdev->real_num_tx_queues =3D adapter->num_tx_queues;
> +	realloc_netdev_mq(adapter->netdev, adapter->num_tx_queues);
>  }
> =20
>  static void ixgbe_acquire_msix_vectors(struct ixgbe_adapter *adapter=
,
>=20
