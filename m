From: Daniel Borkmann <dborkman@redhat.com>
Subject: Re: linux-next: manual merge of the bluetooth tree with the net/net-next
 trees
Date: Tue, 07 Jan 2014 15:37:45 +0100
Message-ID: <52CC1139.1040701@redhat.com>
References: <20140107125418.986ae20298ddc55e5e657447@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Gustavo Padovan <gustavo@padovan.org>,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	linux-next@vger.kernel.org, linux-kernel@vger.kernel.org,
	Jukka Rissanen <jukka.rissanen@linux.intel.com>
To: Stephen Rothwell <sfr@canb.auug.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:32674 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751490AbaAGOhz (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 7 Jan 2014 09:37:55 -0500
In-Reply-To: <20140107125418.986ae20298ddc55e5e657447@canb.auug.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 01/07/2014 02:54 AM, Stephen Rothwell wrote:
> Hi Gustavo,
>
> Today's linux-next merge of the bluetooth tree got a conflict in
> net/ieee802154/6lowpan.c between commit 965801e1eb62 ("net: 6lowpan: fix
> lowpan_header_create non-compression memcpy call") from the  tree and
> commit 8df8c56a5abc ("6lowpan: Moving generic compression code into
> 6lowpan_iphc.c") from the bluetooth tree.
>
> I fixed it up (I applied the following patch to move the fix into
> 6lowpan_iphc.c) and can carry the fix as necessary (no action is
> required).
>
> From: Stephen Rothwell <sfr@canb.auug.org.au>
> Date: Tue, 7 Jan 2014 12:52:43 +1100
> Subject: [PATCH] net: 6lowpan: fixup for code movement
>
> Signed-off-by: Stephen Rothwell <sfr@canb.auug.org.au>

Looks good to me, thanks!

> ---
>   net/ieee802154/6lowpan_iphc.c | 2 +-
>   1 file changed, 1 insertion(+), 1 deletion(-)
>
> diff --git a/net/ieee802154/6lowpan_iphc.c b/net/ieee802154/6lowpan_iphc.c
> index 11840f9e46da..e14fe8b2c054 100644
> --- a/net/ieee802154/6lowpan_iphc.c
> +++ b/net/ieee802154/6lowpan_iphc.c
> @@ -677,7 +677,7 @@ int lowpan_header_compress(struct sk_buff *skb, struct net_device *dev,
>   			hc06_ptr += 3;
>   		} else {
>   			/* compress nothing */
> -			memcpy(hc06_ptr, &hdr, 4);
> +			memcpy(hc06_ptr, hdr, 4);
>   			/* replace the top byte with new ECN | DSCP format */
>   			*hc06_ptr = tmp;
>   			hc06_ptr += 4;
>
