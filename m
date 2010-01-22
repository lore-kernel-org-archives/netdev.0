From: Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>
Subject: Re: [RFC/RFT v2]: compat-wireless for 2.6.32.4 - multiqueue
 backport support
Date: Fri, 22 Jan 2010 10:34:38 +0100
Message-ID: <1264152878.11396.82.camel@johannes.local>
References: <20100121230600.GC8069@bombadil.infradead.org>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha1"; protocol="application/pgp-signature"; boundary="=-Y2lRYMtXEIiuOcXYUrKf"
Cc: linux-wireless <linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, lrodriguez-DlyHzToyqoxBDgjK7y7TUQ@public.gmane.org
To: "Luis R. Rodriguez" <mcgrof-PfSpb0PWhxZc2C7mugBRk2EX/6BAtgUQ@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20100121230600.GC8069-PfSpb0PWhxZc2C7mugBRk2EX/6BAtgUQ@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org


--=-Y2lRYMtXEIiuOcXYUrKf
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Thu, 2010-01-21 at 18:06 -0500, Luis R. Rodriguez wrote:

> +#if (LINUX_VERSION_CODE < KERNEL_VERSION(2,6,23))
> +static bool ieee80211_all_queues_stopped(struct ieee80211_hw *hw)

You want "all queues started" :)

> +{
> +	unsigned int queue;
> +
> +	for (queue =3D 0; queue < hw->queues; queue++)
> +		if (!ieee80211_queue_stopped(hw, queue))
> +			return false;
> +	return true;
> +}
> +#endif
> +
>  static void __ieee80211_wake_queue(struct ieee80211_hw *hw, int queue,
>  				   enum queue_stop_reason reason)
>  {
> @@ -287,7 +299,14 @@ static void __ieee80211_wake_queue(struc
> =20
>  	rcu_read_lock();
>  	list_for_each_entry_rcu(sdata, &local->interfaces, list)
> +#if (LINUX_VERSION_CODE >=3D KERNEL_VERSION(2,6,27))
>  		netif_tx_wake_queue(netdev_get_tx_queue(sdata->dev, queue));
> +#elif (LINUX_VERSION_CODE >=3D KERNEL_VERSION(2,6,23))
> +		netif_start_subqueue(sdata->dev, queue);
> +#else
> +		if (ieee80211_all_queues_stopped(hw))
> +			netif_wake_queue(sdata->dev);
> +#endif

johannes

--=-Y2lRYMtXEIiuOcXYUrKf
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----

iQIcBAABAgAGBQJLWXEqAAoJEODzc/N7+Qma9d0QAJwUvmv0SXub+L6ZrqBr/P8L
io8CvGP3XBTmWuxUzUPZDSwBf8wo/km0v35bN7213Kwv463lVjvXHBoTsyROlyCg
xFgovbiaPLacdcwHQcMn9TsBB8dumRuawisVPTN+w6erK16bN0UDYyxCI4u3ELtp
q1Wv93QD+gv3q2uV3CNqS2gLpDwdReel+SFuD+u4Ak0j5ziFm5ENvR4x5r6GtHbG
JrNxs9OBiyJnNaRCCa9oy/NUU8wChwCCPO9pMOk1CtQ0u9QQHtzYO0OyqlB89qP+
2g1PXQb4UZajekG43UpvZwuj+ot0xi4D6IryJ4hrPaceNAMRXnZf3RIJNtUyhVKV
CNOyVHvXUnjeQexgDwmfJnOIcfqPu+08ENPaBgbBF4fbPdE4u3WaZiVJ3DSvVQK7
dF/N+coJ5Fp2hO20P43iUXHBAGJ0BpsNOZn+FJzF4nxtCQcO0cFOZUEChGPxJaXg
vzHr9VvJi0af1qfrNcG56cMNF9929w+0BF2M3hlsxv+P7+PL1MSGEDYHzv/sbHu8
KcVN9vBiR55lYkveWhoo93eS31q4fIIO03/X/D9WPUZ6VY0gSkU7jEoi74YQXEgN
g91SndS9jBwJVsPvCXqJ1TpO4CxnoTOGaKG4kzHDsu/g5D9ZPX+QRvvx4MyDz6vW
ng+tpvU7c7mEsg7vzXT7
=zv5J
-----END PGP SIGNATURE-----

--=-Y2lRYMtXEIiuOcXYUrKf--

--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
