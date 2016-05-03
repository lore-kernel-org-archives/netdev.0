From: Greg Kroah-Hartman <greg@kroah.com>
Subject: Re: [PATCH] fix infoleak in wireless
Date: Tue, 3 May 2016 14:34:01 -0700
Message-ID: <20160503213401.GB23469@kroah.com>
References: <1462308013-6032-1-git-send-email-kjlu@gatech.edu>
 <1462308044.10444.19.camel@sipsolutions.net>
 <CABEk9YxqyBxnqOseJ3-d-aKxnREZBFt1z89nOjHf=DvNQy_hTw@mail.gmail.com>
 <20160503210052.GA23109@kroah.com>
 <CABEk9YwiqpP+Ahxax3AC7tbPcmpUQnrB-Nwsb4rixhVjcL4Crw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Johannes Berg <johannes@sipsolutions.net>, davem@davemloft.net,
	linux-wireless@vger.kernel.org, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, Kangjie Lu <kjlu@gatech.edu>
To: Kangjie Lu <kangjielu@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <CABEk9YwiqpP+Ahxax3AC7tbPcmpUQnrB-Nwsb4rixhVjcL4Crw@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, May 03, 2016 at 05:11:07PM -0400, Kangjie Lu wrote:
> Opps, I did not notice the patch is not attached.
>=20
> From 34a82a734388d07eb10f91770f86938e38f7575a Mon Sep 17 00:00:00 200=
1
> From: Kangjie Lu <kjlu@gatech.edu>
> Date: Tue, 3 May 2016 14:15:18 -0400
> Subject: [PATCH] fix infoleak in wireless
> MIME-Version: 1.0
> Content-Type: text/plain; charset=3DUTF-8
> Content-Transfer-Encoding: 8bit
>=20
> The 6-bytes array =E2=80=9Cmac_addr=E2=80=9D is not initialized in th=
e dump_station
> implementations of =E2=80=9Cdrivers/staging/wilc1000/wilc_wfi_cfgoper=
ations.c=E2=80=9D
> and =E2=80=9Cdrivers/staging/rtl8723au/os_dep/ioctl_cfg80211.c=E2=80=9D=
, so all 6
> bytes may be leaked.
>=20
> Signed-off-by: Kangjie Lu <kjlu@gatech.edu>
> ---
> =C2=A0net/wireless/nl80211.c | 1 +
> =C2=A01 file changed, 1 insertion(+)
>=20
> diff --git a/net/wireless/nl80211.c b/net/wireless/nl80211.c
> index 056a730..2e92d14 100644
> --- a/net/wireless/nl80211.c
> +++ b/net/wireless/nl80211.c
> @@ -3905,6 +3905,7 @@ static int nl80211_dump_station(struct sk_buff =
*skb,
> =C2=A0
> =C2=A0 while (1) {
> =C2=A0 memset(&sinfo, 0, sizeof(sinfo));
> + eth_zero_addr(mac_addr);
> =C2=A0 err =3D rdev_dump_station(rdev, wdev->netdev, sta_idx,
> =C2=A0 mac_addr, &sinfo);
> =C2=A0 if (err =3D=3D -ENOENT)

Patch is corrupted :(

Why not fix up the staging drivers, they are the real problem here,
which is what I think the networking maintainers were telling you to do=
=2E

thanks,

greg k-h
