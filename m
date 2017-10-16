From: David Ahern <dsahern@gmail.com>
Subject: Re: [PATCH net 3/6] rtnetlink: bring NETDEV_POST_TYPE_CHANGE event
 process back in rtnetlink_event
Date: Sun, 15 Oct 2017 19:16:16 -0600
Message-ID: <bdf49b12-492c-95e2-a808-ebc7b5d11877@gmail.com>
References: <cover.1508062280.git.lucien.xin@gmail.com>
 <d7713874f0ad1c19b640eaae98f0d554d1743a4c.1508062280.git.lucien.xin@gmail.com>
 <e240a6572c8e495eb2da15bd6178604cdfde08ba.1508062280.git.lucien.xin@gmail.com>
 <b4125c6cf42d4d028a9c04f4989627ac1eb83257.1508062280.git.lucien.xin@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, hannes@stressinduktion.org
To: Xin Long <lucien.xin@gmail.com>,
        network dev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f65.google.com ([74.125.83.65]:48343 "EHLO
        mail-pg0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751607AbdJPBQR (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 15 Oct 2017 21:16:17 -0400
Received: by mail-pg0-f65.google.com with SMTP id v78so5497197pgb.5
        for <netdev@vger.kernel.org>; Sun, 15 Oct 2017 18:16:17 -0700 (PDT)
In-Reply-To: <b4125c6cf42d4d028a9c04f4989627ac1eb83257.1508062280.git.lucien.xin@gmail.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 10/15/17 4:13 AM, Xin Long wrote:
> As I said in patch 'rtnetlink: bring NETDEV_CHANGEMTU event process back
> in rtnetlink_event', removing NETDEV_POST_TYPE_CHANGE event was not the
> right fix for the redundant notifications issue.
> 
> So bring this event process back to rtnetlink_event and the old redundant
> notifications issue would be fixed in the later patch 'rtnetlink: check
> DO_SETLINK_NOTIFY correctly in do_setlink'.
> 
> Fixes: aef091ae58aa ("rtnetlink: Do not generate notifications for POST_TYPE_CHANGE event")
> Signed-off-by: Xin Long <lucien.xin@gmail.com>
> ---
>  net/core/rtnetlink.c | 1 +
>  1 file changed, 1 insertion(+)
> 
> diff --git a/net/core/rtnetlink.c b/net/core/rtnetlink.c
> index bf47360..8e44fd5 100644
> --- a/net/core/rtnetlink.c
> +++ b/net/core/rtnetlink.c
> @@ -4284,6 +4284,7 @@ static int rtnetlink_event(struct notifier_block *this, unsigned long event, voi
>  	case NETDEV_CHANGENAME:
>  	case NETDEV_FEAT_CHANGE:
>  	case NETDEV_BONDING_FAILOVER:
> +	case NETDEV_POST_TYPE_CHANGE:
>  	case NETDEV_NOTIFY_PEERS:
>  	case NETDEV_RESEND_IGMP:
>  	case NETDEV_CHANGEINFODATA:
> 

Acked-by: David Ahern <dsahern@gmail.com>
