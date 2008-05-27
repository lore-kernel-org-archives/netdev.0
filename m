From: Wei Yongjun <yjwei@cn.fujitsu.com>
Subject: Re: [PATCH 2.6.26-rc4] fix double call of kfree_skb in net/llc/llc_sap.c
Date: Tue, 27 May 2008 15:31:59 +0800
Message-ID: <483BB8EF.4090904@cn.fujitsu.com>
References: <84ee89da0805270009xe92f7e1l959fa9161c976db2@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	acme@ghostprotocols.net
To: Dmitry Petukhov <dmgenp@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:56082 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1756200AbYE0Hc0 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 27 May 2008 03:32:26 -0400
In-Reply-To: <84ee89da0805270009xe92f7e1l959fa9161c976db2@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Dmitry Petukhov wrote:
> in function llc_sap_state_proces there was lack of return statement,
> and finalizing kfree_skb might be called after skb was already freed
> or queued to the user.
>
> following patch adds the necessary return.
>
>   

Not correct, since kfree_skb(skb) is used after skb_get(skb).

First, it used skb_get inc the users counter, and then, kfree_skb will 
dec the users count, not do the real free.

> ---
>
> --- a/net/llc/llc_sap.c 2008-05-27 12:52:01.000000000 +0600
> +++ b/net/llc/llc_sap.c 2008-05-27 12:52:37.000000000 +0600
> @@ -223,6 +223,7 @@
>                         if (sock_queue_rcv_skb(skb->sk, skb))
>                                 kfree_skb(skb);
>                 }
> +               return;
>         }
>         kfree_skb(skb);
>  }
>   

