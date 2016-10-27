From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next v1 13/16] tipc: create TIPC_DISCONNECTING as a
 new sk_state
Date: Thu, 27 Oct 2016 08:03:23 -0700
Message-ID: <1477580603.7065.210.camel@edumazet-glaptop3.roam.corp.google.com>
References: <1477578157-13256-1-git-send-email-parthasarathy.bhuvaragan@ericsson.com>
         <1477578157-13256-14-git-send-email-parthasarathy.bhuvaragan@ericsson.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, tipc-discussion@lists.sourceforge.net,
        jon.maloy@ericsson.com, maloy@donjonn.com, ying.xue@windriver.com
To: Parthasarathy Bhuvaragan <parthasarathy.bhuvaragan@ericsson.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f194.google.com ([209.85.192.194]:34241 "EHLO
        mail-pf0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S933120AbcJ0PDZ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 27 Oct 2016 11:03:25 -0400
Received: by mail-pf0-f194.google.com with SMTP id u84so2898220pfj.1
        for <netdev@vger.kernel.org>; Thu, 27 Oct 2016 08:03:25 -0700 (PDT)
In-Reply-To: <1477578157-13256-14-git-send-email-parthasarathy.bhuvaragan@ericsson.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2016-10-27 at 16:22 +0200, Parthasarathy Bhuvaragan wrote:
> In this commit, we create a new tipc socket state TIPC_DISCONNECTING in
> sk_state. TIPC_DISCONNECTING is replacing the socket connection status
> update using SS_DISCONNECTING.
> TIPC_DISCONNECTING is set for connection oriented sockets at:
> - tipc_shutdown()
> - connection probe timeout
> - when we receive an error message on the connection.
> 
> There is no functional change in this commit.
> 
> Acked-by: Ying Xue <ying.xue@windriver.com>
> Acked-by: Jon Maloy <jon.maloy@ericsson.com>
> Signed-off-by: Parthasarathy Bhuvaragan <parthasarathy.bhuvaragan@ericsson.com>
> ---
>  include/uapi/linux/tipc.h |  1 +
>  net/tipc/socket.c         | 39 +++++++++++++++++++++++----------------
>  2 files changed, 24 insertions(+), 16 deletions(-)
> 
> diff --git a/include/uapi/linux/tipc.h b/include/uapi/linux/tipc.h
> index ae45de5e0d93..f5c03fdfc8a8 100644
> --- a/include/uapi/linux/tipc.h
> +++ b/include/uapi/linux/tipc.h
> @@ -184,6 +184,7 @@ enum {
>  	TIPC_PROBING,
>  	TIPC_ESTABLISHED,
>  	TIPC_OPEN,
> +	TIPC_DISCONNECTING,
>  };


Note that all these TIPC socket states might conflict with 
sk_fullsock(), sk_listener(), inet6_sk(), ip_skb_dst_mtu(),
sk_const_to_full_sk() , skb_to_full_sk() helpers.

So there is definitely a high risk.
