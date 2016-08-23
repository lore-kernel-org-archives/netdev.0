From: Sergei Shtylyov <sergei.shtylyov-M4DtvfQ/ZS1MRgGoP+s0PdBPR1lH4CV8@public.gmane.org>
Subject: Re: [PATCH 14/20] batman-adv: Place kref_get for
	softif_vlan near use
Date: Tue, 23 Aug 2016 16:20:00 +0300
Message-ID: <39ff1697-a110-ac0e-5fca-26ac559b5291@cogentembedded.com>
References: <20160822135620.15337-1-sw@simonwunderlich.de>
 <20160822135620.15337-15-sw@simonwunderlich.de>
Reply-To: The list for a Better Approach To Mobile Ad-hoc Networking
 <b.a.t.m.a.n-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, b.a.t.m.a.n-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org,
 Marek Lindner <mareklindner-rVWd3aGhH2z5bpWLKbzFeg@public.gmane.org>
To: Simon Wunderlich <sw-2YrNx6rUIHYiY0qSoAWiAoQuADTiUCJX@public.gmane.org>, davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org
Return-path: <b.a.t.m.a.n-bounces-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org>
In-Reply-To: <20160822135620.15337-15-sw-2YrNx6rUIHYiY0qSoAWiAoQuADTiUCJX@public.gmane.org>
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

On 8/22/2016 4:56 PM, Simon Wunderlich wrote:

> From: Sven Eckelmann <sven-KaDOiPu9UxWEi8DpZVb4nw@public.gmane.org>
>
> It is hard to understand why the refcnt is increased when it isn't done
> near the actual place the new reference is used. So using kref_get right
> before the place which requires the reference and in the same function
> helps to avoid accidental problems caused by incorrect reference counting.

     I don't think your boilerplate log works for this patch where you are 
*adding* the ref-counting.

> Signed-off-by: Sven Eckelmann <sven-KaDOiPu9UxWEi8DpZVb4nw@public.gmane.org>
> Signed-off-by: Marek Lindner <mareklindner-rVWd3aGhH2z5bpWLKbzFeg@public.gmane.org>
> Signed-off-by: Simon Wunderlich <sw-2YrNx6rUIHYiY0qSoAWiAoQuADTiUCJX@public.gmane.org>
> ---
>  net/batman-adv/soft-interface.c | 4 ++++
>  1 file changed, 4 insertions(+)
>
> diff --git a/net/batman-adv/soft-interface.c b/net/batman-adv/soft-interface.c
> index e508bf5..49e16b6 100644
> --- a/net/batman-adv/soft-interface.c
> +++ b/net/batman-adv/soft-interface.c
> @@ -594,6 +594,7 @@ int batadv_softif_create_vlan(struct batadv_priv *bat_priv, unsigned short vid)
>  	}
>
>  	spin_lock_bh(&bat_priv->softif_vlan_list_lock);
> +	kref_get(&vlan->refcount);
>  	hlist_add_head_rcu(&vlan->list, &bat_priv->softif_vlan_list);
>  	spin_unlock_bh(&bat_priv->softif_vlan_list_lock);
>
> @@ -604,6 +605,9 @@ int batadv_softif_create_vlan(struct batadv_priv *bat_priv, unsigned short vid)
>  			    bat_priv->soft_iface->dev_addr, vid,
>  			    BATADV_NULL_IFINDEX, BATADV_NO_MARK);
>
> +	/* don't return reference to new softif_vlan */
> +	batadv_softif_vlan_put(vlan);
> +
>  	return 0;
>  }
>

MBR, Sergei
