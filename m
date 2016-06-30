From: Stefan Hajnoczi <stefanha@redhat.com>
Subject: Re: [RFC v2 1/3] vsockmon: Add tap functions
Date: Thu, 30 Jun 2016 11:49:12 +0100
Message-ID: <20160630104912.GB31866@stefanha-x1.localdomain>
References: <20160622161102.8250-1-ggarcia@deic.uab.cat>
 <20160622161102.8250-2-ggarcia@deic.uab.cat>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="neYutvxvOLaeuPCA"
Cc: netdev@vger.kernel.org, jhansen@vmware.com
To: ggarcia@abra.uab.cat
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:54950 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751825AbcF3Ktm (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 30 Jun 2016 06:49:42 -0400
Content-Disposition: inline
In-Reply-To: <20160622161102.8250-2-ggarcia@deic.uab.cat>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--neYutvxvOLaeuPCA
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

On Wed, Jun 22, 2016 at 06:11:00PM +0200, ggarcia@abra.uab.cat wrote:
> +int __vsock_remove_tap(struct vsock_tap *vt) {

This function should be static, it's not used outside this source file.

> +static int __vsock_deliver_tap_skb(struct sk_buff *skb,
> +				     struct net_device *dev)
> +{
> +	int ret = 0;
> +
> +	if (skb) {
> +		dev_hold(dev);

I don't understand the need for this dev_hold()/dev_put().  Can anyone
explain why it is necessary?

> +		/* Take skb ownership so it is not consumed in dev_queue_xmit.
> +		 * dev_queue_xmit will drop a reference so the reference count
> +		 * will reset.
> +		 */
> +		skb_get(skb);
> +		skb->dev = dev;
> +		ret = dev_queue_xmit(skb);
> +		if (unlikely(ret > 0))
> +			ret = net_xmit_errno(ret);
> +
> +		dev_put(dev);
> +	}
> +
> +	return ret;
> +}

--neYutvxvOLaeuPCA
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iQEcBAEBAgAGBQJXdPkoAAoJEJykq7OBq3PIXvIIAIv6cjCJq9zyOlDzqll4kymL
dw0Mo1KUN6x6kU22dG6U8zDYjUvx79juQfBKD+fAgW4FNhRdCYZYkrCFRk3NA+3I
Gh/21haMhqxosa+3exm2ModKgf1OtEvB5unKfbVt+8LEoOZuMkHLpay4p4Gj55E9
1R4sdXfaJMOhU23JT6+QxXcEivR2gKjvPvQNxpU747SeFTmOmS5mEXi/FOlWcvlU
dAeCaBi2A6hhrGjtIKv4sREc6Kz7sNxeHU9DaCNmlx+ZZkeraSMoNJiJxdFTb9Jh
RrI6NPb+pry6qOkVaSfkCg4BNV3bVIDT9gWvMlrz+AIKz76d3r2A7FxUck+jAL4=
=UhrZ
-----END PGP SIGNATURE-----

--neYutvxvOLaeuPCA--
