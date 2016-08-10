From: Stefan Hajnoczi <stefanha@redhat.com>
Subject: Re: [PATCH 1/3] vsockmon: Add tap functions.
Date: Wed, 10 Aug 2016 12:40:33 +0100
Message-ID: <20160810114033.GA10461@stefanha-x1.localdomain>
References: <20160808161442.16038-1-ggarcia@deic.uab.cat>
 <20160808161442.16038-2-ggarcia@deic.uab.cat>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="GvXjxJ+pjyke8COw"
Cc: netdev@vger.kernel.org, jhansen@vmware.com, mst@redhat.com
To: ggarcia@abra.uab.cat
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:52960 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S936597AbcHJSqq (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 10 Aug 2016 14:46:46 -0400
Content-Disposition: inline
In-Reply-To: <20160808161442.16038-2-ggarcia@deic.uab.cat>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--GvXjxJ+pjyke8COw
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

On Mon, Aug 08, 2016 at 06:14:40PM +0200, ggarcia@abra.uab.cat wrote:
> +static int __vsock_deliver_tap_skb(struct sk_buff *skb,
> +				     struct net_device *dev)
> +{
> +	int ret = 0;
> +
> +	if (skb) {
> +		dev_hold(dev);
> +		/* Take skb ownership so it is not consumed in dev_queue_xmit.
> +		 * dev_queue_xmit will drop a reference so the reference count
> +		 * will reset.
> +		 */
> +		skb_get(skb);

Netlink clones the skb instead of adding a reference.  I guess this is
because the skb might be modified later on?  Perhaps there are race
conditions if the original skb is shared.

--GvXjxJ+pjyke8COw
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iQEcBAEBAgAGBQJXqxKxAAoJEJykq7OBq3PIJ9wH/iJyN7k/6Fb9Ki2F1B3UfJOj
zeWgTTplbJe6ZBSDNwcwRh89xYn+tLRabYPq3re4HvHF0JBuoRVmAcepKgB4yOEk
JNgRxHhgtdY3az74IanFxBcBSYP31gSjCdHgDvFdxWzeeFPLtI1hiSEJMBNpT3jM
2/+TA57xNx1uAP2gNZbGx7AkhN3j99XfETR6laKSzX5xd2TCft0cJEnn6E4mr/hr
2QEy5x79ASFL68fnKiR1oYXYbAg0tJ2Qhvk0eKRqDoNIznck7I0M5afZCgqqDNHs
/BSf8+baN2INM4b/DdrEvv3zwvAqxWVlPnrA2nZ8uWY8UPcX42iMdCPJBBTkP0M=
=9KeV
-----END PGP SIGNATURE-----

--GvXjxJ+pjyke8COw--
