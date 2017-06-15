From: YUAN Linyu <Linyu.Yuan@alcatel-sbell.com.cn>
Subject: RE: [RFC v2] networking: convert many more places to skb_put_zero()
Date: Thu, 15 Jun 2017 09:54:33 +0000
Message-ID: <8729016553E3654398EA69218DA29EEF15BC901A@cnshjmbx02>
References: <20170615092804.19400-1-johannes@sipsolutions.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: Johannes Berg <johannes.berg@intel.com>
To: Johannes Berg <johannes@sipsolutions.net>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cnshjsmin03.alcatel-sbell.com.cn ([116.246.26.71]:50188 "EHLO
        cnshjsmin03.alcatel-sbell.com.cn" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1750948AbdFOJyf (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 15 Jun 2017 05:54:35 -0400
In-Reply-To: <20170615092804.19400-1-johannes@sipsolutions.net>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



> -----Original Message-----
> From: netdev-owner@vger.kernel.org [mailto:netdev-owner@vger.kernel.org]
> On Behalf Of Johannes Berg
> Sent: Thursday, June 15, 2017 5:28 PM
> To: netdev@vger.kernel.org
> Cc: Johannes Berg
> Subject: [RFC v2] networking: convert many more places to skb_put_zero()
> 
> From: Johannes Berg <johannes.berg@intel.com>
> diff --git a/net/sctp/sm_make_chunk.c b/net/sctp/sm_make_chunk.c
> index ea2601501654..aaac2660aaf7 100644
> --- a/net/sctp/sm_make_chunk.c
> +++ b/net/sctp/sm_make_chunk.c
> @@ -1478,10 +1478,9 @@ void *sctp_addto_chunk(struct sctp_chunk *chunk,
> int len, const void *data)
>  	int chunklen = ntohs(chunk->chunk_hdr->length);
>  	int padlen = SCTP_PAD4(chunklen) - chunklen;
> 
> -	padding = skb_put(chunk->skb, padlen);
> +	padding = skb_put_zero(chunk->skb, padlen);
"padding" will become unused. 
I know this place when I check.
>  	target = skb_put(chunk->skb, len);
> 
> -	memset(padding, 0, padlen);
>  	memcpy(target, data, len);
> 
>  	/* Adjust the chunk length field.  */
> --
> 2.11.0
