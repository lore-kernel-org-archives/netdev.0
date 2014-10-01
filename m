From: Toshiaki Makita <makita.toshiaki@lab.ntt.co.jp>
Subject: Re: [PATCH v2 net 2/3] bridge: Simplify pvid checks.
Date: Wed, 01 Oct 2014 15:50:01 +0900
Message-ID: <542BA419.9000502@lab.ntt.co.jp>
References: <1412105462-340-1-git-send-email-vyasevic@redhat.com>
	<1412105462-340-3-git-send-email-vyasevic@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-2022-jp
Content-Transfer-Encoding: 7bit
Cc: stephen@networkplumber.org, bridge@lists.linux-foundation.org,
	Vladislav Yasevich <vyasevic@redhat.com>
To: Vladislav Yasevich <vyasevich@gmail.com>, netdev@vger.kernel.org
Return-path: <bridge-bounces@lists.linux-foundation.org>
In-Reply-To: <1412105462-340-3-git-send-email-vyasevic@redhat.com>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/bridge>,
	<mailto:bridge-request@lists.linux-foundation.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/bridge/>
List-Post: <mailto:bridge@lists.linux-foundation.org>
List-Help: <mailto:bridge-request@lists.linux-foundation.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/bridge>,
	<mailto:bridge-request@lists.linux-foundation.org?subject=subscribe>
Sender: bridge-bounces@lists.linux-foundation.org
Errors-To: bridge-bounces@lists.linux-foundation.org
List-Id: netdev.vger.kernel.org

On 2014/10/01 4:31, Vladislav Yasevich wrote:
> Currently, if the pvid is not set, we return an illegal vlan value
> even though the pvid value is set to 0.  Since pvid of 0 is currently
> invalid, just return 0 instead.  This makes the current and future
> checks simpler.
> 
> Signed-off-by: Vladislav Yasevich <vyasevic@redhat.com>
> ---
>  net/bridge/br_private.h | 2 +-
>  net/bridge/br_vlan.c    | 4 ++--
>  2 files changed, 3 insertions(+), 3 deletions(-)
> 
> diff --git a/net/bridge/br_private.h b/net/bridge/br_private.h
> index 6fe8680..873d9da 100644
> --- a/net/bridge/br_private.h
> +++ b/net/bridge/br_private.h
> @@ -647,7 +647,7 @@ static inline u16 br_get_pvid(const struct net_port_vlans *v)
>  	 * vid wasn't set
>  	 */

The comment above should be changed as well.

>  	smp_rmb();
> -	return v->pvid ?: VLAN_N_VID;
> +	return v->pvid;
>  }

Should fix br_get_pvid() when CONFIG_BRIDGE_VLAN_FILTERING=n?
It returns VLAN_N_VID, which might be confusing.

Thanks,
Toshiaki Makita
