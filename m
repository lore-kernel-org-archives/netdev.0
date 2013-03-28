From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [PATCH 4/6] gdm72xx: replace obsolete NLMSG_* with type safe
 nlmsg_*
Date: Thu, 28 Mar 2013 14:37:09 +0000
Message-ID: <20130328143709.GE23043@casper.infradead.org>
References: <1364403137-32806-1-git-send-email-honkiko@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	davem@davemloft.net
To: Hong Zhiguo <honkiko@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1364403137-32806-1-git-send-email-honkiko@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 03/28/13 at 12:52am, Hong Zhiguo wrote:
> Signed-off-by: Hong Zhiguo <honkiko@gmail.com>
> ---
>  drivers/staging/gdm72xx/netlink_k.c |   12 ++++++------
>  1 file changed, 6 insertions(+), 6 deletions(-)
> 
> diff --git a/drivers/staging/gdm72xx/netlink_k.c b/drivers/staging/gdm72xx/netlink_k.c
> index 52c25ba..c1239aa 100644
> --- a/drivers/staging/gdm72xx/netlink_k.c
> +++ b/drivers/staging/gdm72xx/netlink_k.c
> @@ -25,12 +25,12 @@
>  
>  #define ND_MAX_GROUP			30
>  #define ND_IFINDEX_LEN			sizeof(int)
> -#define ND_NLMSG_SPACE(len)		(NLMSG_SPACE(len) + ND_IFINDEX_LEN)
> +#define ND_NLMSG_SPACE(len)		(nlmsg_total_size(len) + ND_IFINDEX_LEN)
>  #define ND_NLMSG_DATA(nlh) \
> -	((void *)((char *)NLMSG_DATA(nlh) + ND_IFINDEX_LEN))
> +	((void *)((char *)nlmsg_data(nlh) + ND_IFINDEX_LEN))
>  #define ND_NLMSG_S_LEN(len)		(len+ND_IFINDEX_LEN)
>  #define ND_NLMSG_R_LEN(nlh)		(nlh->nlmsg_len-ND_IFINDEX_LEN)
> -#define ND_NLMSG_IFIDX(nlh)		NLMSG_DATA(nlh)
> +#define ND_NLMSG_IFIDX(nlh)		nlmsg_data(nlh)
>  #define ND_MAX_MSG_LEN			8096

This is not pretty at all but outside of the context of your patch.

Acked-by: Thomas Graf <tgraf@suug.ch>
