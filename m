From: Vlad Yasevich <vyasevic@redhat.com>
Subject: Re: [PATCH] rtnetlink: rtnl_bridge_getlink: Call
 nlmsg_find_attr() with ifinfomsg header
Date: Mon, 12 Aug 2013 15:57:29 -0400
Message-ID: <52093E29.5010604@redhat.com>
References: <52090C26.4090001@fiberby.net>
	<1376325009-8399-1-git-send-email-ast@fiberby.net>
Reply-To: vyasevic@redhat.com
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Stephen Hemminger <stephen@networkplumber.org>, netdev@vger.kernel.org,
	bridge@lists.linux-foundation.org, "David S. Miller" <davem@davemloft.net>,
	linux-kernel@vger.kernel.org
To: Asbjoern Sloth Toennesen <ast@fiberby.net>
Return-path: <bridge-bounces@lists.linux-foundation.org>
In-Reply-To: <1376325009-8399-1-git-send-email-ast@fiberby.net>
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

On 08/12/2013 12:30 PM, Asbjoern Sloth Toennesen wrote:
> Fix the iproute2 command `bridge vlan show`, after switching from
> rtgenmsg to ifinfomsg.
>
> Signed-off-by: Asbjoern Sloth Toennesen <ast@fiberby.net>


Thanks..  I've still been using an older iproute version and didn't see 
this.


Reviewed-by: Vlad Yasevich <vyasevich@gmail.com>
> ---
>   net/core/rtnetlink.c | 2 +-
>   1 file changed, 1 insertion(+), 1 deletion(-)
>
> diff --git a/net/core/rtnetlink.c b/net/core/rtnetlink.c
> index 3de7408..a043171 100644
> --- a/net/core/rtnetlink.c
> +++ b/net/core/rtnetlink.c
> @@ -2384,7 +2384,7 @@ static int rtnl_bridge_getlink(struct sk_buff *skb, struct netlink_callback *cb)
>   	struct nlattr *extfilt;
>   	u32 filter_mask = 0;
>
> -	extfilt = nlmsg_find_attr(cb->nlh, sizeof(struct rtgenmsg),
> +	extfilt = nlmsg_find_attr(cb->nlh, sizeof(struct ifinfomsg),
>   				  IFLA_EXT_MASK);
>   	if (extfilt)
>   		filter_mask = nla_get_u32(extfilt);
>
