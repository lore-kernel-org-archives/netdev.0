From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [RFC PATCH net-next] ppp: Allow ppp device connected to an l2tp
 session to change of namespace
Date: Thu, 24 Oct 2013 18:23:14 +0400
Message-ID: <52692D52.8090503@cogentembedded.com>
References: <5268F6CD.9070600@alphalink.fr>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, linux-ppp@vger.kernel.org
To: =?UTF-8?B?RnJhbsOnb2lzIENhY2hlcmV1bA==?= <f.cachereul@alphalink.fr>,
	Paul Mackerras <paulus@samba.org>,
	James Chapman <jchapman@katalix.com>
Return-path: <linux-ppp-owner@vger.kernel.org>
In-Reply-To: <5268F6CD.9070600@alphalink.fr>
Sender: linux-ppp-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello.

On 10/24/2013 02:30 PM, Fran=C3=A7ois Cachereul wrote:

> Remove NETIF_F_NETNS_LOCAL flag from ppp device in ppp_connect_channe=
l()
> if the device is connected to a l2tp session socket.
> Restore the flag in ppp_disconnect_channel().

> Signed-off-by: Fran=C3=A7ois CACHEREUL <f.cachereul@alphalink.fr>
> ---
> I'm trying to get rid of this flag for ppp device connected to l2tp
> session, it's seem to be safe to do it for as l2tp_ppp module hasn't =
any
> reference to the ppp device except to the device name. We can probabl=
y
> do it for others modules but pppoe and pptp will require more work.

> I remove the flag for l2tp in ppp_generic.c because I couldn't find a
> place like a callback to do it in l2tp_ppp.c. The best will be to
> remove the flag for all ppp devices.

> Fran=C3=A7ois

>   drivers/net/ppp/ppp_generic.c |   11 +++++++++++
>   1 file changed, 11 insertions(+)

> diff --git a/drivers/net/ppp/ppp_generic.c b/drivers/net/ppp/ppp_gene=
ric.c
> index 72ff14b..7ccf2ae 100644
> --- a/drivers/net/ppp/ppp_generic.c
> +++ b/drivers/net/ppp/ppp_generic.c
[...]
> @@ -2883,6 +2886,13 @@ ppp_connect_channel(struct channel *pch, int u=
nit)
>   	++ppp->n_channels;
>   	pch->ppp =3D ppp;
>   	atomic_inc(&ppp->file.refcnt);
> +
> +	/* allow ppp net device to be moved in another network namespace
> +	 * if it's connected to an l2tp session */

    Acording to Documentation/CodingStyle, the preferred comment style =
in the=20
networking code is:

/* bla
  * bla
  */

WBR, Sergei

