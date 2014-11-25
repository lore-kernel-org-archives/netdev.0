From: Andy Gospodarek <gospo@cumulusnetworks.com>
Subject: Re: [patch net-next v3 01/17] bridge: rename fdb_*_hw to
 fdb_*_hw_addr to avoid confusion
Date: Tue, 25 Nov 2014 10:03:51 -0500
Message-ID: <20141125150351.GB27416@gospo.rtplab.test>
References: <1416911328-10979-1-git-send-email-jiri@resnulli.us>
 <1416911328-10979-2-git-send-email-jiri@resnulli.us>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, davem@davemloft.net, nhorman@tuxdriver.com,
	andy@greyhouse.net, tgraf@suug.ch, dborkman@redhat.com,
	ogerlitz@mellanox.com, jesse@nicira.com, pshelar@nicira.com,
	azhou@nicira.com, ben@decadent.org.uk, stephen@networkplumber.org,
	jeffrey.t.kirsher@intel.com, vyasevic@redhat.com,
	xiyou.wangcong@gmail.com, john.r.fastabend@intel.com,
	edumazet@google.com, jhs@mojatatu.com, sfeldma@gmail.com,
	f.fainelli@gmail.com, roopa@cumulusnetworks.com,
	linville@tuxdriver.com, jasowang@redhat.com, ebiederm@xmission.com,
	nicolas.dichtel@6wind.com, ryazanov.s.a@gmail.com,
	buytenh@wantstofly.org, aviadr@mellanox.com, nbd@openwrt.org,
	alexei.starovoitov@gmail.com, Neil.Jerram@metaswitch.com,
	ronye@mellanox.com, simon.horman@netronome.com,
	alexander.h.duyck@redhat.com, john.ronciak@intel.com,
	mleitner@redhat.com, shrijeet@gmail.com, bcrl@kvack.org
To: Jiri Pirko <jiri@resnulli.us>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ext3.cumulusnetworks.com ([198.211.106.187]:35954 "EHLO
	ext3.cumulusnetworks.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750781AbaKYPEA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 25 Nov 2014 10:04:00 -0500
Content-Disposition: inline
In-Reply-To: <1416911328-10979-2-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Nov 25, 2014 at 11:28:32AM +0100, Jiri Pirko wrote:
> The current name might seem that this actually offloads the fdb entry to
> hw. So rename it to clearly present that this for hardware address
> addition/removal.
> 
> Signed-off-by: Jiri Pirko <jiri@resnulli.us>

Acked-by: Andy Gospodarek <gospo@cumulusnetworks.com>

> ---
> new in v2 as suggested by DaveM
> v2->v3:
> -moved the patch to the patchset head
> ---
>  net/bridge/br_fdb.c | 14 +++++++-------
>  1 file changed, 7 insertions(+), 7 deletions(-)
> 
> diff --git a/net/bridge/br_fdb.c b/net/bridge/br_fdb.c
> index 6f6c95c..08ef4e7 100644
> --- a/net/bridge/br_fdb.c
> +++ b/net/bridge/br_fdb.c
> @@ -90,7 +90,7 @@ static void fdb_rcu_free(struct rcu_head *head)
>   * are then updated with the new information.
>   * Called under RTNL.
>   */
> -static void fdb_add_hw(struct net_bridge *br, const unsigned char *addr)
> +static void fdb_add_hw_addr(struct net_bridge *br, const unsigned char *addr)
>  {
>  	int err;
>  	struct net_bridge_port *p;
> @@ -118,7 +118,7 @@ undo:
>   * the ports with needed information.
>   * Called under RTNL.
>   */
> -static void fdb_del_hw(struct net_bridge *br, const unsigned char *addr)
> +static void fdb_del_hw_addr(struct net_bridge *br, const unsigned char *addr)
>  {
>  	struct net_bridge_port *p;
>  
> @@ -133,7 +133,7 @@ static void fdb_del_hw(struct net_bridge *br, const unsigned char *addr)
>  static void fdb_delete(struct net_bridge *br, struct net_bridge_fdb_entry *f)
>  {
>  	if (f->is_static)
> -		fdb_del_hw(br, f->addr.addr);
> +		fdb_del_hw_addr(br, f->addr.addr);
>  
>  	hlist_del_rcu(&f->hlist);
>  	fdb_notify(br, f, RTM_DELNEIGH);
> @@ -514,7 +514,7 @@ static int fdb_insert(struct net_bridge *br, struct net_bridge_port *source,
>  		return -ENOMEM;
>  
>  	fdb->is_local = fdb->is_static = 1;
> -	fdb_add_hw(br, addr);
> +	fdb_add_hw_addr(br, addr);
>  	fdb_notify(br, fdb, RTM_NEWNEIGH);
>  	return 0;
>  }
> @@ -754,19 +754,19 @@ static int fdb_add_entry(struct net_bridge_port *source, const __u8 *addr,
>  			fdb->is_local = 1;
>  			if (!fdb->is_static) {
>  				fdb->is_static = 1;
> -				fdb_add_hw(br, addr);
> +				fdb_add_hw_addr(br, addr);
>  			}
>  		} else if (state & NUD_NOARP) {
>  			fdb->is_local = 0;
>  			if (!fdb->is_static) {
>  				fdb->is_static = 1;
> -				fdb_add_hw(br, addr);
> +				fdb_add_hw_addr(br, addr);
>  			}
>  		} else {
>  			fdb->is_local = 0;
>  			if (fdb->is_static) {
>  				fdb->is_static = 0;
> -				fdb_del_hw(br, addr);
> +				fdb_del_hw_addr(br, addr);
>  			}
>  		}
>  
> -- 
> 1.9.3
> 
