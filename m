From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH net-next] bridge: remove unused variable ifm
Date: Thu, 28 Mar 2013 10:03:44 -0700
Message-ID: <20130328100344.70c78134@nehalam.linuxnetplumber.net>
References: <1364487682-5839-1-git-send-email-honkiko@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, bridge@lists.linux-foundation.org,
	davem@davemloft.net
To: Hong Zhiguo <honkiko@gmail.com>
Return-path: <bridge-bounces@lists.linux-foundation.org>
In-Reply-To: <1364487682-5839-1-git-send-email-honkiko@gmail.com>
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

On Fri, 29 Mar 2013 00:21:22 +0800
Hong Zhiguo <honkiko@gmail.com> wrote:

> Signed-off-by: Hong Zhiguo <honkiko@gmail.com>
> ---
>  net/bridge/br_netlink.c |   12 +++---------
>  1 file changed, 3 insertions(+), 9 deletions(-)
> 
> diff --git a/net/bridge/br_netlink.c b/net/bridge/br_netlink.c
> index b96e02e..8e3abf5 100644
> --- a/net/bridge/br_netlink.c
> +++ b/net/bridge/br_netlink.c
> @@ -352,17 +352,14 @@ static int br_setport(struct net_bridge_port *p, struct nlattr *tb[])
>  /* Change state and parameters on port. */
>  int br_setlink(struct net_device *dev, struct nlmsghdr *nlh)
>  {
> -	struct ifinfomsg *ifm;
>  	struct nlattr *protinfo;
>  	struct nlattr *afspec;
>  	struct net_bridge_port *p;
>  	struct nlattr *tb[IFLA_BRPORT_MAX + 1];
>  	int err = 0;
>  
> -	ifm = nlmsg_data(nlh);
> -
> -	protinfo = nlmsg_find_attr(nlh, sizeof(*ifm), IFLA_PROTINFO);
> -	afspec = nlmsg_find_attr(nlh, sizeof(*ifm), IFLA_AF_SPEC);
> +	protinfo = nlmsg_find_attr(nlh, sizeof(struct ifinfomsg), IFLA_PROTINFO);
> +	afspec = nlmsg_find_attr(nlh, sizeof(struct ifinfomsg), IFLA_AF_SPEC);
>  	if (!protinfo && !afspec)
>  		return 0;
>  
> @@ -411,14 +408,11 @@ out:
>  /* Delete port information */
>  int br_dellink(struct net_device *dev, struct nlmsghdr *nlh)
>  {
> -	struct ifinfomsg *ifm;
>  	struct nlattr *afspec;
>  	struct net_bridge_port *p;
>  	int err;
>  
> -	ifm = nlmsg_data(nlh);
> -
> -	afspec = nlmsg_find_attr(nlh, sizeof(*ifm), IFLA_AF_SPEC);
> +	afspec = nlmsg_find_attr(nlh, sizeof(struct ifinfomsg), IFLA_AF_SPEC);
>  	if (!afspec)
>  		return 0;
>  

Acked-by: Stephen Hemminger <stephen@networkplumber.org>
