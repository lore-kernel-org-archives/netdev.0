From: Sergei Shtylyov <sergei.shtylyov-M4DtvfQ/ZS1MRgGoP+s0PdBPR1lH4CV8@public.gmane.org>
Subject: Re: [PATCH net 1/1] net: batman-adv: Treat
 NET_XMIT_CN as transmit successfully
Date: Mon, 21 Nov 2016 13:44:47 +0300
Message-ID: <850ff61e-8f94-9316-ed1f-c7d3e8faf95b@cogentembedded.com>
References: <1479688779-1328-1-git-send-email-fgao@ikuai8.com>
Reply-To: The list for a Better Approach To Mobile Ad-hoc Networking
 <b.a.t.m.a.n-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
To: fgao-KlmEoCYek3zQT0dZR+AlfA@public.gmane.org, mareklindner-rVWd3aGhH2z5bpWLKbzFeg@public.gmane.org, sw-2YrNx6rUIHYiY0qSoAWiAoQuADTiUCJX@public.gmane.org,
 a@unstable.cc, davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org, b.a.t.m.a.n-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org,
 netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, gfree.wind-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org
Return-path: <b.a.t.m.a.n-bounces-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org>
In-Reply-To: <1479688779-1328-1-git-send-email-fgao-KlmEoCYek3zQT0dZR+AlfA@public.gmane.org>
List-Unsubscribe: <https://lists.open-mesh.org/mm/options/b.a.t.m.a.n>,
 <mailto:b.a.t.m.a.n-request-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.open-mesh.org/pipermail/b.a.t.m.a.n/>
List-Post: <mailto:b.a.t.m.a.n-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org>
List-Help: <mailto:b.a.t.m.a.n-request-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org?subject=help>
List-Subscribe: <https://lists.open-mesh.org/mm/listinfo/b.a.t.m.a.n>,
 <mailto:b.a.t.m.a.n-request-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org?subject=subscribe>
Errors-To: b.a.t.m.a.n-bounces-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org
Sender: "B.A.T.M.A.N" <b.a.t.m.a.n-bounces-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org>
List-Id: netdev.vger.kernel.org

Hello.

On 11/21/2016 3:39 AM, fgao-KlmEoCYek3zQT0dZR+AlfA@public.gmane.org wrote:

> From: Gao Feng <fgao-KlmEoCYek3zQT0dZR+AlfA@public.gmane.org>
>
> The tc could return NET_XMIT_CN as one congestion notification, but
> it does not mean the packe is lost. Other modules like ipvlan,

    Packet.

> macvlan, and others treat NET_XMIT_CN as success too.
>
> So batman-adv should add the NET_XMIT_CN check.
>
> Signed-off-by: Gao Feng <fgao-KlmEoCYek3zQT0dZR+AlfA@public.gmane.org>

[...]

> diff --git a/net/batman-adv/routing.c b/net/batman-adv/routing.c
> index 7e8dc64..8edd324 100644
> --- a/net/batman-adv/routing.c
> +++ b/net/batman-adv/routing.c
> @@ -706,7 +706,7 @@ static int batadv_route_unicast_packet(struct sk_buff *skb,
>  		goto out;
>
>  	/* translate transmit result into receive result */
> -	if (res == NET_XMIT_SUCCESS) {
> +	if (res == NET_XMIT_SUCCESS || ret == NET_XMIT_CN) {

    Not 'res == NET_XMIT_CN'?

>  		/* skb was transmitted and consumed */
>  		batadv_inc_counter(bat_priv, BATADV_CNT_FORWARD);
>  		batadv_add_counter(bat_priv, BATADV_CNT_FORWARD_BYTES,
[...]

MBR, Sergei
