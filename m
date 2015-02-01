From: Yann Droneaud <ydroneaud-RlY5vtjFyJ3QT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH for-next 02/10] IB/core: Pass network namespace as a
 parameter to relevant functions
Date: Sun, 01 Feb 2015 13:26:50 +0100
Message-ID: <1422793610.3030.39.camel@opteya.com>
References: <1422790133-28725-1-git-send-email-raindel@mellanox.com>
	 <1422790133-28725-3-git-send-email-raindel@mellanox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: roland-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org, sean.hefty-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org,
	linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	liranl-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org, Guy Shapiro <guysh-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
	Haggai Eran <haggaie-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
	Yotam Kenneth <yotamke-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
To: Shachar Raindel <raindel-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1422790133-28725-3-git-send-email-raindel-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Hi,

Le dimanche 01 f=C3=A9vrier 2015 =C3=A0 13:28 +0200, Shachar Raindel a =
=C3=A9crit :
> From: Guy Shapiro <guysh-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
>=20
> Add network namespace parameters for the address related ib_core
> functions. The parameter is passed to lower level function, instead o=
f
> &init_net, so things are done in the correct namespace.
>=20
> For now pass &init_net on every caller.
> Callers that will pass &init_net permanently are marked with an
> appropriate comment.
>=20
> Signed-off-by: Haggai Eran <haggaie-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
> Signed-off-by: Yotam Kenneth <yotamke-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
> Signed-off-by: Shachar Raindel <raindel-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
> Signed-off-by: Guy Shapiro <guysh-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
>=20
> ---
>  drivers/infiniband/core/agent.c       |  4 +++-
>  drivers/infiniband/core/cm.c          |  9 +++++++--
>  drivers/infiniband/core/mad_rmpp.c    | 10 ++++++++--
>  drivers/infiniband/core/user_mad.c    |  4 +++-
>  drivers/infiniband/core/verbs.c       | 10 ++++++----
>  drivers/infiniband/ulp/srpt/ib_srpt.c |  3 ++-
>  include/rdma/ib_verbs.h               | 15 +++++++++++++--
>  7 files changed, 42 insertions(+), 13 deletions(-)

> diff --git a/include/rdma/ib_verbs.h b/include/rdma/ib_verbs.h
> index 0d74f1de99aa..dd4c80cea8d3 100644
> --- a/include/rdma/ib_verbs.h
> +++ b/include/rdma/ib_verbs.h
> @@ -48,6 +48,7 @@
>  #include <linux/rwsem.h>
>  #include <linux/scatterlist.h>
>  #include <linux/workqueue.h>
> +#include <net/net_namespace.h>
>  #include <uapi/linux/if_ether.h>
> =20
>  #include <linux/atomic.h>
> @@ -1801,9 +1802,14 @@ struct ib_ah *ib_create_ah(struct ib_pd *pd, s=
truct ib_ah_attr *ah_attr);
>   *   ignored unless the work completion indicates that the GRH is va=
lid.
>   * @ah_attr: Returned attributes that can be used when creating an a=
ddress
>   *   handle for replying to the message.
> + * @net: The network namespace to use for address resolution.
> + *
> + * It is the caller's responsibility to make sure the network namesp=
ace is
> + * alive until the function returns.

Why ?

>   */
>  int ib_init_ah_from_wc(struct ib_device *device, u8 port_num, struct=
 ib_wc *wc,
> -		       struct ib_grh *grh, struct ib_ah_attr *ah_attr);
> +		       struct ib_grh *grh, struct ib_ah_attr *ah_attr,
> +		       struct net *net);
> =20
>  /**
>   * ib_create_ah_from_wc - Creates an address handle associated with =
the
> @@ -1813,12 +1819,17 @@ int ib_init_ah_from_wc(struct ib_device *devi=
ce, u8 port_num, struct ib_wc *wc,
>   * @grh: References the received global route header.  This paramete=
r is
>   *   ignored unless the work completion indicates that the GRH is va=
lid.
>   * @port_num: The outbound port number to associate with the address=
=2E
> + * @net: The network namespace to use for address resolution.
>   *
>   * The address handle is used to reference a local or global destina=
tion
>   * in all UD QP post sends.
> + *
> + * It is the caller's responsibility to make sure the network namesp=
ace is
> + * alive until the function returns.

Why ?

Regards.

--=20
Yann Droneaud
OPTEYA


--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" i=
n
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
