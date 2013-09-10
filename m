From: Vlad Yasevich <vyasevic@redhat.com>
Subject: Re: [PATCH net 3/4] bridge: Fix the way the PVID is referenced
Date: Tue, 10 Sep 2013 10:24:00 -0400
Message-ID: <522F2B80.20703@redhat.com>
References: <1378808874.3988.2.camel@ubuntu-vm-makita> <1378809451.3988.11.camel@ubuntu-vm-makita>
Reply-To: vyasevic@redhat.com
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
To: Toshiaki Makita <makita.toshiaki@lab.ntt.co.jp>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:7304 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751098Ab3IJOYE (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 10 Sep 2013 10:24:04 -0400
In-Reply-To: <1378809451.3988.11.camel@ubuntu-vm-makita>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 09/10/2013 06:37 AM, Toshiaki Makita wrote:
> We are using the VLAN_TAG_PRESENT bit to detect whether the PVID is
> set or not at br_get_pvid(), while we don't care about the bit in
> adding/deleting the PVID, which makes it impossible to forward any
> incomming untagged frame with vlan_filtering enabled.
>
> Since vid 0 cannot be used for the PVID, we can use vid 0 to indicate
> that the PVID is not set, which is slightly more efficient than using
> the VLAN_TAG_PRESENT.

Yes, that is simpler.
>
> Fix the problem by getting rid of using the VLAN_TAG_PRESENT.
>
> Signed-off-by: Toshiaki Makita <makita.toshiaki@lab.ntt.co.jp>

Reviewed-by: Vlad Yasevich <vyasevich@redhat.com>

-vlad

> ---
>   net/bridge/br_private.h | 4 +---
>   1 file changed, 1 insertion(+), 3 deletions(-)
>
> diff --git a/net/bridge/br_private.h b/net/bridge/br_private.h
> index 598cb0b..435ca4d 100644
> --- a/net/bridge/br_private.h
> +++ b/net/bridge/br_private.h
> @@ -646,9 +646,7 @@ static inline u16 br_get_pvid(const struct net_port_vlans *v)
>   	 * vid wasn't set
>   	 */
>   	smp_rmb();
> -	return (v->pvid & VLAN_TAG_PRESENT) ?
> -			(v->pvid & ~VLAN_TAG_PRESENT) :
> -			VLAN_N_VID;
> +	return v->pvid ?: VLAN_N_VID;
>   }
>
>   #else
>
