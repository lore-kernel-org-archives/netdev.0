From: Andy Zhou <azhou@nicira.com>
Subject: Re: [net-next 01/10] net: Rename ndo_add_vxlan_port to ndo_add_udp_tunnel_port.
Date: Thu, 24 Jul 2014 13:28:04 -0700
Message-ID: <CACzMAJLGEK7bxmjKfhEXLb73t6eDaUv7gHaXsDtERFBkjdeaTw@mail.gmail.com>
References: <1406024393-6778-1-git-send-email-azhou@nicira.com>
	<1406024393-6778-2-git-send-email-azhou@nicira.com>
	<CAJZOPZ+5M1ufs26dN68ZU+2g6cZ5zkzNH03JLwLg+5o50B9=KQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: David Miller <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Or Gerlitz <or.gerlitz@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from na3sys009aob139.obsmtp.com ([74.125.149.251]:60649 "HELO
	psmtp.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with SMTP
	id S934176AbaGXU2G (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 24 Jul 2014 16:28:06 -0400
Received: by mail-oa0-f47.google.com with SMTP id g18so4400831oah.34
        for <netdev@vger.kernel.org>; Thu, 24 Jul 2014 13:28:05 -0700 (PDT)
In-Reply-To: <CAJZOPZ+5M1ufs26dN68ZU+2g6cZ5zkzNH03JLwLg+5o50B9=KQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jul 23, 2014 at 11:40 PM, Or Gerlitz <or.gerlitz@gmail.com> wrote:
> On Tue, Jul 22, 2014 at 1:19 PM, Andy Zhou <azhou@nicira.com> wrote:
>>
>> Rename ndo_add_vxlan_port() API provided by net_device_ops to
>> ndo_add_udp_tunnel_port(). Generalized the API in preparation for
>> up coming NICs and device drivers that may support offloading more
>> UDP tunnels protocols besides VxLAN.  There is no behavioral changes
>> with this patch.
>>
>
>
> [..]
>
>>
>> --- a/drivers/net/vxlan.c
>> +++ b/drivers/net/vxlan.c
>> @@ -650,9 +650,11 @@ static void vxlan_notify_add_rx_port(struct vxlan_sock *vs)
>>
>>         rcu_read_lock();
>>         for_each_netdev_rcu(net, dev) {
>> -               if (dev->netdev_ops->ndo_add_vxlan_port)
>> -                       dev->netdev_ops->ndo_add_vxlan_port(dev, sa_family,
>> -                                                           port);
>> +               if (!dev->netdev_ops->ndo_add_udp_tunnel_port)
>> +                       continue;
>> +
>> +               dev->netdev_ops->ndo_add_udp_tunnel_port(dev, sa_family, port,
>> +                                                        UDP_TUNNEL_TYPE_VXLAN);
>>         }
>>         rcu_read_unlock();
>>  }
>
>
>
> Such changes should be done in a manner which is as minimal as
> possible and not introduce further cleanups
> or style modifications, here the existing code say
>
> if(ndo X is supported by dev Y)
>    call it
>
> Please stick to this and just replace the ndo name in this patch
>
>
>>
>> @@ -668,9 +670,10 @@ static void vxlan_notify_del_rx_port(struct vxlan_sock *vs)
>>
>>         rcu_read_lock();
>>         for_each_netdev_rcu(net, dev) {
>> -               if (dev->netdev_ops->ndo_del_vxlan_port)
>> -                       dev->netdev_ops->ndo_del_vxlan_port(dev, sa_family,
>> -                                                           port);
>> +               if (!dev->netdev_ops->ndo_del_udp_tunnel_port)
>> +                       continue;
>> +               dev->netdev_ops->ndo_del_udp_tunnel_port(dev, sa_family, port,
>> +                                                        UDP_TUNNEL_TYPE_VXLAN);
>>         }
>>         rcu_read_unlock();
>>
>
> same here

O.K. I will revert them back.
