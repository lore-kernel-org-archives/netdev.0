From: Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>
Subject: Re: [PATCH 1/2] mac802154: add a software MAC 802.15.4
 implementation
Date: Mon, 10 Aug 2009 16:27:46 +0200
Message-ID: <1249914466.32614.13.camel@johannes.local>
References: <1249913800-10176-1-git-send-email-dbaryshkov@gmail.com>
	 <1249913800-10176-2-git-send-email-dbaryshkov@gmail.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha1"; protocol="application/pgp-signature"; boundary="=-KsYkkV96P1gPmlwoM3O1"
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	Sergey Lapin <slapin-9cOl001CZnBAfugRpC6u6w@public.gmane.org>
To: Dmitry Eremin-Solenikov <dbaryshkov-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1249913800-10176-2-git-send-email-dbaryshkov-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org


--=-KsYkkV96P1gPmlwoM3O1
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable

On Mon, 2009-08-10 at 18:16 +0400, Dmitry Eremin-Solenikov wrote:
> Some of available devices are just dump radios implementing IEEE 802.15.4

dump -> dumb

> Note this implementaion is neither certified, nor feature complete!

implementation

> + * @tx: Handler that 802.15.4 module calls for each transmitted frame.
> + *      skb cntains the buffer starting from the IEEE 802.15.4 header.
> + *      The low-level driver should send the frame based on available
> + *      configuration.
> + *      This function should return zero or negative errno.

That return value is strange.

> +++ b/net/Makefile
> @@ -61,6 +61,7 @@ ifneq ($(CONFIG_DCB),)
>  obj-y				+=3D dcb/
>  endif
>  obj-y				+=3D ieee802154/
> +obj-y				+=3D mac802154/

I think you should use obj-$(CONFIG_MAC802154) as there's no need to
recurse into the dir unless that's selected.

But does it make sense to actually have this little code as a separate
dir/module?

> +	  Note: this implementation is neither certified, nor feature
> +	  complete! We do not garantee that it is compatible w/ other
> +	  implementations, etc.

guarantee

But generally, you don't have to write that anyway due to the license.

> +	  If you plan to use HardMAC IEEE 802.15.4 devices, you can
> +          say N here. Alternatievly you can say M to compile it as
> +	  module.

white space gone wrong

> +	struct net_device *netdev; /* mwpanX device */
> +	int open_count;
> +	/* As in mac80211 slaves list is modified:
> +	 * 1) under the RTNL
> +	 * 2) protected by slaves_mtx;
> +	 * 3) in an RCU manner
> +	 *
> +	 * So atomic readers can use any of this protection methods
> +	 */
> +	struct list_head	slaves;

heh.

> +static int ieee802154_master_open(struct net_device *dev)
> +{

We've had no end to trouble with the master netdev, I suggest you look
into the current mac80211 code and see if you can get rid of it.

> +struct ieee802154_dev *ieee802154_alloc_device(size_t priv_size,
> +		struct ieee802154_ops *ops)
> +{

> +	if (!try_module_get(ops->owner)) {

That isn't necessary since the module is just calling your function. In
fact, doing this removes the ability to rmmod any module using this
which is bogus.

johannes

--=-KsYkkV96P1gPmlwoM3O1
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----

iQIcBAABAgAGBQJKgC5fAAoJEODzc/N7+QmaSWMP/3s6Mpb1g0XXrIGJPUJ4acNA
sdT8jOQGGTyVQOnb2qm9sDJ/PCEtXFrEuXAWzF4Xw/q4JW18B4rFhc0jOD109QGI
ahe62VwJGXzErcWnomm4QE1tXilJ3rpgT8K+H66rP5p7/mo60Rg1JwPsUoGYMBoX
g0tu9avvKt9f0ACKu0GmrvMiW5yOeAwdP3MzhoeSRAeflbXZ2Zc9F55AX9DxxwDR
a1D2+42ZG0eI7/tDIU/8Df6pswU5n2CezcUpxUxq+hKcXb+MsRO6wtum2cd3cNm2
h0e7JOpBCEgM+2rE6N2uaKzMbjjeg6EhITTvvFok5ASkOrjzbJlrpYYOFrB26AgZ
BeLt3u06aLFvXT+6EqpKkOpGjbFwJwowvu63gw5iOBQWcz2HysBpdcjAy8BmVrQI
8WUFhDB4A18X6fbedlfCuhyevVhbq9PmU3kCcPFW2pAAlQLwcSvygs9DSLW4k5Gv
ZQuvisTAHRVD6WyqNzO8Ma7DL6k/31rGLHFRFl1zocIQFvEqiFFpoS4GOt5JSWC3
FMBfMf+DZYFIrH+rY16fH7QvSCTUbbCJ3gRUwp5J/KhTLawtr520vhVE5bWPfhaV
k+ALH5ygGhOEgQ1JCxuSMNbLVD9Lbj0BXS2rVAWHxx5u0zain80m8EBgsPGyaeWZ
x8dWHyNo2P7fGYqaesHR
=gpG+
-----END PGP SIGNATURE-----

--=-KsYkkV96P1gPmlwoM3O1--

--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
