From: Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>
Subject: Re: [RFC v2] mac80211: assign needed_headroom/tailroom for netdevs
Date: Mon, 05 May 2008 17:22:03 +0200
Message-ID: <1210000923.8245.26.camel@johannes.berg>
References: <1209936253.7304.10.camel@johannes.berg>
	 <1209936745.7304.16.camel@johannes.berg>
	 <20080504.173051.133197507.davem@davemloft.net>
	 <1209972139.3655.9.camel@johannes.berg>
	 <1ba2fa240805050727r2060b0b4x3a9b3240647b66b1@mail.gmail.com>
	 (sfid-20080505_162641_085309_1D6B25FD)
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1; protocol="application/pgp-signature"; boundary="=-K7CBnQ8K0ZyVE0Df64DJ"
Cc: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>, linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Tomas Winkler <tomasw-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1ba2fa240805050727r2060b0b4x3a9b3240647b66b1-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org> (sfid-20080505_162641_085309_1D6B25FD)
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org


--=-K7CBnQ8K0ZyVE0Df64DJ
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable


> I've did some measurement of the TX path  on an embedded system (2.6.23 k=
ernel)
> When bridging packets from an ethernet device to wireless  there is
> loss of 12% in the CPU utilization and equivalent throughput reduction
> in data packets that are checked and expanded in
> ieee80211_subif_start_xmit function.

Yeah, I figured.

> The expansion is just due to bigger size of the 80211 header size, yet
> the whole packet is reallocated and copied. As we are reaching 11n
> rates 200bps and up this starts to be visible.
> When header was reserved to the  proper side already in the ethernet
> driver the overhead was gone. Yet this doesn't seems to be a correct
> solution for bridging or forwarding.
> For example Iwlwifi HW supports scattered packets this would allow
> just reallocate the header, providing data portion is aligned.

Right. Not all hardware supports this though, but even when it does I
don't see what we can do unless we want to do all this inside mac80211
which I'd rather not.

SKBs don't have a way to say "I need N bytes writable headroom but I can
do s/g operation for the rest" which is what we'd need. If that was
available, we could even work with clones, then we could pull away the
ethernet header and build the 802.11/device headers in separate buffers,
demoting the old 'skb head' buffer to a data buffer...

johannes

--=-K7CBnQ8K0ZyVE0Df64DJ
Content-Type: application/pgp-signature; name=signature.asc
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Comment: Johannes Berg (powerbook)

iQIVAwUASB8mGaVg1VMiehFYAQK2xhAAh+MikUeIysVY38j22KmOoKfGQMN310YH
V9hdxW6nOQKBTIWHXyBCWNHTLRh3LTdbswSBgDrC3Dy22H5W2cFajhKhHaEsSVkP
86drDREaZUmB7O2oKY1PYRX5G2jD6f8jTzZnSkO/orCszP4Lag6LB+GpmPfMYxNr
UaqW8M6fLFMz+ko9GiuxL2gX1eH4I0PDewzg6Nx71bOw8T5U7qFdYMBHmi4352Du
fGp1L2uHGhKbolPYpLnPC4kOllpPgyxEBmKzYQo8Uh0uqaTN2Ut7e3IMtIC9z3o0
x8/d9maYErN4HZwHoCA4KiM9i7OEkQok3dSJZMF81mQjKZZRwqBphzLq9EzU6sW2
bHHPEbf8xFo/QdKM04L6TUxq+VTyJuE6QTjO4n1ZQeoNwdjjXKHl4ra8yO79mj84
6c3XF7w4W0Ex6I9D+uVwz1YzqmaW0UvVZc4wOsJV+QAFyu+4YdzdMa2G2Sd+z1EU
DreH9RP3ZNppjA+B7csgsB0yosTuPx6T0uNzNXumYbbskzNQa5elS9aQAIxej1QY
biedylXwcDqvAUi2zM1GtNzqUr4gI8wTvfMAWARCCIar8WkbKxQIX8SLIeS7fkBB
1tXgMwU+eqX89nIakxsgKwtXQXJxcy0S1I7skaFZUMUEw6vcj98VEtUrHg/4PniF
sVAmcDu0gpQ=
=tS0y
-----END PGP SIGNATURE-----

--=-K7CBnQ8K0ZyVE0Df64DJ--

--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
