From: =?ISO-8859-2?Q?Micha=B3_Miros=B3aw?= <mirqus@gmail.com>
Subject: Re: [PATCH 1/3] e1000: increase skb size to prevent dma over skb
	boundary
Date: Mon, 7 Dec 2009 16:19:43 +0100
Message-ID: <e2d7436a0912070719n5b979cfbsad4f9a9bc7058edb@mail.gmail.com>
References: <20091207144623.GA8073@hmsreliant.think-freely.org>
	 <20091207144736.GB8073@hmsreliant.think-freely.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-2
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, e1000-devel@lists.sourceforge.net,
	davem@davemloft.net, jeffrey.t.kirsher@intel.com,
	jesse.brandeburg@intel.com, bruce.w.allan@intel.com,
	peter.p.waskiewicz.jr@intel.com, john.ronciak@intel.com
To: Neil Horman <nhorman@tuxdriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ey-out-2122.google.com ([74.125.78.25]:13410 "EHLO
	ey-out-2122.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S935254AbZLGPTi convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 7 Dec 2009 10:19:38 -0500
Received: by ey-out-2122.google.com with SMTP id d26so1156419eyd.19
        for <netdev@vger.kernel.org>; Mon, 07 Dec 2009 07:19:44 -0800 (PST)
In-Reply-To: <20091207144736.GB8073@hmsreliant.think-freely.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

2009/12/7 Neil Horman <nhorman@tuxdriver.com>:
> Update e1000 driver to not allow dma beyond the end of the allocated =
skb
>
[...]
> +static inline u32 normalize_rx_len(u32 len)
> +{
> + =A0 =A0 =A0 =A0u32 match, last_match;
> +
> +
> + =A0 =A0 =A0 =A0for (match =3D 0x100; match <=3D 0x4000; match *=3D =
2) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0if (len <=3D match)
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0return match;
> + =A0 =A0 =A0 =A0}
> +
> + =A0 =A0 =A0 =A0return 0;
> +}
> +

You could use roundup_pow_of_two() instead.

Best Regards,
Micha=B3 Miros=B3aw
