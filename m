From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [net-next bugfix] net, rps: fix build failure when CONFIG_RPS
 isn't set
Date: Wed, 01 Jan 2014 01:03:18 +0300
Message-ID: <52C33F26.8070609@cogentembedded.com>
References: <1388521861-17410-1-git-send-email-zwu.kernel@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, therbert@google.com, fengguang.wu@intel.com,
	Zhi Yong Wu <wuzhy@linux.vnet.ibm.com>
To: Zhi Yong Wu <zwu.kernel@gmail.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lb0-f173.google.com ([209.85.217.173]:55216 "EHLO
	mail-lb0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756215Ab3LaVDV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 31 Dec 2013 16:03:21 -0500
Received: by mail-lb0-f173.google.com with SMTP id z5so6423969lbh.4
        for <netdev@vger.kernel.org>; Tue, 31 Dec 2013 13:03:20 -0800 (PST)
In-Reply-To: <1388521861-17410-1-git-send-email-zwu.kernel@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello.

On 12/31/2013 11:31 PM, Zhi Yong Wu wrote:

> From: Zhi Yong Wu <wuzhy@linux.vnet.ibm.com>

> Reported-by: Fengguang Wu <fengguang.wu@intel.com>
> Signed-off-by: Zhi Yong Wu <wuzhy@linux.vnet.ibm.com>
> ---
>   include/net/sock.h |    4 ++++
>   1 files changed, 4 insertions(+), 0 deletions(-)

> diff --git a/include/net/sock.h b/include/net/sock.h
> index 8ee90ad..bd716b6 100644
> --- a/include/net/sock.h
> +++ b/include/net/sock.h
> @@ -846,12 +846,16 @@ static inline void sock_rps_reset_flow_hash(__u32 hash)
>
>   static inline void sock_rps_record_flow(const struct sock *sk)
>   {
> +#ifdef CONFIG_RPS
>   	sock_rps_record_flow_hash(sk->sk_rxhash);
> +#endif
>   }
>
>   static inline void sock_rps_reset_flow(const struct sock *sk)
>   {
> +#ifdef CONFIG_RPS
>   	sock_rps_reset_flow_hash(sk->sk_rxhash);
> +#endif
>   }

    A lot better style would be:

+#ifdef CONFIG_RPS
  static inline void sock_rps_reset_flow(const struct sock *sk)
  {
  	sock_rps_reset_flow_hash(sk->sk_rxhash);
  }
#else
  static inline void sock_rps_reset_flow(const struct sock *sk) {}
+#endif

WBR, Sergei
