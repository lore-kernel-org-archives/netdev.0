From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH v3 net-next 1/4] flow_keys: include thoff into flow_keys
 for later usage
Date: Tue, 19 Mar 2013 09:41:55 -0700
Message-ID: <1363711315.2558.17.camel@edumazet-glaptop>
References: <1363711172-9728-1-git-send-email-dborkman@redhat.com>
	 <1363711172-9728-2-git-send-email-dborkman@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net
To: Daniel Borkmann <dborkman@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qc0-f177.google.com ([209.85.216.177]:56426 "EHLO
	mail-qc0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933201Ab3CSQl7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 19 Mar 2013 12:41:59 -0400
Received: by mail-qc0-f177.google.com with SMTP id u28so320754qcs.22
        for <netdev@vger.kernel.org>; Tue, 19 Mar 2013 09:41:58 -0700 (PDT)
In-Reply-To: <1363711172-9728-2-git-send-email-dborkman@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2013-03-19 at 17:39 +0100, Daniel Borkmann wrote:
> In skb_flow_dissect(), we perform a dissection of a skbuff. Since we're
> doing the work here anyway, also store thoff for a later usage, e.g. in
> the BPF filter.
> 
> Suggested-by: Eric Dumazet <edumazet@google.com>
> Signed-off-by: Daniel Borkmann <dborkman@redhat.com>
> ---
>  This patch also needs to go into the net tree, since Eric or Jason will
>  post a bug fix on top of this one.
> 
>  include/net/flow_keys.h   | 1 +
>  net/core/flow_dissector.c | 2 ++
>  2 files changed, 3 insertions(+)
> 
> diff --git a/include/net/flow_keys.h b/include/net/flow_keys.h
> index 80461c1..bb8271d 100644
> --- a/include/net/flow_keys.h
> +++ b/include/net/flow_keys.h
> @@ -9,6 +9,7 @@ struct flow_keys {
>  		__be32 ports;
>  		__be16 port16[2];
>  	};
> +	u16 thoff;
>  	u8 ip_proto;
>  };
>  
> diff --git a/net/core/flow_dissector.c b/net/core/flow_dissector.c
> index f8d9e03..f4be293 100644
> --- a/net/core/flow_dissector.c
> +++ b/net/core/flow_dissector.c
> @@ -151,6 +151,8 @@ ipv6:
>  			flow->ports = *ports;
>  	}
>  
> +	flow->thoff = (u16) nhoff;
> +
>  	return true;
>  }
>  EXPORT_SYMBOL(skb_flow_dissect);

Signed-off-by: Eric Dumazet <edumazet@google.com>
