From: Eliad Peller <eliad@wizery.com>
Subject: Re: [PATCH 3/5] net/mac80211/debugfs.c: use kstrtoul, etc
Date: Mon, 7 Nov 2011 13:47:27 +0200
Message-ID: <CAB3XZEfHV+sO=+vJdZUQVqXFtHvZyhJQ1Cm8LJ8Puyz9eqq9Kg@mail.gmail.com>
References: <1320586010-21931-1-git-send-email-julia@diku.dk>
	<1320586010-21931-4-git-send-email-julia@diku.dk>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "John W. Linville" <linville@tuxdriver.com>,
	kernel-janitors@vger.kernel.org,
	Johannes Berg <johannes@sipsolutions.net>,
	"David S. Miller" <davem@davemloft.net>,
	linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Julia Lawall <julia@diku.dk>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1320586010-21931-4-git-send-email-julia@diku.dk>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sun, Nov 6, 2011 at 3:26 PM, Julia Lawall <julia@diku.dk> wrote:
> From: Julia Lawall <julia@diku.dk>
>
> Use kstrtoul, etc instead of the now deprecated strict_strtoul, etc.
>
> A semantic patch rule for the kstrtoul case is as follows:
> (http://coccinelle.lip6.fr/)
>
> // <smpl>
> @@
> expression a,b;
> {int,long} *c;
> @@
>
> -strict_strtoul
> +kstrtoul
> =A0(a,b,c)
> // </smpl>
>
> Signed-off-by: Julia Lawall <julia@diku.dk>
>
> ---
> =A0net/mac80211/debugfs.c | =A0 =A02 +-
> =A01 file changed, 1 insertion(+), 1 deletion(-)
>
> diff -u -p a/net/mac80211/debugfs.c b/net/mac80211/debugfs.c
> --- a/net/mac80211/debugfs.c
> +++ b/net/mac80211/debugfs.c
> @@ -190,7 +190,7 @@ static ssize_t uapsd_max_sp_len_write(st
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0return -EFAULT;
> =A0 =A0 =A0 =A0buf[len] =3D '\0';
>
> - =A0 =A0 =A0 ret =3D strict_strtoul(buf, 0, &val);
> + =A0 =A0 =A0 ret =3D kstrtoul(buf, 0, &val);
>
> =A0 =A0 =A0 =A0if (ret)
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0return -EINVAL;
>

maybe while cleaning it up change copy_from_user +
strict_stroul/kstroul -> kstroul_from_user?

Eliad.
