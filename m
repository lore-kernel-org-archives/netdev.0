From: Pravin Shelar <pshelar@nicira.com>
Subject: Re: [PATCH 2/2] openvswitch: Enable tunnel GSO for OVS bridge.
Date: Thu, 12 Jun 2014 08:41:09 -0700
Message-ID: <CALnjE+qqNcRC2NhqCu=OpLhN3exDsSR91fyzcx8AeHvyvCRZbA@mail.gmail.com>
References: <1401017985-1574-1-git-send-email-pshelar@nicira.com>
	<CAJZOPZKhxTWP_vGYKADBc6-B4HSj-QJygdATGkd6cHqHO+PHoQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Or Gerlitz <or.gerlitz@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from na3sys009aog120.obsmtp.com ([74.125.149.140]:54249 "HELO
	na3sys009aog120.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1752950AbaFLPlK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 12 Jun 2014 11:41:10 -0400
Received: by mail-ve0-f170.google.com with SMTP id oz11so1979480veb.15
        for <netdev@vger.kernel.org>; Thu, 12 Jun 2014 08:41:09 -0700 (PDT)
In-Reply-To: <CAJZOPZKhxTWP_vGYKADBc6-B4HSj-QJygdATGkd6cHqHO+PHoQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Jun 12, 2014 at 2:27 AM, Or Gerlitz <or.gerlitz@gmail.com> wrote:
> On Sun, May 25, 2014 at 2:39 PM, Pravin B Shelar <pshelar@nicira.com> wrote:
>> Signed-off-by: Pravin B Shelar <pshelar@nicira.com>
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
>
> OK, I guess this commit is similar in spirit to 82d8189 "veth: extend
> features to support tunneling"
>
> So in that respect, don't you need to set also dev->hw_enc_features
> for the NETIF_F_GSO_YYY to come into play?

Right, I will send updated patch.
