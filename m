From: Pravin Shelar <pshelar-l0M0P4e3n4LQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH] openvswitch: Use IS_ERR_OR_NULL
Date: Mon, 28 Jul 2014 13:37:09 -0700
Message-ID: <CALnjE+pjdWLCKya6FeqfZqYra=p=vjDN2nywrdTWuRErGmpu9w@mail.gmail.com>
References: <20140727070746.GA4825@himangi-Dell>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: "dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org" <dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>,
 netdev <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, Julia Lawall <julia.lawall-L2FTfq7BK8M@public.gmane.org>,
 "David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>, LKML <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: Himangi Saraogi <himangi774-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Return-path: <dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>
In-Reply-To: <20140727070746.GA4825@himangi-Dell>
List-Unsubscribe: <http://openvswitch.org/mailman/options/dev>,
 <mailto:dev-request-yBygre7rU0TnMu66kgdUjQ@public.gmane.org?subject=unsubscribe>
List-Archive: <http://openvswitch.org/pipermail/dev>
List-Post: <mailto:dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>
List-Help: <mailto:dev-request-yBygre7rU0TnMu66kgdUjQ@public.gmane.org?subject=help>
List-Subscribe: <http://openvswitch.org/mailman/listinfo/dev>,
 <mailto:dev-request-yBygre7rU0TnMu66kgdUjQ@public.gmane.org?subject=subscribe>
Errors-To: dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org
Sender: "dev" <dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>
List-Id: netdev.vger.kernel.org

On Sun, Jul 27, 2014 at 12:07 AM, Himangi Saraogi <himangi774-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org> wrote:
> This patch introduces the use of the macro IS_ERR_OR_NULL in place of
> tests for NULL and IS_ERR.
>
> The following Coccinelle semantic patch was used for making the change:
>
> @@
> expression e;
> @@
>
> - e == NULL || IS_ERR(e)
> + IS_ERR_OR_NULL(e)
>  || ...
>
> Signed-off-by: Himangi Saraogi <himangi774-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
> Acked-by: Julia Lawall <julia.lawall-L2FTfq7BK8M@public.gmane.org>

Looks good.
Acked-by: Pravin B Shelar <pshelar-l0M0P4e3n4LQT0dZR+AlfA@public.gmane.org>

> ---
>  net/openvswitch/datapath.c | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
>
> diff --git a/net/openvswitch/datapath.c b/net/openvswitch/datapath.c
> index 20f59b6..e3b3c21 100644
> --- a/net/openvswitch/datapath.c
> +++ b/net/openvswitch/datapath.c
> @@ -780,7 +780,7 @@ static struct sk_buff *ovs_flow_cmd_build_info(const struct sw_flow *flow,
>
>         skb = ovs_flow_cmd_alloc_info(ovsl_dereference(flow->sf_acts), info,
>                                       always);
> -       if (!skb || IS_ERR(skb))
> +       if (IS_ERR_OR_NULL(skb))
>                 return skb;
>
>         retval = ovs_flow_cmd_fill_info(flow, dp_ifindex, skb,
> --
> 1.9.1
>
