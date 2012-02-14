From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] ixgbe: fix truesize calculation when merging active
 tail into lro skb
Date: Tue, 14 Feb 2012 18:39:32 +0100
Message-ID: <1329241172.4818.4.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
References: <20120213135248.GA23457@sir.fritz.box>
	  <1329142322.2494.11.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
	 <1329169382.2307.14.camel@jtkirshe-mobl> <4F3A9806.2000102@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: jeffrey.t.kirsher@intel.com, Christian Brunner <chb@muc.de>,
	netdev@vger.kernel.org,
	Jesse Brandeburg <jesse.brandeburg@intel.com>
To: Alexander Duyck <alexander.h.duyck@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bk0-f46.google.com ([209.85.214.46]:55076 "EHLO
	mail-bk0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759047Ab2BNRjg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 14 Feb 2012 12:39:36 -0500
Received: by bkcjm19 with SMTP id jm19so217119bkc.19
        for <netdev@vger.kernel.org>; Tue, 14 Feb 2012 09:39:35 -0800 (PST)
In-Reply-To: <4F3A9806.2000102@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mardi 14 f=C3=A9vrier 2012 =C3=A0 09:21 -0800, Alexander Duyck a =C3=
=A9crit :

> The code itself is correct, but the comment isn't.  This code path is
> applied only to the case where we are not using pages.  The default R=
x
> buffer size is actually about 3K when RSC is in use, which means
> truesize is about 4.25K per buffer.
>=20

Hmm... any reason its not 2.25K per buffer ? (assuming MTU=3D1500)

Do you really need this code in ixgbe_set_rx_buffer_len() ?

                /*
                 * Make best use of allocation by using all but 1K of a
                 * power of 2 allocation that will be used for skb->hea=
d.
                 */
                else if (max_frame <=3D IXGBE_RXBUFFER_3K)
                        rx_buf_len =3D IXGBE_RXBUFFER_3K;
                else if (max_frame <=3D IXGBE_RXBUFFER_7K)
                        rx_buf_len =3D IXGBE_RXBUFFER_7K;
                else if (max_frame <=3D IXGBE_RXBUFFER_15K)
                        rx_buf_len =3D IXGBE_RXBUFFER_15K;
                else
                        rx_buf_len =3D IXGBE_MAX_RXBUFFER;

Why not using :
		rx_buf_len =3D max_frame;

and let kmalloc() do its best ?
