From: Toshiaki Makita <makita.toshiaki@lab.ntt.co.jp>
Subject: Re: [PATCH net-next] bridge: Add netlink support for
 vlan_protocol attribute
Date: Thu, 27 Aug 2015 15:22:45 +0900
Message-ID: <55DEACB5.9050105@lab.ntt.co.jp>
References: <1440655205-14247-1-git-send-email-makita.toshiaki@lab.ntt.co.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-2022-jp
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, bridge@lists.linux-foundation.org
To: "David S . Miller" <davem@davemloft.net>,
	Stephen Hemminger <stephen@networkplumber.org>
Return-path: <bridge-bounces@lists.linux-foundation.org>
In-Reply-To: <1440655205-14247-1-git-send-email-makita.toshiaki@lab.ntt.co.jp>
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

On 2015/08/27 15:00, Toshiaki Makita wrote:
> This enables bridge vlan_protocol to be configured through netlink.
> 
> When CONFIG_BRIDGE_VLAN_FILTERING is disabled, kernel behaves the
> same way as this feature is not implemented.
> 
> Signed-off-by: Toshiaki Makita <makita.toshiaki@lab.ntt.co.jp>
> ---
...
>  static int br_changelink(struct net_device *brdev, struct nlattr *tb[],
> @@ -784,6 +800,16 @@ static int br_changelink(struct net_device *brdev, struct nlattr *tb[],
>  			return err;
>  	}
>  
> +#ifdef CONFIG_BRIDGE_VLAN_FILTERING
> +	if (data[IFLA_BR_VLAN_PROTOCOL]) {
> +		u16 vlan_proto = nla_get_be16(data[IFLA_BR_VLAN_PROTOCOL]);

This u16 should have been __be16...
Sorry, will send v2.

Toshiaki Makita
