From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: [PATCH v2 net-next 1/8] bridge: Turn flag change macro
 into a function.
Date: Thu, 15 May 2014 20:18:22 +0300
Message-ID: <20140515171822.GA1699@redhat.com>
References: <1400173016-8952-1-git-send-email-vyasevic@redhat.com>
	<1400173016-8952-2-git-send-email-vyasevic@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: john.r.fastabend@intel.com, netdev@vger.kernel.org, shemminger@vyatta.com,
	bridge@lists.linux-foundation.org, jhs@mojatatu.com
To: Vlad Yasevich <vyasevic@redhat.com>
Return-path: <bridge-bounces@lists.linux-foundation.org>
Content-Disposition: inline
In-Reply-To: <1400173016-8952-2-git-send-email-vyasevic@redhat.com>
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

On Thu, May 15, 2014 at 12:56:49PM -0400, Vlad Yasevich wrote:
> Turn the flag change macro into a function to allow
> easier updates and to reduce space.
> 
> Signed-off-by: Vlad Yasevich <vyasevic@redhat.com>

Acked-by: Michael S. Tsirkin <mst@redhat.com>

whitespace nit below

> ---
>  net/bridge/br_sysfs_if.c | 27 +++++++++++++++++----------
>  1 file changed, 17 insertions(+), 10 deletions(-)
> 
> diff --git a/net/bridge/br_sysfs_if.c b/net/bridge/br_sysfs_if.c
> index dd595bd..112a25e 100644
> --- a/net/bridge/br_sysfs_if.c
> +++ b/net/bridge/br_sysfs_if.c
> @@ -41,20 +41,27 @@ static ssize_t show_##_name(struct net_bridge_port *p, char *buf) \
>  }								\
>  static int store_##_name(struct net_bridge_port *p, unsigned long v) \
>  {								\
> -	unsigned long flags = p->flags;				\
> -	if (v)							\
> -		flags |= _mask;					\
> -	else							\
> -		flags &= ~_mask;				\
> -	if (flags != p->flags) {				\
> -		p->flags = flags;				\
> -		br_ifinfo_notify(RTM_NEWLINK, p);		\
> -	}							\
> -	return 0;						\
> +	return store_flag(p, v, _mask);				\
>  }								\
>  static BRPORT_ATTR(_name, S_IRUGO | S_IWUSR,			\
>  		   show_##_name, store_##_name)
>  
> +static int store_flag(struct net_bridge_port *p, unsigned long v,
> +		     unsigned long mask)

This second line should align "unsigned" with "struct" on the line above
it. As it is it's aligned with (  which violates the docinf style
requirement
	Descendants are always substantially shorter than the parent and
	are placed substantially to the right.
it's not substantially to the right if it's not to the right of (.

> +{
> +	unsigned long flags = p->flags;
> +
> +	if (v)
> +		flags |= mask;
> +	else
> +		flags &= ~mask;
> +
> +	if (flags != p->flags) {
> +		p->flags = flags;
> +		br_ifinfo_notify(RTM_NEWLINK, p);
> +	}
> +	return 0;
> +}
>  
>  static ssize_t show_path_cost(struct net_bridge_port *p, char *buf)
>  {
> -- 
> 1.9.0
