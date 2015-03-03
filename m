From: David Laight <David.Laight@ACULAB.COM>
Subject: RE: [PATCH v2] net: bridge: add compile-time assert for cb struct
 size
Date: Tue, 3 Mar 2015 13:50:59 +0000
Message-ID: <063D6719AE5E284EB5DD2968C1650D6D1CAF3BB7@AcuExch.aculab.com>
References: <1425387211-16807-1-git-send-email-fw@strlen.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="Windows-1252"
Content-Transfer-Encoding: 8BIT
To: 'Florian Westphal' <fw@strlen.de>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out6.electric.net ([192.162.217.185]:52772 "EHLO
	smtp-out6.electric.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755819AbbCCNwT convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 3 Mar 2015 08:52:19 -0500
In-Reply-To: <1425387211-16807-1-git-send-email-fw@strlen.de>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Florian Westphal
> make build fail if structure no longer fits into ->cb storage.
> 
> Signed-off-by: Florian Westphal <fw@strlen.de>
> ---
>  Change since v1: use FIELD_SIZEOF
> 
>  checkpatch complains about >80 chars, but line break is ugly here.
> 
> diff --git a/net/bridge/br.c b/net/bridge/br.c
> index fb57ab6..02c24cf 100644
> --- a/net/bridge/br.c
> +++ b/net/bridge/br.c
> @@ -190,6 +190,8 @@ static int __init br_init(void)
>  {
>  	int err;
> 
> +	BUILD_BUG_ON(sizeof(struct br_input_skb_cb) > FIELD_SIZEOF(struct sk_buff, cb));
> +

What about using something based on:
#define GET_CB(skb, type) ((type *)((skb)->cb + (sizeof (char[(sizeof (type) <= sizeof (skb->cb)) ? 1 : -1] - 1)))
to access skb->sb?

Then all invalid uses are likely to be picked up.

	David
