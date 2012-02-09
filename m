From: Sven Eckelmann <sven-KaDOiPu9UxWEi8DpZVb4nw@public.gmane.org>
Subject: Re: [PATCH 40/50] batman-adv: use
	dev_hw_addr_random() instead of random_ether_addr()
Date: Thu, 09 Feb 2012 09:44:12 +0100
Message-ID: <4131504.bFpDbrJZp3@sven-laptop.home.narfation.org>
References: <1328735457-29986-1-git-send-email-danny.kukawka@bisect.de>
	<1328735457-29986-41-git-send-email-danny.kukawka@bisect.de>
Reply-To: The list for a Better Approach To Mobile Ad-hoc Networking
	<b.a.t.m.a.n-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org>
Mime-Version: 1.0
Content-Type: multipart/signed; boundary="nextPart14017467.JRCiTb72lR";
	micalg="pgp-sha512"; protocol="application/pgp-signature"
Content-Transfer-Encoding: 7Bit
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Danny Kukawka <dkukawka-l3A5Bk7waGM@public.gmane.org>,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Simon Wunderlich <siwu-MaAgPAbsBIVS8oHt8HbXEIQuADTiUCJX@public.gmane.org>,
	Danny Kukawka <danny.kukawka-2YacvwyR+KOzQB+pC5nmwQ@public.gmane.org>,
	Marek Lindner <lindner_marek-LWAfsSFWpa4@public.gmane.org>,
	"David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
To: b.a.t.m.a.n-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org
Return-path: <b.a.t.m.a.n-bounces-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org>
In-Reply-To: <1328735457-29986-41-git-send-email-danny.kukawka-2YacvwyR+KOzQB+pC5nmwQ@public.gmane.org>
List-Unsubscribe: <https://lists.open-mesh.org/mm/options/b.a.t.m.a.n>,
	<mailto:b.a.t.m.a.n-request-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.open-mesh.org/pipermail/b.a.t.m.a.n>
List-Post: <mailto:b.a.t.m.a.n-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org>
List-Help: <mailto:b.a.t.m.a.n-request-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org?subject=help>
List-Subscribe: <https://lists.open-mesh.org/mm/listinfo/b.a.t.m.a.n>,
	<mailto:b.a.t.m.a.n-request-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org?subject=subscribe>
Sender: b.a.t.m.a.n-bounces-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org
Errors-To: b.a.t.m.a.n-bounces-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org
List-Id: netdev.vger.kernel.org


--nextPart14017467.JRCiTb72lR
Content-Transfer-Encoding: 7Bit
Content-Type: text/plain; charset="ISO-8859-1"

On Wednesday 08 February 2012 22:10:47 Danny Kukawka wrote:
> Use dev_hw_addr_random() instead of calling random_ether_addr()
> to set addr_assign_type correctly to NET_ADDR_RANDOM.
> 
> Reset the state to NET_ADDR_PERM as soon as the MAC get
> changed via .ndo_set_mac_address.
> 
> Signed-off-by: Danny Kukawka <danny.kukawka-2YacvwyR+KOzQB+pC5nmwQ@public.gmane.org>
> ---
>  net/batman-adv/soft-interface.c |    7 ++++---
>  1 files changed, 4 insertions(+), 3 deletions(-)
> 
> diff --git a/net/batman-adv/soft-interface.c
> b/net/batman-adv/soft-interface.c index 987c75a..865a485 100644
> --- a/net/batman-adv/soft-interface.c
> +++ b/net/batman-adv/soft-interface.c
> @@ -541,6 +541,9 @@ static int interface_set_mac_addr(struct net_device
> *dev, void *p) }
> 
>  	memcpy(dev->dev_addr, addr->sa_data, ETH_ALEN);
> +	if (dev->addr_assign_type & NET_ADDR_RANDOM)
> +		dev->addr_assign_type ^= NET_ADDR_RANDOM;
> +
>  	return 0;
>  }

Why not something like

dev->addr_assign_type &= ~NET_ADDR_RANDOM;

? It is a relative common way inside the kernel to do this kind of stuff.

Thanks,
	Sven

PS: For the batman-adv people. This functionality was introduced with 2.6.36. 
--nextPart14017467.JRCiTb72lR
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part.

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.11 (GNU/Linux)

iQIcBAABCgAGBQJPM4dcAAoJEF2HCgfBJntGnHUP/3Vrc6d5QO0uEbhtNFkCLn+k
0bRP1ad4SpSC4a94B8/cblQ/HXujqE1fvVkZrtRKss6gkhYLFwOzBvKff0cOt658
v8i7jRfo4REKjdHUWFZtyUX+SnE+IXbJ3UbxJNoRwUq+WamI5aCNKBGBaHWIx2rS
CkEZuWSc7U9g1Ic74gycS7AmLr/nCRcTRxq2Z1XieCUB81atAG5SfwdvYlWIka9p
OWp+uPKdMQ2w+nEpwJgTdXnR3aRe5eVuiHgqGBlPRAWEgfgidLWqLSO5Hx2k4tnw
cG5y4N/BKcF0tv5Yy24Y9C1SVyWNPwUi8xeHnpqZO9RTlkuCnykLi6q/tKZiC8kQ
22fWSmRIc/qL4AzEuSHART4Ejtd8haoszIWTw00vCWstEkqo7K/xY2uzGEZdeH5T
i6zH1XxtBnGDYCODTCdSD/J33s348cDdSrfpNPubYpcxBvIaKnjpDVNK1sAmVf46
LiJfCM5d/6FqhNnkUg6lCMRv/Qiu4NiexzmzNR0HNswSPTZDqvTAK2XUwUciMQBN
5Ks7KEXttyRksSesYHM3lI6Ig0+OOX6jUWEHmguK1FnC6WsDEFXC35S9EvPa2GmK
ggHlJfmBqHO+wQwvLmf0tH0S2ADogCtHel70ciI8G2qSDc8A3t0POqa5Hu0E34FZ
wpjyK1883XjbbsfK4msM
=r1h5
-----END PGP SIGNATURE-----

--nextPart14017467.JRCiTb72lR--
