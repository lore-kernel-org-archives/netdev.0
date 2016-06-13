From: Tom Herbert <tom@herbertland.com>
Subject: Re: [net-next PATCH 02/15] net: Merge VXLAN and GENEVE push notifiers
 into a single notifier
Date: Mon, 13 Jun 2016 12:31:26 -0700
Message-ID: <CALx6S35MsGtRyxYiOi389w05v8y=pG6fXZC3spj8OZKDTeh=Cg@mail.gmail.com>
References: <20160613173750.15186.24381.stgit@localhost.localdomain>
	<20160613174806.15186.64702.stgit@localhost.localdomain>
	<77eb25b2-d775-ec6f-c945-524d73113c96@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Alexander Duyck <aduyck@mirantis.com>,
	Linux Kernel Network Developers <netdev@vger.kernel.org>,
	intel-wired-lan <intel-wired-lan@lists.osuosl.org>,
	Jesse Gross <jesse@kernel.org>, Jiri Benc <jbenc@redhat.com>,
	Alexander Duyck <alexander.duyck@gmail.com>,
	Saeed Mahameed <saeedm@mellanox.com>, ariel.elior@qlogic.com,
	Dept-GELinuxNICDev@qlogic.com,
	"David S. Miller" <davem@davemloft.net>, eugenia@mellanox.com
To: Hannes Frederic Sowa <hannes@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f193.google.com ([209.85.223.193]:36694 "EHLO
	mail-io0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1422720AbcFMTb1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 13 Jun 2016 15:31:27 -0400
Received: by mail-io0-f193.google.com with SMTP id o127so15232428iod.3
        for <netdev@vger.kernel.org>; Mon, 13 Jun 2016 12:31:27 -0700 (PDT)
In-Reply-To: <77eb25b2-d775-ec6f-c945-524d73113c96@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Jun 13, 2016 at 10:57 AM, Hannes Frederic Sowa
<hannes@redhat.com> wrote:
> Hi Alex,
>
> very cool series!
>
> On 13.06.2016 19:48, Alexander Duyck wrote:
>> diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
>> index d101e4d904ba..e959b6348f91 100644
>> --- a/include/linux/netdevice.h
>> +++ b/include/linux/netdevice.h
>> @@ -1269,6 +1269,14 @@ struct net_device_ops {
>>       void                    (*ndo_del_geneve_port)(struct  net_device *dev,
>>                                                      sa_family_t sa_family,
>>                                                      __be16 port);
>> +     void                    (*ndo_add_udp_enc_port)(struct  net_device *dev,
>> +                                                    sa_family_t sa_family,
>> +                                                    __be16 port,
>> +                                                    unsigned int type);
>> +     void                    (*ndo_del_udp_enc_port)(struct  net_device *dev,
>> +                                                    sa_family_t sa_family,
>> +                                                    __be16 port,
>> +                                                    unsigned int type);
>>       void*                   (*ndo_dfwd_add_station)(struct net_device *pdev,
>>                                                       struct net_device *dev);
>>       void                    (*ndo_dfwd_del_station)(struct net_device *pdev,
>
> What do you think about adding a struct as argument to
> ndo_*_udp_enc_port? As a result we can much easier add new fields in
> case future NICs allow us to e.g. specify a bound ip address?
>
This is why I think we should be using ntuple filtering for
encapsulation instead perpetuating the notion that encapsulation
offload can only be done based on receive ports.

Tom

> Thanks,
> Hannes
>
