From: Josh Triplett <josh@joshtriplett.org>
Subject: Re: [PATCH 05/13] net: Mark function as static in core/filter.c
Date: Sat, 8 Feb 2014 12:09:52 -0800
Message-ID: <20140208200951.GE20885@leaf>
References: <6f029c895035908595957fb16ab445c82793c77d.1391888654.git.rashika.kheria@gmail.com>
 <b4fedb3d1984f8e1878015e12b7214c00a6588bb.1391888654.git.rashika.kheria@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-kernel@vger.kernel.org,
	"David S. Miller" <davem@davemloft.net>,
	Eric Dumazet <edumazet@google.com>,
	Alexei Starovoitov <ast@plumgrid.com>,
	Nicolas Dichtel <nicolas.dichtel@6wind.com>,
	Daniel Borkmann <dborkman@redhat.com>, netdev@vger.kernel.org
To: Rashika Kheria <rashika.kheria@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <b4fedb3d1984f8e1878015e12b7214c00a6588bb.1391888654.git.rashika.kheria@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sun, Feb 09, 2014 at 01:25:05AM +0530, Rashika Kheria wrote:
> Mark function as static in core/filter.c because it is not used outsi=
de
> this file.
>=20
> This eliminates the following warning in core/filter.c:
> net/core/filter.c:48:7: warning: no previous prototype for =E2=80=98b=
pf_internal_load_pointer_neg_helper=E2=80=99 [-Wmissing-prototypes]
>=20
> Signed-off-by: Rashika Kheria <rashika.kheria@gmail.com>

This function actually is used outside this file, just not from C code;
a couple of assembly files call it.  (See also the comment above this
definition: "Exported for the bpf jit load helper.")

I'd suggest prototyping this function in include/linux/filter.h , unles=
s
someone on CC has another preference.

>  net/core/filter.c |    3 ++-
>  1 file changed, 2 insertions(+), 1 deletion(-)
>=20
> diff --git a/net/core/filter.c b/net/core/filter.c
> index ad30d62..a022dad 100644
> --- a/net/core/filter.c
> +++ b/net/core/filter.c
> @@ -44,7 +44,8 @@
>   *
>   * Exported for the bpf jit load helper.
>   */
> -void *bpf_internal_load_pointer_neg_helper(const struct sk_buff *skb=
, int k, unsigned int size)
> +static void *bpf_internal_load_pointer_neg_helper(const struct sk_bu=
ff *skb,
> +						  int k, unsigned int size)
>  {
>  	u8 *ptr =3D NULL;
> =20
> --=20
> 1.7.9.5
>=20
