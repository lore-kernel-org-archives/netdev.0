From: Ivan Vecera <ivecera@redhat.com>
Subject: Re: [PATCH net-next v3 1/9] net: switchdev: add SET_SWITCHDEV_OPS
 helper
Date: Fri, 30 Jun 2017 16:03:54 +0200
Message-ID: <82c7f448-4390-70d4-4c55-9a5e6b0bda55@redhat.com>
References: <1498766899-30707-1-git-send-email-simon.horman@netronome.com>
 <1498766899-30707-2-git-send-email-simon.horman@netronome.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, oss-drivers@netronome.com,
        Or Gerlitz <gerlitz.or@gmail.com>,
        Pieter Jansen van Vuuren
        <pieter.jansenvanvuuren@netronome.com>
To: Simon Horman <simon.horman@netronome.com>,
        David Miller <davem@davemloft.net>,
        Jakub Kicinski <jakub.kicinski@netronome.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:46552 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752038AbdF3OD6 (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 30 Jun 2017 10:03:58 -0400
In-Reply-To: <1498766899-30707-2-git-send-email-simon.horman@netronome.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 29.6.2017 22:08, Simon Horman wrote:
> Add a helper to allow switchdev ops to be set if NET_SWITCHDEV is configured
> and do nothing otherwise. This allows for slightly cleaner code which
> uses switchdev but does not select NET_SWITCHDEV.
> 
> Signed-off-by: Simon Horman <simon.horman@netronome.com>
> ---
>  include/net/switchdev.h | 4 ++++
>  1 file changed, 4 insertions(+)
> 
> diff --git a/include/net/switchdev.h b/include/net/switchdev.h
> index c784a6ac6ef1..8ae9e3b6392e 100644
> --- a/include/net/switchdev.h
> +++ b/include/net/switchdev.h
> @@ -217,6 +217,8 @@ void switchdev_port_fwd_mark_set(struct net_device *dev,
>  
>  bool switchdev_port_same_parent_id(struct net_device *a,
>  				   struct net_device *b);
> +
> +#define SWITCHDEV_SET_OPS(netdev, ops) ((netdev)->switchdev_ops = (ops))
>  #else
>  
>  static inline void switchdev_deferred_process(void)
> @@ -322,6 +324,8 @@ static inline bool switchdev_port_same_parent_id(struct net_device *a,
>  	return false;
>  }
>  
> +#define SWITCHDEV_SET_OPS(netdev, ops) do {} while (0)
> +
>  #endif
>  
>  #endif /* _LINUX_SWITCHDEV_H_ */
> 

Acked-by: Ivan Vecera <ivecera@redhat.com>
