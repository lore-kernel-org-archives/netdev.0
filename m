From: David Daney <ddaney@caviumnetworks.com>
Subject: Re: [PATCH] skbuff: align sk_buff::cb to 64 bit
Date: Fri, 29 Jan 2010 14:42:03 -0800
Message-ID: <4B63643B.3070400@caviumnetworks.com>
References: <4B635CA1.8070803@openwrt.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Lennert Buytenhek <buytenh@wantstofly.org>
To: Felix Fietkau <nbd@openwrt.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail3.caviumnetworks.com ([12.108.191.235]:13661 "EHLO
	mail3.caviumnetworks.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752339Ab0A2Wml (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 29 Jan 2010 17:42:41 -0500
In-Reply-To: <4B635CA1.8070803@openwrt.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Felix Fietkau wrote:
> The alignment requirement for 64-bit load/store instructions on ARM is
> implementation defined. Some CPUs (such as Marvell Feroceon) do not
> generate an exception, if such an instruction is executed with an
> address that is not 64 bit aligned. 
> In such a case, the Feroceon corrupts adjacent memory, which showed up
> in my tests as a crash in the rx path of ath9k that only occured with
> CONFIG_XFRM set. This crash happened, because the first field of the
> mac80211 rx status info in the cb is an u64, and changing it corrupted
> the skb->sp field.
> 
> Signed-off-by: Felix Fietkau <nbd@openwrt.org>
> Cc: stable@kernel.org
> ---
> --- a/include/linux/skbuff.h
> +++ b/include/linux/skbuff.h
> @@ -329,7 +329,7 @@ struct sk_buff {
>  	 * want to keep them across layers you have to do a skb_clone()
>  	 * first. This is owned by whoever has the skb queued ATM.
>  	 */
> -	char			cb[48];
> +	char			cb[48] __attribute__((aligned(8)));
>  


s/__attribute__((aligned(8)))/__aligned(8)/

Could the same thing be achieved by swapping the order of the dev and 
tstamp fields instead of adding the alignment attribute?

What is the sizeof(void *) on this thing?

David Daney
