From: "Lara Gomez, Ezequiel" <ezegomez@amazon.com>
Subject: Re: [PATCH] Enable tx timestamping on loopback and dummy
Date: Sat, 11 Mar 2017 23:37:22 +0000
Message-ID: <29A6CA32-4A02-40A3-89FB-E7E9814B5FEB@amazon.com>
References: <20170311144224.GA21305@u480fcf44e5b8574c5490.ant.amazon.com>,<13e4b635-089d-fb4b-4d73-62b807bb86e8@hartkopp.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Oliver Hartkopp <socketcan@hartkopp.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-fw-9101.amazon.com ([207.171.184.25]:44948 "EHLO
        smtp-fw-9101.amazon.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751325AbdCKXiH (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 11 Mar 2017 18:38:07 -0500
In-Reply-To: <13e4b635-089d-fb4b-4d73-62b807bb86e8@hartkopp.net>
Content-Language: en-IE
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

2 and 3 were recommendations by the checkpatch.pl script; as suggested, I'v=
e broken them down from the timestamping code and resubmitted as two separa=
te patches (on separate emails though).


> On 11 Mar 2017, at 23:17, Oliver Hartkopp <socketcan@hartkopp.net> wrote:
> =

> Hi Ezequiel,
> =

>> On 03/11/2017 03:42 PM, Ezequiel Lara Gomez wrote:
>> Also, cleanup some warnings from timestamping code.
> =

> in fact you're doing three different things here:
> =

> 1. introduce tx timestamping
> 2. silently change an include: <asm/io.h> -> <linux/io.h>
> 3. fix some whitespace and empty line issues
> =

> You'd better provide one patch for 1 & 2 and explain why 2 is needed.
> =

> Regards,
> Oliver
> =

>> =

>> This enables testing of SO_TIMESTAMPING options by targetting localhost
>> addresses.
>> =

>> Tested on qemu using txtimestamping.c from the kernel selftests.
>> =

>> Signed-off-by: Ezequiel Lara Gomez <ezegomez@amazon.com>
>> ---
>> drivers/net/dummy.c    |  1 +
>> drivers/net/loopback.c | 14 +++++++-------
>> 2 files changed, 8 insertions(+), 7 deletions(-)
>> =

>> diff --git a/drivers/net/dummy.c b/drivers/net/dummy.c
>> index 2c80611..32fdc00 100644
>> --- a/drivers/net/dummy.c
>> +++ b/drivers/net/dummy.c
>> @@ -125,6 +125,7 @@ static netdev_tx_t dummy_xmit(struct sk_buff *skb, s=
truct net_device *dev)
>>    dstats->tx_bytes +=3D skb->len;
>>    u64_stats_update_end(&dstats->syncp);
>> =

>> +    skb_tx_timestamp(skb);
>>    dev_kfree_skb(skb);
>>    return NETDEV_TX_OK;
>> }
>> diff --git a/drivers/net/loopback.c b/drivers/net/loopback.c
>> index b23b719..8bcf479 100644
>> --- a/drivers/net/loopback.c
>> +++ b/drivers/net/loopback.c
>> @@ -13,7 +13,7 @@
>>  *
>>  *        Alan Cox    :    Fixed oddments for NET3.014
>>  *        Alan Cox    :    Rejig for NET3.029 snap #3
>> - *        Alan Cox    :    Fixed NET3.029 bugs and sped up
>> + *        Alan Cox    :    Fixed NET3.029 bugs and sped up
>>  *        Larry McVoy    :    Tiny tweak to double performance
>>  *        Alan Cox    :    Backed out LMV's tweak - the linux mm
>>  *                    can't take it...
>> @@ -41,7 +41,7 @@
>> #include <linux/in.h>
>> =

>> #include <linux/uaccess.h>
>> -#include <asm/io.h>
>> +#include <linux/io.h>
>> =

>> #include <linux/inet.h>
>> #include <linux/netdevice.h>
>> @@ -74,6 +74,7 @@ static netdev_tx_t loopback_xmit(struct sk_buff *skb,
>>    struct pcpu_lstats *lb_stats;
>>    int len;
>> =

>> +    skb_tx_timestamp(skb);
>>    skb_orphan(skb);
>> =

>>    /* Before queueing this packet to netif_rx(),
>> @@ -149,8 +150,8 @@ static void loopback_dev_free(struct net_device *dev)
>> }
>> =

>> static const struct net_device_ops loopback_ops =3D {
>> -    .ndo_init      =3D loopback_dev_init,
>> -    .ndo_start_xmit=3D loopback_xmit,
>> +    .ndo_init        =3D loopback_dev_init,
>> +    .ndo_start_xmit  =3D loopback_xmit,
>>    .ndo_get_stats64 =3D loopback_get_stats64,
>>    .ndo_set_mac_address =3D eth_mac_addr,
>> };
>> @@ -170,7 +171,7 @@ static void loopback_setup(struct net_device *dev)
>>    dev->priv_flags        |=3D IFF_LIVE_ADDR_CHANGE | IFF_NO_QUEUE;
>>    netif_keep_dst(dev);
>>    dev->hw_features    =3D NETIF_F_GSO_SOFTWARE;
>> -    dev->features        =3D NETIF_F_SG | NETIF_F_FRAGLIST
>> +    dev->features        =3D NETIF_F_SG | NETIF_F_FRAGLIST
>>        | NETIF_F_GSO_SOFTWARE
>>        | NETIF_F_HW_CSUM
>>        | NETIF_F_RXCSUM
>> @@ -206,7 +207,6 @@ static __net_init int loopback_net_init(struct net *=
net)
>>    net->loopback_dev =3D dev;
>>    return 0;
>> =

>> -
>> out_free_netdev:
>>    free_netdev(dev);
>> out:
>> @@ -217,5 +217,5 @@ static __net_init int loopback_net_init(struct net *=
net)
>> =

>> /* Registered in net/core/dev.c */
>> struct pernet_operations __net_initdata loopback_net_ops =3D {
>> -       .init =3D loopback_net_init,
>> +    .init =3D loopback_net_init,
>> };
>> =

> =

Amazon Data Services Ireland Limited registered office: One Burlington Plaz=
a, Burlington Road, Dublin 4, Ireland. Registered in Ireland. Registration =
number 390566.
