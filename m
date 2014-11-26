From: Mahesh Bandewar <maheshb@google.com>
Subject: Re: [PATCH net-next v4] ipvlan: Initial check-in of the IPVLAN driver.
Date: Wed, 26 Nov 2014 09:05:41 -0800
Message-ID: <CAF2d9jgZkgk4kOyS7K959vEq_55DuEnkVdxzKPdmPiTxFfPvsg@mail.gmail.com>
References: <1416812866-13401-1-git-send-email-maheshb@google.com> <54757631.8090604@lab.ntt.co.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: netdev <netdev@vger.kernel.org>,
	Eric Dumazet <edumazet@google.com>,
	Maciej Zenczykowski <maze@google.com>,
	Laurent Chavey <chavey@google.com>,
	Tim Hockin <thockin@google.com>,
	David Miller <davem@davemloft.net>,
	Brandon Philips <brandon.philips@coreos.com>,
	Pavel Emelianov <xemul@parallels.com>
To: Toshiaki Makita <makita.toshiaki@lab.ntt.co.jp>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vc0-f175.google.com ([209.85.220.175]:58278 "EHLO
	mail-vc0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751142AbaKZRGD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 26 Nov 2014 12:06:03 -0500
Received: by mail-vc0-f175.google.com with SMTP id hy10so1455164vcb.20
        for <netdev@vger.kernel.org>; Wed, 26 Nov 2014 09:06:02 -0800 (PST)
In-Reply-To: <54757631.8090604@lab.ntt.co.jp>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Nov 25, 2014 at 10:41 PM, Toshiaki Makita
<makita.toshiaki@lab.ntt.co.jp> wrote:
> Hi Mahesh,
>
> I found that deleting the last ipvlan device triggers WARN_ON() in
> rtmsg_ifinfo().
> ipvlan_nl_fillinfo() seems to return -EINVAL in that case.
>
>> +static int ipvlan_nl_fillinfo(struct sk_buff *skb,
>> +                           const struct net_device *dev)
>> +{
>> +     struct ipvl_dev *ipvlan = netdev_priv(dev);
>> +     struct ipvl_port *port = ipvlan_port_get_rtnl(ipvlan->phy_dev);
>> +     int ret = -EINVAL;
>> +
>> +     if (!port)
>> +             goto err;
>> +
>> +     ret = -EMSGSIZE;
>> +     if (nla_put_u16(skb, IFLA_IPVLAN_MODE, port->mode))
>> +             goto err;
>> +
>> +     return 0;
>> +
>> +err:
>> +     return ret;
>> +}
>
> rollback_registered_many() calls rtmsg_ifinfo() after calling ndo_uninit().
> ndo_uninit() (ipvlan_uninit() -> ipvlan_port_destroy() ->
> netdev_rx_handler_unregister()) sets rx_handler_data into NULL.
> So, we cannot dereference "port" in ipvlan_nl_fillinfo().
>
Calling fillinfo() after calling uninit() seems pointless on any
device. But how are you hitting this case? Can you share the command
sequence with me?

Thanks,
--mahesh..

> Maybe "mode" should belong to struct ipvl_dev?
>
> Thanks,
> Toshiaki Makita
>
