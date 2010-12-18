From: Alexander Duyck <alexander.duyck@gmail.com>
Subject: Re: [RFC PATCH 3/3] igb: example of how to update igb to make use of
 in-kernel Toeplitz hashing
Date: Fri, 17 Dec 2010 22:53:24 -0800
Message-ID: <AANLkTimuXo+ZJKmz4U38mLd8x-KymJ0BQxTTjDT2bjgy@mail.gmail.com>
References: <20101218004210.28602.18499.stgit@gitlad.jf.intel.com>
	<20101218010048.28602.49776.stgit@gitlad.jf.intel.com>
	<20101217.210923.193721885.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: alexander.h.duyck@intel.com, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:60416 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751790Ab0LRGx0 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 18 Dec 2010 01:53:26 -0500
Received: by wwa36 with SMTP id 36so1383476wwa.1
        for <netdev@vger.kernel.org>; Fri, 17 Dec 2010 22:53:25 -0800 (PST)
In-Reply-To: <20101217.210923.193721885.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Dec 17, 2010 at 9:09 PM, David Miller <davem@davemloft.net> wro=
te:
> From: Alexander Duyck <alexander.h.duyck@intel.com>
> Date: Fri, 17 Dec 2010 17:00:48 -0800
>
>> @@ -1691,6 +1692,7 @@ static const struct net_device_ops igb_netdev_=
ops =3D {
>> =A0 =A0 =A0 .ndo_open =A0 =A0 =A0 =A0 =A0 =A0 =A0 =3D igb_open,
>> =A0 =A0 =A0 .ndo_stop =A0 =A0 =A0 =A0 =A0 =A0 =A0 =3D igb_close,
>> =A0 =A0 =A0 .ndo_start_xmit =A0 =A0 =A0 =A0 =3D igb_xmit_frame_adv,
>> + =A0 =A0 .ndo_select_queue =A0 =A0 =A0 =3D toeplitz_select_queue,
>> =A0 =A0 =A0 .ndo_get_stats64 =A0 =A0 =A0 =A0=3D igb_get_stats64,
>> =A0 =A0 =A0 .ndo_set_rx_mode =A0 =A0 =A0 =A0=3D igb_set_rx_mode,
>> =A0 =A0 =A0 .ndo_set_multicast_list =3D igb_set_rx_mode,
>
> Adding a NETIF_F_TX_TOEPLITZ flag that skb_tx_hash() keys off of woul=
d
> be a lot simpler

Thats probably true.  I hadn't put much thought into it at the time.

> We want less overriding of ->ndo_select_queue(), not more, and this c=
ase
> is definitely gratuitous.

I kind of figured that was the approach was flawed.  As I said in the
cover page, this is a somewhat hastily thrown together set of patches
to demonstrate a proof of concept.  To me this appeared to be the
quickest way to come up with the means to alter the queue selection.
The main piece I am interested in is any input on the first patch that
added the Toeplitz hash functionality.  Specifically would a 16 bit
key/hash work for queue selection or would there be cases where we
need a 32 bit key/hash result?

Thanks,

Alex
