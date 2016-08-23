From: Sergei Shtylyov <sergei.shtylyov-M4DtvfQ/ZS1MRgGoP+s0PdBPR1lH4CV8@public.gmane.org>
Subject: Re: [PATCH 18/20] batman-adv: Place kref_get for
 tvlv_handler near use
Date: Tue, 23 Aug 2016 16:36:17 +0300
Message-ID: <8ee11ebe-56e2-5e47-aba9-7564e76440a6@cogentembedded.com>
References: <20160822135620.15337-1-sw@simonwunderlich.de>
 <20160822135620.15337-19-sw@simonwunderlich.de>
Reply-To: The list for a Better Approach To Mobile Ad-hoc Networking
 <b.a.t.m.a.n-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, b.a.t.m.a.n-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org,
 Marek Lindner <mareklindner-rVWd3aGhH2z5bpWLKbzFeg@public.gmane.org>
To: Simon Wunderlich <sw-2YrNx6rUIHYiY0qSoAWiAoQuADTiUCJX@public.gmane.org>, davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org
Return-path: <b.a.t.m.a.n-bounces-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org>
In-Reply-To: <20160822135620.15337-19-sw-2YrNx6rUIHYiY0qSoAWiAoQuADTiUCJX@public.gmane.org>
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

On 8/22/2016 4:56 PM, Simon Wunderlich wrote:

> From: Sven Eckelmann <sven-KaDOiPu9UxWEi8DpZVb4nw@public.gmane.org>
>
> It is hard to understand why the refcnt is increased when it isn't done
> near the actual place the new reference is used. So using kref_get right
> before the place which requires the reference and in the same function
> helps to avoid accidental problems caused by incorrect reference counting.

      Neither does the boilerplate work for this patch...

> Signed-off-by: Sven Eckelmann <sven-KaDOiPu9UxWEi8DpZVb4nw@public.gmane.org>
> Signed-off-by: Marek Lindner <mareklindner-rVWd3aGhH2z5bpWLKbzFeg@public.gmane.org>
> Signed-off-by: Simon Wunderlich <sw-2YrNx6rUIHYiY0qSoAWiAoQuADTiUCJX@public.gmane.org>
> ---
>  net/batman-adv/tvlv.c | 4 ++++
>  1 file changed, 4 insertions(+)
>
> diff --git a/net/batman-adv/tvlv.c b/net/batman-adv/tvlv.c
> index 3533867..77654f0 100644
> --- a/net/batman-adv/tvlv.c
> +++ b/net/batman-adv/tvlv.c
> @@ -547,8 +547,12 @@ void batadv_tvlv_handler_register(struct batadv_priv *bat_priv,
>  	INIT_HLIST_NODE(&tvlv_handler->list);
>
>  	spin_lock_bh(&bat_priv->tvlv.handler_list_lock);
> +	kref_get(&tvlv_handler->refcount);
>  	hlist_add_head_rcu(&tvlv_handler->list, &bat_priv->tvlv.handler_list);
>  	spin_unlock_bh(&bat_priv->tvlv.handler_list_lock);
> +
> +	/* don't return reference to new tvlv_handler */
> +	batadv_tvlv_handler_put(tvlv_handler);
>  }
>
>  /**

MBR, Sergei
