From: Zhi Yong Wu <zwu.kernel@gmail.com>
Subject: Re: [RFC PATCH net-next 2/3] virtio_net: Introduce one dummy function virtnet_filter_rfs()
Date: Thu, 16 Jan 2014 10:45:28 +0800
Message-ID: <CAEH94Lj7VGamzKCKyxWviRO2P7Hmz=DZWgqaoQCUYzYUWy=9aw@mail.gmail.com>
References: <1389795654-28381-1-git-send-email-zwu.kernel@gmail.com>
	<1389795654-28381-3-git-send-email-zwu.kernel@gmail.com>
	<CA+mtBx8Z80d5Y1ti0_68UA-x0hZPeqT4wa9knevWoPxX+eyaVA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Linux Netdev List <netdev@vger.kernel.org>,
	Eric Dumazet <edumazet@google.com>,
	David Miller <davem@davemloft.net>,
	Zhi Yong Wu <wuzhy@linux.vnet.ibm.com>
To: Tom Herbert <therbert@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f175.google.com ([209.85.214.175]:44633 "EHLO
	mail-ob0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751401AbaAPCp2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 15 Jan 2014 21:45:28 -0500
Received: by mail-ob0-f175.google.com with SMTP id uz6so2109361obc.20
        for <netdev@vger.kernel.org>; Wed, 15 Jan 2014 18:45:28 -0800 (PST)
In-Reply-To: <CA+mtBx8Z80d5Y1ti0_68UA-x0hZPeqT4wa9knevWoPxX+eyaVA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Jan 16, 2014 at 1:54 AM, Tom Herbert <therbert@google.com> wrote:
> Zhi, this is promising work! I can't wait to see how this impacts
"Zhi" is part of my first name, you call me "Zhi Yong".
> network virtualization performance :-)
heh, too much work is missing.
>
> On Wed, Jan 15, 2014 at 6:20 AM, Zhi Yong Wu <zwu.kernel@gmail.com> wrote:
>> From: Zhi Yong Wu <wuzhy@linux.vnet.ibm.com>
>>
>> Signed-off-by: Zhi Yong Wu <wuzhy@linux.vnet.ibm.com>
>> ---
>>  drivers/net/virtio_net.c |   11 +++++++++++
>>  1 files changed, 11 insertions(+), 0 deletions(-)
>>
>> diff --git a/drivers/net/virtio_net.c b/drivers/net/virtio_net.c
>> index 7b17240..046421c 100644
>> --- a/drivers/net/virtio_net.c
>> +++ b/drivers/net/virtio_net.c
>> @@ -1295,6 +1295,14 @@ static int virtnet_change_mtu(struct net_device *dev, int new_mtu)
>>         return 0;
>>  }
>>
>> +#ifdef CONFIG_RFS_ACCEL
>> +static int virtnet_filter_rfs(struct net_device *net_dev,
>> +               const struct sk_buff *skb, u16 rxq_index, u32 flow_id)
>> +{
> Does this need to be filled out with more stuff?
Yes, the following stuff are missing:
1.)  guest virtio_net driver should have one filter table and its
entries can be expired periodically;
2.)  guest virtio_net driver should pass rx queue index and filter
info down to the emulated virtio_net NIC in QEMU.
3.) the emulated virtio_net NIC should have its indirect table to
store the flow to rx queue mapping.
4.) the emulated virtio_net NIC should classify the rx packet to
selected queue by applying the filter.
5.) update virtio spec.
Do i miss anything? If yes, please correct me.
For 3.) and 4.), do you have any doc about how they are implemented in
physical NICs? e.g. mlx4_en or sfc, etc.

>
>> +       return 0;
>> +}
>> +#endif /* CONFIG_RFS_ACCEL */
>> +
>>  static const struct net_device_ops virtnet_netdev = {
>>         .ndo_open            = virtnet_open,
>>         .ndo_stop            = virtnet_close,
>> @@ -1309,6 +1317,9 @@ static const struct net_device_ops virtnet_netdev = {
>>  #ifdef CONFIG_NET_POLL_CONTROLLER
>>         .ndo_poll_controller = virtnet_netpoll,
>>  #endif
>> +#ifdef CONFIG_RFS_ACCEL
>> +       .ndo_rx_flow_steer   = virtnet_filter_rfs,
>> +#endif
>>  };
>>
>>  static void virtnet_config_changed_work(struct work_struct *work)
>> --
>> 1.7.6.5
>>



-- 
Regards,

Zhi Yong Wu
