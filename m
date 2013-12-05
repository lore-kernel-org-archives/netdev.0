From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH RFC 1/5] {pktgen, xfrm} Remove original pktgen ipsec fixed
 configuration
Date: Thu, 05 Dec 2013 18:00:05 +0400
Message-ID: <52A086E5.1050701@cogentembedded.com>
References: <1386230239-31860-1-git-send-email-fan.du@windriver.com> <1386230239-31860-2-git-send-email-fan.du@windriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Fan Du <fan.du@windriver.com>, steffen.klassert@secunet.com,
	davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-la0-f42.google.com ([209.85.215.42]:52749 "EHLO
	mail-la0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932146Ab3LEOAF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 5 Dec 2013 09:00:05 -0500
Received: by mail-la0-f42.google.com with SMTP id ec20so10542897lab.1
        for <netdev@vger.kernel.org>; Thu, 05 Dec 2013 06:00:03 -0800 (PST)
In-Reply-To: <1386230239-31860-2-git-send-email-fan.du@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello.

On 05-12-2013 11:57, Fan Du wrote:

> Cleanup original fixed IPsec output mode and encapuslation type,
> As following patchset enable user to configure IPsec attribute.

> Signed-off-by: Fan Du <fan.du@windriver.com>
> ---
>   net/core/pktgen.c |   11 +++--------
>   1 file changed, 3 insertions(+), 8 deletions(-)

> diff --git a/net/core/pktgen.c b/net/core/pktgen.c
> index a797fff..ab67986 100644
> --- a/net/core/pktgen.c
> +++ b/net/core/pktgen.c
> @@ -387,8 +387,7 @@ struct pktgen_dev {
>   	int node;               /* Memory node */
>
>   #ifdef CONFIG_XFRM
> -	__u8	ipsmode;		/* IPSEC mode (config) */
> -	__u8	ipsproto;		/* IPSEC type (config) */
> +

    Why add this empty line which you'll remove in patch #3? And I'd also have 
removed empty #ifdef too...

>   #endif
>   	char result[512];
>   };
> @@ -2482,10 +2481,7 @@ static int pktgen_output_ipsec(struct sk_buff *skb, struct pktgen_dev *pkt_dev)
>
>   	if (!x)
>   		return 0;
> -	/* XXX: we dont support tunnel mode for now until
> -	 * we resolve the dst issue */
> -	if (x->props.mode != XFRM_MODE_TRANSPORT)
> -		return 0;
> +

    Why? There's enough empty lines already.

>
>   	spin_lock(&x->lock);
>
> @@ -3540,8 +3536,7 @@ static int pktgen_add_device(struct pktgen_thread *t, const char *ifname)
>   		goto out2;
>   	}
>   #ifdef CONFIG_XFRM
> -	pkt_dev->ipsmode = XFRM_MODE_TRANSPORT;
> -	pkt_dev->ipsproto = IPPROTO_ESP;
> +

    Same question about empty line removed in patch #3.

>   #endif

WBR, Sergei
