From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH net-next] xfrm: check function pointer of xfrm_mgr before
 use it
Date: Sun, 10 Nov 2013 23:03:19 +0400
Message-ID: <527FD877.70909@cogentembedded.com>
References: <1384093556-8987-1-git-send-email-baker.kernel@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: baker.kernel@gmail.com, herbert@gondor.apana.org.au,
	davem@davemloft.net, steffen.klassert@secunet.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-la0-f50.google.com ([209.85.215.50]:45102 "EHLO
	mail-la0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751204Ab3KJTDW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 10 Nov 2013 14:03:22 -0500
Received: by mail-la0-f50.google.com with SMTP id eo20so3282487lab.23
        for <netdev@vger.kernel.org>; Sun, 10 Nov 2013 11:03:20 -0800 (PST)
In-Reply-To: <1384093556-8987-1-git-send-email-baker.kernel@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello.

On 10-11-2013 18:25, baker.kernel@gmail.com wrote:

> From: "baker.zhang" <baker.kernel@gmail.com>

> Signed-off-by: baker.zhang <baker.kernel@gmail.com>
> ---
> For current kernel source, there is no problem.

> In our vpn product, we need a xfrm_km in kernel module
> to monitor the xfrm state change.
> thus, the 'acquire' and 'compile_policy' may be NULL.

> So I think we should do the check before use it.

>   net/xfrm/xfrm_state.c | 18 +++++++++++-------
>   1 file changed, 11 insertions(+), 7 deletions(-)

> diff --git a/net/xfrm/xfrm_state.c b/net/xfrm/xfrm_state.c
> index b9c3f9e..541f684 100644
> --- a/net/xfrm/xfrm_state.c
> +++ b/net/xfrm/xfrm_state.c
[...]
> @@ -1783,10 +1785,12 @@ int xfrm_user_policy(struct sock *sk, int optname, u8 __user *optval, int optlen
>   	err = -EINVAL;
>   	rcu_read_lock();
>   	list_for_each_entry_rcu(km, &xfrm_km_list, list) {
> -		pol = km->compile_policy(sk, optname, data,
> -					 optlen, &err);
> -		if (err >= 0)
> -			break;
> +		if (km->compile_policy) {
> +			pol = km->compile_policy(sk, optname, data,
> +					optlen, &err);

    According the networking coding style, the continuation line should start 
right under 'sk' on the previous line.

WBR, Sergei
