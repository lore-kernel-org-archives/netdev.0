From: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
Subject: Re: [PATCH] firewire net: Ensure checksumming in upper layer.
Date: Sun, 20 Jan 2013 19:37:09 +0900
Message-ID: <50FBC8D5.50205@linux-ipv6.org>
References: <50FBA02C.9030203@linux-ipv6.org> <20130120105058.1aee26c4@stein>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: linux1394-devel@lists.sourceforge.net, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org,
	YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
To: Stefan Richter <stefanr@s5r6.in-berlin.de>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20130120105058.1aee26c4@stein>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Stefan Richter wrote:
> On Jan 20 YOSHIFUJI Hideaki wrote:
>> It is wrong to set skb->ip_summed to CHECKSUM_UNNECESSARY unless
>> the device has already checked it.
>>
>> Signed-off-by: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
>> ---
>>  drivers/firewire/net.c |    2 +-
>>  1 file changed, 1 insertion(+), 1 deletion(-)
>>
>> diff --git a/drivers/firewire/net.c b/drivers/firewire/net.c
>> index e7a711f5..df6a1ca 100644
>> --- a/drivers/firewire/net.c
>> +++ b/drivers/firewire/net.c
>> @@ -520,7 +520,7 @@ static int fwnet_finish_incoming_packet(struct net_device *net,
>>  	dev = netdev_priv(net);
>>  	/* Write metadata, and then pass to the receive level */
>>  	skb->dev = net;
>> -	skb->ip_summed = CHECKSUM_UNNECESSARY;  /* don't check it */
>> +	skb->ip_summed = CHECKSUM_NONE;
>>  
>>  	/*
>>  	 * Parse the encapsulation header. This actually does the job of
> 
> Indeed neither the device nor the lower drivers check protocol checksums.
> But the CRCs of the encapsulating 1394 packets are checked in hardware.
> Shall protocol checksums be verified regardless?

Yes, because packets may come from off-link source.

--yoshfuji
