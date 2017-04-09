From: Vlad Yasevich <vyasevic@redhat.com>
Subject: Re: [PATCH net-next 7/8] rtnetlink: Do not generate notifications for
 NOTIFY_PEERS event
Date: Sat, 8 Apr 2017 21:37:53 -0400
Message-ID: <7a5c0cdd-7d9b-a8e9-a27c-591d165b5ab3@redhat.com>
References: <1491600340-8359-1-git-send-email-dsa@cumulusnetworks.com>
 <1491600340-8359-8-git-send-email-dsa@cumulusnetworks.com>
Reply-To: vyasevic@redhat.com
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net
To: David Ahern <dsa@cumulusnetworks.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:56112 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751610AbdDIBhz (ORCPT <rfc822;netdev@vger.kernel.org>);
        Sat, 8 Apr 2017 21:37:55 -0400
In-Reply-To: <1491600340-8359-8-git-send-email-dsa@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 04/07/2017 05:25 PM, David Ahern wrote:
> NOTIFY_PEERS is an internal event; do not generate userspace
> notifications.

We actually need this event to support macvtap over bonding
as well as to resolve some issues with VMs using a bonded uplink
on the host.

-vlad

> 
> Signed-off-by: David Ahern <dsa@cumulusnetworks.com>
> ---
>  include/uapi/linux/if_link.h | 1 -
>  net/core/rtnetlink.c         | 4 ----
>  2 files changed, 5 deletions(-)
> 
> diff --git a/include/uapi/linux/if_link.h b/include/uapi/linux/if_link.h
> index 4fa3bf3eb21d..8f23e9dde667 100644
> --- a/include/uapi/linux/if_link.h
> +++ b/include/uapi/linux/if_link.h
> @@ -906,7 +906,6 @@ enum {
>  	IFLA_EVENT_CHANGE_NAME,
>  	IFLA_EVENT_FEAT_CHANGE,
>  	IFLA_EVENT_BONDING_FAILOVER,
> -	IFLA_EVENT_NOTIFY_PEERS,
>  	IFLA_EVENT_CHANGE_UPPER,
>  	IFLA_EVENT_RESEND_IGMP,
>  	IFLA_EVENT_CHANGE_LOWER_STATE,
> diff --git a/net/core/rtnetlink.c b/net/core/rtnetlink.c
> index e2b0ec5174e7..d2587aa339c4 100644
> --- a/net/core/rtnetlink.c
> +++ b/net/core/rtnetlink.c
> @@ -1294,9 +1294,6 @@ static int rtnl_fill_link_event(struct sk_buff *skb, unsigned long event)
>  	case NETDEV_BONDING_FAILOVER:
>  		rtnl_event = IFLA_EVENT_BONDING_FAILOVER;
>  		break;
> -	case NETDEV_NOTIFY_PEERS:
> -		rtnl_event = IFLA_EVENT_NOTIFY_PEERS;
> -		break;
>  	case NETDEV_CHANGEUPPER:
>  		rtnl_event = IFLA_EVENT_CHANGE_UPPER;
>  		break;
> @@ -4173,7 +4170,6 @@ static int rtnetlink_event(struct notifier_block *this, unsigned long event, voi
>  	case NETDEV_CHANGENAME:
>  	case NETDEV_FEAT_CHANGE:
>  	case NETDEV_BONDING_FAILOVER:
> -	case NETDEV_NOTIFY_PEERS:
>  	case NETDEV_CHANGEUPPER:
>  	case NETDEV_RESEND_IGMP:
>  	case NETDEV_CHANGELOWERSTATE:
> 
