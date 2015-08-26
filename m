From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH net-next v2] bridge: vlan: allow to suppress
 local mac install for all vlans
Date: Tue, 25 Aug 2015 17:58:20 -0700
Message-ID: <20150825175820.0b0538c1@urahara>
References: <1440549295-3979-1-git-send-email-razor@blackwall.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: vyasevic@redhat.com, bridge@lists.linux-foundation.org,
	Nikolay Aleksandrov <nikolay@cumulusnetworks.com>,
	netdev@vger.kernel.org, wkok@cumulusnetworks.com, davem@davemloft.net
To: Nikolay Aleksandrov <razor@blackwall.org>
Return-path: <bridge-bounces@lists.linux-foundation.org>
In-Reply-To: <1440549295-3979-1-git-send-email-razor@blackwall.org>
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

On Tue, 25 Aug 2015 17:34:55 -0700
Nikolay Aleksandrov <razor@blackwall.org> wrote:

> diff --git a/net/bridge/br_private.h b/net/bridge/br_private.h
> index 3d95647039d0..2bda472c5a6e 100644
> --- a/net/bridge/br_private.h
> +++ b/net/bridge/br_private.h
> @@ -294,6 +294,7 @@ struct net_bridge
>  	u32				auto_cnt;
>  #ifdef CONFIG_BRIDGE_VLAN_FILTERING
>  	u8				vlan_enabled;
> +	bool				vlan_ignore_local_fdb;

bool takes more space than u8.


>  	__be16				vlan_proto;
>  	u16				default_pvid;
>  	struct net_port_vlans __rcu	*vlan_info;

> +int br_vlan_ignore_local_fdb_toggle(struct net_bridge *br, unsigned long val)
> +{
> +	br->vlan_ignore_local_fdb = val ? true : false;

personal preference is for:
	br->vlan_ignore_local_fdb = !!val;
