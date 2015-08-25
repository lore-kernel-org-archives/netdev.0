From: David Ahern <dsa@cumulusnetworks.com>
Subject: Re: [PATCH net-next] vrf: Add ethernet header for pass through VRF
 device
Date: Tue, 25 Aug 2015 15:37:55 -0700
Message-ID: <55DCEE43.4000200@cumulusnetworks.com>
References: <1440355260-16528-1-git-send-email-dsa@cumulusnetworks.com> <20150825.140220.156958823239060297.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, shm@cumulusnetworks.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f54.google.com ([209.85.220.54]:34639 "EHLO
	mail-pa0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932595AbbHYWh5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 25 Aug 2015 18:37:57 -0400
Received: by pabzx8 with SMTP id zx8so47016551pab.1
        for <netdev@vger.kernel.org>; Tue, 25 Aug 2015 15:37:57 -0700 (PDT)
In-Reply-To: <20150825.140220.156958823239060297.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 8/25/15 2:02 PM, David Miller wrote:
> From: David Ahern <dsa@cumulusnetworks.com>
> Date: Sun, 23 Aug 2015 12:41:00 -0600
>
>> @@ -250,6 +253,17 @@ static netdev_tx_t vrf_xmit(struct sk_buff *skb, struct net_device *dev)
>>
>>   static netdev_tx_t vrf_finish(struct sock *sk, struct sk_buff *skb)
>>   {
>> +	int err;
>> +
>> +	__skb_pull(skb, skb_network_offset(skb));
>> +	err = dev_hard_header(skb, skb->dev, ntohs(skb->protocol),
>> +			      NULL, NULL, skb->len);
>> +
>> +	if (err < 0) {
>> +		vrf_tx_error(skb->dev, skb);
>> +		return -EINVAL;
>> +	}
>> +
>>   	return dev_queue_xmit(skb);
>
> This is expensive and rediculous to do for every TX frame.
>
> You'll need to find another way.
>

The packet is directed here from the IP layer via the custom dst, so 
there is no L2 header on the skb. So while the push and pop of the 
header seems silly it is part and parcel of the feature to run tcpdump 
on the VRF device. I don't see how it could be done any other way.

David
