From: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
Subject: Re: [PATCH net-next 5/6] net: bridge: get msgtype from
 nlmsghdr in mdb ops
Date: Thu, 18 May 2017 18:28:46 +0300
Message-ID: <ee5d9736-72ec-f4fd-8e9b-2c4179687e16@cumulusnetworks.com>
References: <20170517212709.6473-1-vivien.didelot@savoirfairelinux.com>
	<20170517212709.6473-6-vivien.didelot@savoirfairelinux.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "moderated list:ETHERNET BRIDGE" <bridge@lists.linux-foundation.org>,
	kernel@savoirfairelinux.com, linux-kernel@vger.kernel.org,
	"David S. Miller" <davem@davemloft.net>
To: Vivien Didelot <vivien.didelot@savoirfairelinux.com>,
	netdev@vger.kernel.org
Return-path: <bridge-bounces@lists.linux-foundation.org>
In-Reply-To: <20170517212709.6473-6-vivien.didelot@savoirfairelinux.com>
Content-Language: en-US
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

On 5/18/17 12:27 AM, Vivien Didelot wrote:
> Retrieve the message type from the nlmsghdr structure instead of
> hardcoding it in both br_mdb_add and br_mdb_del.
> 
> Signed-off-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
> ---
>   net/bridge/br_mdb.c | 10 ++++++----
>   1 file changed, 6 insertions(+), 4 deletions(-)
> 
> diff --git a/net/bridge/br_mdb.c b/net/bridge/br_mdb.c
> index a72d5e6f339f..d280b20587cb 100644
> --- a/net/bridge/br_mdb.c
> +++ b/net/bridge/br_mdb.c
> @@ -569,6 +569,7 @@ static int br_mdb_add(struct sk_buff *skb, struct nlmsghdr *nlh,
>   	struct net_bridge_port *p;
>   	struct net_bridge_vlan *v;
>   	struct net_bridge *br;
> +	int msgtype = nlh->nlmsg_type;

minor nits:
nlmsg_type is a u16, also please keep the order and arrange these from longest 
to shortest

>   	int err;
>   
>   	err = br_mdb_parse(skb, nlh, &dev, &entry);
> @@ -595,12 +596,12 @@ static int br_mdb_add(struct sk_buff *skb, struct nlmsghdr *nlh,
>   	if (br_vlan_enabled(br) && vg && entry->vid == 0) {
>   		list_for_each_entry(v, &vg->vlan_list, vlist) {
>   			entry->vid = v->vid;
> -			err = __br_mdb_do(p, entry, RTM_NEWMDB);
> +			err = __br_mdb_do(p, entry, msgtype);
>   			if (err)
>   				break;
>   		}
>   	} else {
> -		err = __br_mdb_do(p, entry, RTM_NEWMDB);
> +		err = __br_mdb_do(p, entry, msgtype);
>   	}
>   
>   	return err;
> @@ -677,6 +678,7 @@ static int br_mdb_del(struct sk_buff *skb, struct nlmsghdr *nlh,
>   	struct net_bridge_port *p;
>   	struct net_bridge_vlan *v;
>   	struct net_bridge *br;
> +	int msgtype = nlh->nlmsg_type;

same here

>   	int err;
>   
>   	err = br_mdb_parse(skb, nlh, &dev, &entry);
> @@ -703,12 +705,12 @@ static int br_mdb_del(struct sk_buff *skb, struct nlmsghdr *nlh,
>   	if (br_vlan_enabled(br) && vg && entry->vid == 0) {
>   		list_for_each_entry(v, &vg->vlan_list, vlist) {
>   			entry->vid = v->vid;
> -			err = __br_mdb_do(p, entry, RTM_DELMDB);
> +			err = __br_mdb_do(p, entry, msgtype);
>   			if (err)
>   				break;
>   		}
>   	} else {
> -		err = __br_mdb_do(p, entry, RTM_DELMDB);
> +		err = __br_mdb_do(p, entry, msgtype);
>   	}
>   
>   	return err;
> 
