From: Vlad Yasevich <vyasevich@gmail.com>
Subject: Re: [PATCH net 2/2] net: sctp: sctp_auth_key_put: use kzfree instead
 of kfree
Date: Thu, 07 Feb 2013 10:05:46 -0500
Message-ID: <5113C2CA.6080102@gmail.com>
References: <cover.1360231701.git.dborkman@redhat.com> <8c764d916f21d56402a5b9a915ea31d927898da0.1360231701.git.dborkman@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	linux-sctp@vger.kernel.org
To: Daniel Borkmann <dborkman@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vb0-f53.google.com ([209.85.212.53]:36613 "EHLO
	mail-vb0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754000Ab3BGPF5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 7 Feb 2013 10:05:57 -0500
In-Reply-To: <8c764d916f21d56402a5b9a915ea31d927898da0.1360231701.git.dborkman@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 02/07/2013 05:55 AM, Daniel Borkmann wrote:
> For sensitive data like keying material, it is common practice to zero
> out keys before returning the memory back to the allocator. Thus, use
> kzfree instead of kfree.
>
> Signed-off-by: Daniel Borkmann <dborkman@redhat.com>

Acked-by: Vlad Yasevich <vyasevich@gmail.com>

-vlad

> ---
>   net/sctp/auth.c | 2 +-
>   1 file changed, 1 insertion(+), 1 deletion(-)
>
> diff --git a/net/sctp/auth.c b/net/sctp/auth.c
> index 55f1b06..69fcd6d 100644
> --- a/net/sctp/auth.c
> +++ b/net/sctp/auth.c
> @@ -71,7 +71,7 @@ void sctp_auth_key_put(struct sctp_auth_bytes *key)
>   		return;
>
>   	if (atomic_dec_and_test(&key->refcnt)) {
> -		kfree(key);
> +		kzfree(key);
>   		SCTP_DBG_OBJCNT_DEC(keys);
>   	}
>   }
>
