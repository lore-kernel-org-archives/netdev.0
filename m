From: Alexander Duyck <alexander.duyck@gmail.com>
Subject: Re: [net-next PATCH 02/15] net: Merge VXLAN and GENEVE push notifiers
 into a single notifier
Date: Mon, 13 Jun 2016 12:47:39 -0700
Message-ID: <CAKgT0Ufd_BNSLrJUqN-eWjytf0aD2w_LVWFD7E1ym+A0jRhCtA@mail.gmail.com>
References: <20160613173750.15186.24381.stgit@localhost.localdomain>
 <20160613174806.15186.64702.stgit@localhost.localdomain> <77eb25b2-d775-ec6f-c945-524d73113c96@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Alexander Duyck <aduyck@mirantis.com>,
	Netdev <netdev@vger.kernel.org>,
	intel-wired-lan <intel-wired-lan@lists.osuosl.org>,
	Jesse Gross <jesse@kernel.org>, Jiri Benc <jbenc@redhat.com>,
	Saeed Mahameed <saeedm@mellanox.com>,
	Ariel Elior <ariel.elior@qlogic.com>,
	Tom Herbert <tom@herbertland.com>,
	Dept-GELinuxNICDev@qlogic.com, David Miller <davem@davemloft.net>,
	Eugenia Emantayev <eugenia@mellanox.com>
To: Hannes Frederic Sowa <hannes@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-it0-f65.google.com ([209.85.214.65]:35122 "EHLO
	mail-it0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1423023AbcFMTrq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 13 Jun 2016 15:47:46 -0400
Received: by mail-it0-f65.google.com with SMTP id e5so8531214ith.2
        for <netdev@vger.kernel.org>; Mon, 13 Jun 2016 12:47:40 -0700 (PDT)
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

Actually that is probably a good idea.  Suggestions on the name are
welcome.  Otherwise I will try to come up with something in a bit as I
am currently going through and flushing out all the driver specific
VXLAN and GENEVE build flags.

- Alex
