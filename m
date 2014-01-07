From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH net-next 1/2] include/uapi/linux/xfrm.h: Pack struct xfrm_userpolicy_info
Date: Wed, 08 Jan 2014 02:52:11 +0400
Message-ID: <52CC851B.2060401@cogentembedded.com>
References: <1389077339-12814-1-git-send-email-fan.du@windriver.com> <1389077339-12814-2-git-send-email-fan.du@windriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, stephen@networkplumber.org,
	dev@lists.strongswan.org, netdev@vger.kernel.org
To: Fan Du <fan.du@windriver.com>, steffen.klassert@secunet.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-la0-f42.google.com ([209.85.215.42]:48353 "EHLO
	mail-la0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754162AbaAGWwM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 7 Jan 2014 17:52:12 -0500
Received: by mail-la0-f42.google.com with SMTP id ec20so604913lab.29
        for <netdev@vger.kernel.org>; Tue, 07 Jan 2014 14:52:10 -0800 (PST)
In-Reply-To: <1389077339-12814-2-git-send-email-fan.du@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello.

On 07-01-2014 10:48, Fan Du wrote:

> Otherwise 64bits kernel has sizeof(struct xfrm_userpolicy_info) 168 bytes,
> while 32bits compiled iproute2 see the same structure as 164 bytes, which
> leading deficit xfrm policy, in turn broken IPsec connectivity.

> Fix this by packing the structure.

    This will force byte-by-byte access to all members on some arches like ARM...

> Signed-off-by: Fan Du <fan.du@windriver.com>
> ---
>   include/uapi/linux/xfrm.h |    2 +-
>   1 file changed, 1 insertion(+), 1 deletion(-)

> diff --git a/include/uapi/linux/xfrm.h b/include/uapi/linux/xfrm.h
> index a8cd6a4..470bfae 100644
> --- a/include/uapi/linux/xfrm.h
> +++ b/include/uapi/linux/xfrm.h
> @@ -405,7 +405,7 @@ struct xfrm_userpolicy_info {
>   	/* Automatically expand selector to include matching ICMP payloads. */
>   #define XFRM_POLICY_ICMP	2
>   	__u8				share;
> -};
> +} __attribute__((packed));

    Please use the __packed macro instead. I guess you haven't run checkpatch.pl?

WBR, Sergei
