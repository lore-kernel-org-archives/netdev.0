From: Ben Greear <greearb@candelatech.com>
Subject: Re: [PATCH 1/2] igb: Allow extra 4 bytes on RX for vlan tags.
Date: Thu, 17 Feb 2011 09:28:56 -0800
Message-ID: <4D5D5AD8.5000802@candelatech.com>
References: <1297375149-18458-1-git-send-email-greearb@candelatech.com> <AANLkTinsWRAJ2bepa1NjQ4f0Wz46DaxWO6f_nEbmBAB0@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.candelatech.com ([208.74.158.172]:36320 "EHLO
	ns3.lanforge.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751599Ab1BQR3A (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 17 Feb 2011 12:29:00 -0500
In-Reply-To: <AANLkTinsWRAJ2bepa1NjQ4f0Wz46DaxWO6f_nEbmBAB0@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 02/17/2011 03:04 AM, Jeff Kirsher wrote:
> On Thu, Feb 10, 2011 at 13:59,<greearb@candelatech.com>  wrote:
>> From: Ben Greear<greearb@candelatech.com>
>>
>> This allows the NIC to receive 1518 byte (not counting
>> FCS) packets when MTU is 1500, thus allowing 1500 MTU
>> VLAN frames to be received.  Please note that no VLANs
>> were actually configured on the NIC...it was just acting
>> as pass-through device.
>>
>> Signed-off-by: Ben Greear<greearb@candelatech.com>
>> ---
>> :100644 100644 58c665b... 30c9cc6... M  drivers/net/igb/igb_main.c
>>   drivers/net/igb/igb_main.c |    5 +++--
>>   1 files changed, 3 insertions(+), 2 deletions(-)
>>
>> diff --git a/drivers/net/igb/igb_main.c b/drivers/net/igb/igb_main.c
>> index 58c665b..30c9cc6 100644
>> --- a/drivers/net/igb/igb_main.c
>> +++ b/drivers/net/igb/igb_main.c
>> @@ -2281,7 +2281,8 @@ static int __devinit igb_sw_init(struct igb_adapter *adapter)
>>         adapter->rx_itr_setting = IGB_DEFAULT_ITR;
>>         adapter->tx_itr_setting = IGB_DEFAULT_ITR;
>>
>> -       adapter->max_frame_size = netdev->mtu + ETH_HLEN + ETH_FCS_LEN;
>> +       adapter->max_frame_size = (netdev->mtu + ETH_HLEN + ETH_FCS_LEN
>> +                                  + VLAN_HLEN);
>>         adapter->min_frame_size = ETH_ZLEN + ETH_FCS_LEN;
>>
>>         spin_lock_init(&adapter->stats64_lock);
>> @@ -4303,7 +4304,7 @@ static int igb_change_mtu(struct net_device *netdev, int new_mtu)
>>   {
>>         struct igb_adapter *adapter = netdev_priv(netdev);
>>         struct pci_dev *pdev = adapter->pdev;
>> -       int max_frame = new_mtu + ETH_HLEN + ETH_FCS_LEN;
>> +       int max_frame = new_mtu + ETH_HLEN + ETH_FCS_LEN + VLAN_HLEN;
>>         u32 rx_buffer_len, i;
>>
>>         if ((new_mtu<  68) || (max_frame>  MAX_JUMBO_FRAME_SIZE)) {
>
> While testing this patch, validation found that the patch reduces the
> maximum mtu size
> by 4 bytes (reduces it from 9216 to 9212).  This is not a desired side
> effect of this patch.

You could add handling for that case and have it act as it used to when
new_mtu is greater than 9212?

I tested e1000e and it worked w/out hacking at 1500 MTU, so maybe
check how it does it?

Thanks,
Ben

-- 
Ben Greear <greearb@candelatech.com>
Candela Technologies Inc  http://www.candelatech.com

