From: Akinobu Mita <akinobu.mita@gmail.com>
Subject: Re: [PATCH 2/5] drivers/net/ethernet/dec/tulip: Use standard
 __set_bit_le() function
Date: Wed, 13 Jun 2012 18:43:40 +0900
Message-ID: <CAC5umyj582T+9GbOYDzOAanmMcVZ-Fdxr7i-8GWf3gTSmtAKUA@mail.gmail.com>
References: <20120613130054.b5695621.yoshikawa.takuya@oss.ntt.co.jp>
	<20120613130304.0186fa9d.yoshikawa.takuya@oss.ntt.co.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: akpm@linux-foundation.org, bhutchings@solarflare.com,
	grundler@parisc-linux.org, arnd@arndb.de, benh@kernel.crashing.org,
	avi@redhat.com, mtosatti@redhat.com,
	linux-net-drivers@solarflare.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, linux-arch@vger.kernel.org,
	kvm@vger.kernel.org, takuya.yoshikawa@gmail.com
To: Takuya Yoshikawa <yoshikawa.takuya@oss.ntt.co.jp>
Return-path: <linux-arch-owner@vger.kernel.org>
In-Reply-To: <20120613130304.0186fa9d.yoshikawa.takuya@oss.ntt.co.jp>
Sender: linux-arch-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

2012/6/13 Takuya Yoshikawa <yoshikawa.takuya@oss.ntt.co.jp>:
> From: Takuya Yoshikawa <yoshikawa.takuya@oss.ntt.co.jp>
>
> To introduce generic set_bit_le() later, we remove our own definition
> and use a proper non-atomic bitops function: __set_bit_le().
>
> Signed-off-by: Takuya Yoshikawa <yoshikawa.takuya@oss.ntt.co.jp>
> Acked-by: Grant Grundler <grundler@parisc-linux.org>
> ---
> =A0drivers/net/ethernet/dec/tulip/de2104x.c =A0 =A0| =A0 =A07 ++-----
> =A0drivers/net/ethernet/dec/tulip/tulip_core.c | =A0 =A07 ++-----
> =A02 files changed, 4 insertions(+), 10 deletions(-)
>
> diff --git a/drivers/net/ethernet/dec/tulip/de2104x.c b/drivers/net/e=
thernet/dec/tulip/de2104x.c
> index 61cc093..77335853 100644
> --- a/drivers/net/ethernet/dec/tulip/de2104x.c
> +++ b/drivers/net/ethernet/dec/tulip/de2104x.c
> @@ -661,9 +661,6 @@ static netdev_tx_t de_start_xmit (struct sk_buff =
*skb,
> =A0 =A0new frame, not around filling de->setup_frame. =A0This is non-=
deterministic
> =A0 =A0when re-entered but still correct. */
>
> -#undef set_bit_le
> -#define set_bit_le(i,p) do { ((char *)(p))[(i)/8] |=3D (1<<((i)%8));=
 } while(0)
> -
> =A0static void build_setup_frame_hash(u16 *setup_frm, struct net_devi=
ce *dev)
> =A0{
> =A0 =A0 =A0 =A0struct de_private *de =3D netdev_priv(dev);
> @@ -673,12 +670,12 @@ static void build_setup_frame_hash(u16 *setup_f=
rm, struct net_device *dev)
> =A0 =A0 =A0 =A0u16 *eaddrs;
>
> =A0 =A0 =A0 =A0memset(hash_table, 0, sizeof(hash_table));
> - =A0 =A0 =A0 set_bit_le(255, hash_table); =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 =A0/* Broadcast entry */
> + =A0 =A0 =A0 __set_bit_le(255, hash_table); =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0 =A0/* Broadcast entry */

Should this hash_table be converted from u16 hash_table[32] to
DECLARE_BITMAP(hash_table, 16 * 32) to ensure that it is aligned
on long-word boundary?
