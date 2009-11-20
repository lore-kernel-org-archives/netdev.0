From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH 1/1] Defer skb allocation for both mergeable buffers and
 big packets in virtio_net
Date: Fri, 20 Nov 2009 07:19:53 +0100
Message-ID: <4B063509.10006@gmail.com>
References: <1258697745.7416.20.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "Michael S. Tsirkin" <mst@redhat.com>, Avi Kivity <avi@redhat.com>,
	Rusty Russell <rusty@rustcorp.com.au>, netdev@vger.kernel.org,
	kvm@vger.kernel.org, linux-kernel@vger.kernel.org
To: Shirley Ma <mashirle@us.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([212.99.114.194]:48429 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754012AbZKTGUV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 20 Nov 2009 01:20:21 -0500
In-Reply-To: <1258697745.7416.20.camel@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Shirley Ma a =E9crit :
> This patch is generated against 2.6 git tree. I didn't break up this
> patch since it has one functionality. Please review it.
>=20
> Thanks
> Shirley
>=20
> Signed-off-by: Shirley Ma <xma@us.ibm.com>
> ------
> =20
> +void virtio_free_pages(void *buf)
> +{
> +	struct page *page =3D (struct page *)buf;
> +
> +	while (page) {
> +		__free_pages(page, 0);
> +		page =3D (struct page *)page->private;
> +	}
> +}
> +

Interesting use after free :)
