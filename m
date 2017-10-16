From: David Ahern <dsahern@gmail.com>
Subject: Re: [PATCH net 6/6] rtnetlink: do not set notification for
 tx_queue_len in do_setlink
Date: Sun, 15 Oct 2017 19:17:38 -0600
Message-ID: <f3d4667b-5f43-2a6b-b5e5-67f748ab2cd9@gmail.com>
References: <cover.1508062280.git.lucien.xin@gmail.com>
 <d7713874f0ad1c19b640eaae98f0d554d1743a4c.1508062280.git.lucien.xin@gmail.com>
 <e240a6572c8e495eb2da15bd6178604cdfde08ba.1508062280.git.lucien.xin@gmail.com>
 <b4125c6cf42d4d028a9c04f4989627ac1eb83257.1508062280.git.lucien.xin@gmail.com>
 <784f477a1f9e8b9a5ec7bbe9e1dff1dcdfd5553b.1508062280.git.lucien.xin@gmail.com>
 <22c0aefe18d4451166c5f12714d8520346a63f2b.1508062280.git.lucien.xin@gmail.com>
 <6337bdec4b0564c0577f90703ea840fd3580912a.1508062280.git.lucien.xin@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, hannes@stressinduktion.org
To: Xin Long <lucien.xin@gmail.com>,
        network dev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f176.google.com ([209.85.192.176]:48319 "EHLO
        mail-pf0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751751AbdJPBRk (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 15 Oct 2017 21:17:40 -0400
Received: by mail-pf0-f176.google.com with SMTP id b79so14588089pfk.5
        for <netdev@vger.kernel.org>; Sun, 15 Oct 2017 18:17:40 -0700 (PDT)
In-Reply-To: <6337bdec4b0564c0577f90703ea840fd3580912a.1508062280.git.lucien.xin@gmail.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 10/15/17 4:13 AM, Xin Long wrote:
> NETDEV_CHANGE_TX_QUEUE_LEN event process in rtnetlink_event would
> send a notification for userspace and tx_queue_len's setting in
> do_setlink would trigger NETDEV_CHANGE_TX_QUEUE_LEN.
> 
> So it shouldn't set DO_SETLINK_NOTIFY status for this change to
> send a notification any more.
> 
> Signed-off-by: Xin Long <lucien.xin@gmail.com>
> ---
>  net/core/rtnetlink.c | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> diff --git a/net/core/rtnetlink.c b/net/core/rtnetlink.c
> index 3e98fb5..a6bcf86 100644
> --- a/net/core/rtnetlink.c
> +++ b/net/core/rtnetlink.c
> @@ -2093,7 +2093,7 @@ static int do_setlink(const struct sk_buff *skb,
>  				dev->tx_queue_len = orig_len;
>  				goto errout;
>  			}
> -			status |= DO_SETLINK_NOTIFY;
> +			status |= DO_SETLINK_MODIFIED;
>  		}
>  	}
>  
> 

Acked-by: David Ahern <dsahern@gmail.com>
