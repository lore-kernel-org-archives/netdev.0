From: Gao Feng <fgao@ikuai8.com>
Subject: Re: [PATCH net 1/1] driver: ipvlan: Unlink the upper dev when
 ipvlan_link_new failed
Date: Thu, 8 Dec 2016 09:44:44 +0800
Message-ID: <CA+6hz4p2pUJGQNM_CmNpSFPMrmA=9QBH-jx_1T7VGQv4Lh32GQ@mail.gmail.com>
References: <1481160060-28730-1-git-send-email-fgao@ikuai8.com> <CAF2d9jgfO=__ympFr-RSeWnKcwzDYDee5kh+Dp_KPk1fsMCHYQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8BIT
Cc: David Miller <davem@davemloft.net>,
        Eric Dumazet <edumazet@google.com>,
        linux-netdev <netdev@vger.kernel.org>
To: =?UTF-8?B?TWFoZXNoIEJhbmRld2FyICjgpK7gpLngpYfgpLYg4KSs4KSC4KSh4KWH4KS14KS+4KSwKQ==?=
        <maheshb@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtpproxy19.qq.com ([184.105.206.84]:51703 "EHLO
        smtpproxy19.qq.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S933226AbcLHBoy (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 7 Dec 2016 20:44:54 -0500
Received: from mail-vk0-f53.google.com (unknown [209.85.213.53])
        by esmtp4.qq.com (ESMTP) with SMTP id 0
        for <netdev@vger.kernel.org>; Thu, 08 Dec 2016 09:44:45 +0800 (CST)
Received: by mail-vk0-f53.google.com with SMTP id w194so222314843vkw.2
        for <netdev@vger.kernel.org>; Wed, 07 Dec 2016 17:44:46 -0800 (PST)
In-Reply-To: <CAF2d9jgfO=__ympFr-RSeWnKcwzDYDee5kh+Dp_KPk1fsMCHYQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Dec 8, 2016 at 9:39 AM, Mahesh Bandewar (महेश बंडेवार)
<maheshb@google.com> wrote:
> On Wed, Dec 7, 2016 at 5:21 PM,  <fgao@ikuai8.com> wrote:
>> From: Gao Feng <fgao@ikuai8.com>
>>
>> When netdev_upper_dev_unlink failed in ipvlan_link_new, need to
>> unlink the ipvlan dev with upper dev.
>>
>> Signed-off-by: Gao Feng <fgao@ikuai8.com>
>> ---
>>  drivers/net/ipvlan/ipvlan_main.c | 4 +++-
>>  1 file changed, 3 insertions(+), 1 deletion(-)
>>
>> diff --git a/drivers/net/ipvlan/ipvlan_main.c b/drivers/net/ipvlan/ipvlan_main.c
>> index 0fef178..189adbc 100644
>> --- a/drivers/net/ipvlan/ipvlan_main.c
>> +++ b/drivers/net/ipvlan/ipvlan_main.c
>> @@ -546,13 +546,15 @@ static int ipvlan_link_new(struct net *src_net, struct net_device *dev,
>>         }
>>         err = ipvlan_set_port_mode(port, mode);
>>         if (err) {
>> -               goto unregister_netdev;
>> +               goto dev_unlink;
>>         }
>>
>>         list_add_tail_rcu(&ipvlan->pnode, &port->ipvlans);
>>         netif_stacked_transfer_operstate(phy_dev, dev);
>>         return 0;
>>
>> +dev_unlink:
> probably 'unlink_netdev' label inline with other labels used. thanks

OK, it is better name.
I will follow it and send v2 update.

Regards
Feng

>> +       netdev_upper_dev_unlink(phy_dev, dev);
>>  unregister_netdev:
>>         unregister_netdevice(dev);
>>  destroy_ipvlan_port:
>> --
>> 1.9.1
>>
>>
