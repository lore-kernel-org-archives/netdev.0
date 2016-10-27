From: Wengang <wen.gang.wang@oracle.com>
Subject: Re: [PATCH RDS v1] rds: debug messages are enabled by default
Date: Thu, 27 Oct 2016 09:01:02 -0700
Message-ID: <386fbffd-fe27-c37d-aca8-c04a7a803786@oracle.com>
References: <1477561598-20186-1-git-send-email-shamir.rabinovitch@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: santosh.shilimkar@oracle.com, davem@davemloft.net
To: shamir.rabinovitch@oracle.com, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from userp1040.oracle.com ([156.151.31.81]:38872 "EHLO
        userp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753982AbcJ0QBF (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 27 Oct 2016 12:01:05 -0400
In-Reply-To: <1477561598-20186-1-git-send-email-shamir.rabinovitch@oracle.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Reviewed-by: Wengang Wang <wen.gang.wang@oracle.com>

thanks,

wengang


On 10/27/2016 2:46 AM, shamir.rabinovitch@oracle.com wrote:
> From: shamir rabinovitch <shamir.rabinovitch@oracle.com>
>
> rds use Kconfig option called "RDS_DEBUG" to enable rds debug messages.
> This option cause the rds Makefile to add -DDEBUG to the rds gcc command
> line.
>
> When CONFIG_DYNAMIC_DEBUG is enabled, the "DEBUG" macro is used by
> include/linux/dynamic_debug.h to decide if dynamic debug prints should
> be sent by default to the kernel log.
>
> rds should not enable this macro for production builds. rds dynamic
> debug work as expected follow this fix.
>
> Signed-off-by: Shamir Rabinovitch <shamir.rabinovitch@oracle.com>
> ---
>   net/rds/Makefile |    2 +-
>   net/rds/rds.h    |    2 +-
>   2 files changed, 2 insertions(+), 2 deletions(-)
>
> diff --git a/net/rds/Makefile b/net/rds/Makefile
> index 0e72bec..56c7d27 100644
> --- a/net/rds/Makefile
> +++ b/net/rds/Makefile
> @@ -13,5 +13,5 @@ obj-$(CONFIG_RDS_TCP) += rds_tcp.o
>   rds_tcp-y :=		tcp.o tcp_connect.o tcp_listen.o tcp_recv.o \
>   			tcp_send.o tcp_stats.o
>   
> -ccflags-$(CONFIG_RDS_DEBUG)	:=	-DDEBUG
> +ccflags-$(CONFIG_RDS_DEBUG)	:=	-DRDS_DEBUG
>   
> diff --git a/net/rds/rds.h b/net/rds/rds.h
> index 25532a4..4121e18 100644
> --- a/net/rds/rds.h
> +++ b/net/rds/rds.h
> @@ -33,7 +33,7 @@
>   #define KERNEL_HAS_ATOMIC64
>   #endif
>   
> -#ifdef DEBUG
> +#ifdef RDS_DEBUG
>   #define rdsdebug(fmt, args...) pr_debug("%s(): " fmt, __func__ , ##args)
>   #else
>   /* sigh, pr_debug() causes unused variable warnings */
