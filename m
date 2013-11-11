From: Fan Du <fan.du@windriver.com>
Subject: Re: [PATCH v3 net-next] xfrm: Add check to prevent un-complete key
 manager
Date: Mon, 11 Nov 2013 15:11:59 +0800
Message-ID: <5280833F.6010800@windriver.com>
References: <1384093556-8987-1-git-send-email-baker.kernel@gmail.com> <1384151951-13549-1-git-send-email-baker.kernel@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: <davem@davemloft.net>, <herbert@gondor.hengli.com.au>,
	<steffen.klassert@secunet.com>, <netdev@vger.kernel.org>,
	<linux-kernel@vger.kernel.org>
To: <baker.kernel@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1384151951-13549-1-git-send-email-baker.kernel@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org



On 2013=E5=B9=B411=E6=9C=8811=E6=97=A5 14:39, baker.kernel@gmail.com wr=
ote:
> From: Baker Zhang<Baker.kernel@gmail.com>
>
> "acquire" and "compile_policy" callbacks are necessary for a key mana=
ger.
>
> Signed-off-by: Baker Zhang<Baker.kernel@gmail.com>
> ---
> Thanks for all reply.
>
> V1:
> For current kernel source, there is no problem.
>
> In our vpn product, we need a xfrm_km in kernel module
> to monitor the xfrm state change.
> thus, the 'acquire' and 'compile_policy' may be NULL.
>
> So I think we should do the check before use it.
>
> V2:
> Align the continuation line according the networking coding style.
>
> V3:
> Add check to prevent un-complete key manager at register time.
>
>   net/xfrm/xfrm_state.c | 3 +++
>   1 file changed, 3 insertions(+)
>
> diff --git a/net/xfrm/xfrm_state.c b/net/xfrm/xfrm_state.c
> index b9c3f9e..178283e 100644
> --- a/net/xfrm/xfrm_state.c
> +++ b/net/xfrm/xfrm_state.c
> @@ -1806,6 +1806,9 @@ static DEFINE_SPINLOCK(xfrm_km_lock);
>
>   int xfrm_register_km(struct xfrm_mgr *km)
>   {
> +	if (km->acquire =3D=3D NULL || km->compile_policy =3D=3D NULL)

"acquire" is a MUST, "compile_policy" is not a necessity.

 From  the fist commit log, you probably add functionality providing SA=
 state changes
in your private key manager, which current implementation does not. May=
be it's worthwhile
to elaborate the missing functionality than add those checking, because=
 both key manage
(pfkeyv2/netlink) in use has "acquire" and "compile_policy" at the same=
 time.



--=20
=E6=B5=AE=E6=B2=89=E9=9A=8F=E6=B5=AA=E5=8F=AA=E8=AE=B0=E4=BB=8A=E6=9C=9D=
=E7=AC=91

--fan
