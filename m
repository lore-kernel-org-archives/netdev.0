From: Pravin Shelar <pshelar@nicira.com>
Subject: Re: [PATCH 2/2] openvswitch: Enable tunnel GSO for OVS bridge.
Date: Mon, 30 Jun 2014 16:37:13 -0700
Message-ID: <CALnjE+qTN6PN38MJWc9iFEMFQs73ejoSQtW=NQ0GXaMn6nrTtQ@mail.gmail.com>
References: <1401017985-1574-1-git-send-email-pshelar@nicira.com>
	<CAJZOPZLDhqkosAVty2TpOx5JrkTwVdn2JhMNY8Jti2pu6jU9xQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Tom Herbert <therbert@google.com>
To: Or Gerlitz <or.gerlitz@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from na3sys009aog116.obsmtp.com ([74.125.149.240]:39148 "HELO
	na3sys009aog116.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1751881AbaF3XhO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 30 Jun 2014 19:37:14 -0400
Received: by mail-vc0-f170.google.com with SMTP id hy10so8221201vcb.15
        for <netdev@vger.kernel.org>; Mon, 30 Jun 2014 16:37:14 -0700 (PDT)
In-Reply-To: <CAJZOPZLDhqkosAVty2TpOx5JrkTwVdn2JhMNY8Jti2pu6jU9xQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Jun 30, 2014 at 2:53 PM, Or Gerlitz <or.gerlitz@gmail.com> wrote:
> On Sun, May 25, 2014 at 2:39 PM, Pravin B Shelar <pshelar@nicira.com> wrote:
>>
>> Signed-off-by: Pravin B Shelar <pshelar@nicira.com>
>
>
>
> Hi Pravin, ping... this addresses a real life use case where offloads
> didn't come into play, right? can you respin the patch with non-empty
> change-log so people can review/ack it? --> and we'll have upstream
> support for that case.
>
This patch is blocked by double encap issue. You can read mail thread
on first patch http://marc.info/?l=linux-netdev&m=140236173911474&w=2

Tom is going to fix GSO for packets with multiple encapsulations.
After that it would be safe to enable tunnel offloading features for
OVS.

Thanks,
Pravin.

> Or.
>
>
>
>>
>> ---
>>  include/linux/netdev_features.h      | 4 ++++
>>  net/openvswitch/vport-internal_dev.c | 3 ++-
>>  2 files changed, 6 insertions(+), 1 deletion(-)
>>
>> diff --git a/include/linux/netdev_features.h b/include/linux/netdev_features.h
>> index e5a5894..12118a5 100644
>> --- a/include/linux/netdev_features.h
>> +++ b/include/linux/netdev_features.h
>> @@ -152,6 +152,10 @@ enum {
>>  #define NETIF_F_ALL_FCOE       (NETIF_F_FCOE_CRC | NETIF_F_FCOE_MTU | \
>>                                  NETIF_F_FSO)
>>
>> +#define NETIF_F_ALL_ENCAP_GSO   (NETIF_F_GSO_GRE | NETIF_F_GSO_GRE_CSUM | \
>> +                                NETIF_F_GSO_IPIP | NETIF_F_GSO_SIT |     \
>> +                                NETIF_F_GSO_UDP_TUNNEL | NETIF_F_GSO_MPLS)
>> +
>>  /*
>>   * If one device supports one of these features, then enable them
>>   * for all in netdev_increment_features.
>> diff --git a/net/openvswitch/vport-internal_dev.c b/net/openvswitch/vport-internal_dev.c
>> index 789af92..b971610 100644
>> --- a/net/openvswitch/vport-internal_dev.c
>> +++ b/net/openvswitch/vport-internal_dev.c
>> @@ -134,7 +134,8 @@ static void do_setup(struct net_device *netdev)
>>         netdev->tx_queue_len = 0;
>>
>>         netdev->features = NETIF_F_LLTX | NETIF_F_SG | NETIF_F_FRAGLIST |
>> -                          NETIF_F_HIGHDMA | NETIF_F_HW_CSUM | NETIF_F_GSO_SOFTWARE;
>> +                          NETIF_F_HIGHDMA | NETIF_F_HW_CSUM | NETIF_F_GSO_SOFTWARE |
>> +                          NETIF_F_ALL_ENCAP_GSO;
>>
>>         netdev->vlan_features = netdev->features;
>>         netdev->features |= NETIF_F_HW_VLAN_CTAG_TX;
>> --
>> 1.9.1
>>
>> --
>> To unsubscribe from this list: send the line "unsubscribe netdev" in
>> the body of a message to majordomo@vger.kernel.org
>> More majordomo info at  http://vger.kernel.org/majordomo-info.html
