From: Hauke Mehrtens <hauke@hauke-m.de>
Subject: Re: [PATCH] bgmac: fix unaligned accesses to network headers
Date: Sat, 16 Feb 2013 20:01:32 +0100
Message-ID: <511FD78C.5000805@hauke-m.de>
References: <1361025154-11612-1-git-send-email-hauke@hauke-m.de> <20130216103612.190d908e@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, zajec5@gmail.com, netdev@vger.kernel.org
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from server19320154104.serverpool.info ([193.201.54.104]:34823 "EHLO
	hauke-m.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753987Ab3BPTBo (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 16 Feb 2013 14:01:44 -0500
In-Reply-To: <20130216103612.190d908e@nehalam.linuxnetplumber.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 02/16/2013 07:36 PM, Stephen Hemminger wrote:
> On Sat, 16 Feb 2013 15:32:34 +0100
> Hauke Mehrtens <hauke@hauke-m.de> wrote:
> 
>> Without this patch I get many unaligned access warnings per packet,
>> this patches fixes them all. This should improve performance ony some
>> systems like mips.
>>
>> Signed-off-by: Hauke Mehrtens <hauke@hauke-m.de>
>> ---
>>  drivers/net/ethernet/broadcom/bgmac.c |    3 ++-
>>  1 file changed, 2 insertions(+), 1 deletion(-)
>>
>> diff --git a/drivers/net/ethernet/broadcom/bgmac.c b/drivers/net/ethernet/broadcom/bgmac.c
>> index d341090..f9b1bc8 100644
>> --- a/drivers/net/ethernet/broadcom/bgmac.c
>> +++ b/drivers/net/ethernet/broadcom/bgmac.c
>> @@ -301,8 +301,9 @@ static int bgmac_dma_rx_read(struct bgmac *bgmac, struct bgmac_dma_ring *ring,
>>  			bgmac_err(bgmac, "Found poisoned packet at slot %d, DMA issue!\n",
>>  				  ring->start);
>>  		} else {
>> -			new_skb = netdev_alloc_skb(bgmac->net_dev, len);
>> +			new_skb = netdev_alloc_skb(bgmac->net_dev, len + 2);
>>  			if (new_skb) {
>> +				skb_reserve(new_skb, 2);
>>  				skb_put(new_skb, len);
>>  				skb_copy_from_linear_data_offset(skb, BGMAC_RX_FRAME_OFFSET,
>>  								 new_skb->data,
> 
> NAK. Use netdev_alloc_skb_ip_align instead. 
> It is less error prone, and handles case of architectures where unaligned is faster.

Thanks for the hint, I will send a better version of this patch.

Hauke
