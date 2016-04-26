From: Sergei Shtylyov <sergei.shtylyov-M4DtvfQ/ZS1MRgGoP+s0PdBPR1lH4CV8@public.gmane.org>
Subject: Re: [PATCH 4/5] batman-adv: Reduce refcnt of removed
 router when updating route
Date: Tue, 26 Apr 2016 17:42:54 +0300
Message-ID: <83cedcb0-1090-2a0d-f3b8-c9c273c5f1d2@cogentembedded.com>
References: <1461641239-7097-1-git-send-email-a@unstable.cc>
 <1461641239-7097-5-git-send-email-a@unstable.cc>
Reply-To: The list for a Better Approach To Mobile Ad-hoc Networking
 <b.a.t.m.a.n-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, b.a.t.m.a.n-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org,
 Marek Lindner <mareklindner-rVWd3aGhH2z5bpWLKbzFeg@public.gmane.org>
To: Antonio Quartulli <a@unstable.cc>, davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org
Return-path: <b.a.t.m.a.n-bounces-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org>
In-Reply-To: <1461641239-7097-5-git-send-email-a-2CpIooy/SPIKlTDg6p0iyA@public.gmane.org>
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

On 4/26/2016 6:27 AM, Antonio Quartulli wrote:

> From: Sven Eckelmann <sven-KaDOiPu9UxWEi8DpZVb4nw@public.gmane.org>
>
> _batadv_update_route rcu_derefences orig_ifinfo->router outside of a
> spinlock protected region to print some information messages to the debug
> log. But this pointer is not checked again when the new pointer is assigned
> in the spinlock protected region. Thus is can happen that the value of

    Thus is can? :-)

> orig_ifinfo->router changed in the meantime and thus the reference counter
> of the wrong router gets reduced after the spinlock protected region.
>
> Just rcu_dereferencing the value of orig_ifinfo->router inside the spinlock
> protected region (which also set the new pointer) is enough to get the
> correct old router object.
>
> Fixes: e1a5382f978b ("batman-adv: Make orig_node->router an rcu protected pointer")
> Signed-off-by: Sven Eckelmann <sven-KaDOiPu9UxWEi8DpZVb4nw@public.gmane.org>
> Signed-off-by: Marek Lindner <mareklindner-rVWd3aGhH2z5bpWLKbzFeg@public.gmane.org>
> Signed-off-by: Antonio Quartulli <a@unstable.cc>
> ---
>  net/batman-adv/routing.c | 9 +++++++++
>  1 file changed, 9 insertions(+)
>
> diff --git a/net/batman-adv/routing.c b/net/batman-adv/routing.c
> index 4dd646a52f1a..b781bf753250 100644
> --- a/net/batman-adv/routing.c
> +++ b/net/batman-adv/routing.c
> @@ -105,6 +105,15 @@ static void _batadv_update_route(struct batadv_priv *bat_priv,
>  		neigh_node = NULL;
>
>  	spin_lock_bh(&orig_node->neigh_list_lock);
> +	/* curr_router used earlier may not be the current orig_ifinfo->router
> +	 * anymore because it was dereferenced outside of the neigh_list_lock
> +	 * protected region. After the new best neighbor has replace the current

    Replaced.

[...]

MBR, Sergei
