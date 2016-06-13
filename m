From: Hannes Frederic Sowa <hannes@redhat.com>
Subject: Re: [net-next PATCH 02/15] net: Merge VXLAN and GENEVE push notifiers
 into a single notifier
Date: Mon, 13 Jun 2016 23:08:19 +0200
Message-ID: <014f26d6-c747-5506-8dee-59866408c760@redhat.com>
References: <20160613173750.15186.24381.stgit@localhost.localdomain>
 <20160613174806.15186.64702.stgit@localhost.localdomain>
 <77eb25b2-d775-ec6f-c945-524d73113c96@redhat.com>
 <CAKgT0Ufd_BNSLrJUqN-eWjytf0aD2w_LVWFD7E1ym+A0jRhCtA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: Alexander Duyck <aduyck@mirantis.com>,
	Netdev <netdev@vger.kernel.org>,
	intel-wired-lan <intel-wired-lan@lists.osuosl.org>,
	Jesse Gross <jesse@kernel.org>, Jiri Benc <jbenc@redhat.com>,
	Saeed Mahameed <saeedm@mellanox.com>,
	Ariel Elior <ariel.elior@qlogic.com>,
	Tom Herbert <tom@herbertland.com>,
	Dept-GELinuxNICDev@qlogic.com, David Miller <davem@davemloft.net>,
	Eugenia Emantayev <eugenia@mellanox.com>
To: Alexander Duyck <alexander.duyck@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:53713 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1161278AbcFMVI3 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 13 Jun 2016 17:08:29 -0400
In-Reply-To: <CAKgT0Ufd_BNSLrJUqN-eWjytf0aD2w_LVWFD7E1ym+A0jRhCtA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 13.06.2016 21:47, Alexander Duyck wrote:
> On Mon, Jun 13, 2016 at 10:57 AM, Hannes Frederic Sowa
> <hannes@redhat.com> wrote:
>> Hi Alex,
>>
>> very cool series!
>>
>> On 13.06.2016 19:48, Alexander Duyck wrote:
>>> diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
>>> index d101e4d904ba..e959b6348f91 100644
>>> --- a/include/linux/netdevice.h
>>> +++ b/include/linux/netdevice.h
>>> @@ -1269,6 +1269,14 @@ struct net_device_ops {
>>>       void                    (*ndo_del_geneve_port)(struct  net_device *dev,
>>>                                                      sa_family_t sa_family,
>>>                                                      __be16 port);
>>> +     void                    (*ndo_add_udp_enc_port)(struct  net_device *dev,
>>> +                                                    sa_family_t sa_family,
>>> +                                                    __be16 port,
>>> +                                                    unsigned int type);
>>> +     void                    (*ndo_del_udp_enc_port)(struct  net_device *dev,
>>> +                                                    sa_family_t sa_family,
>>> +                                                    __be16 port,
>>> +                                                    unsigned int type);
>>>       void*                   (*ndo_dfwd_add_station)(struct net_device *pdev,
>>>                                                       struct net_device *dev);
>>>       void                    (*ndo_dfwd_del_station)(struct net_device *pdev,
>>
>> What do you think about adding a struct as argument to
>> ndo_*_udp_enc_port? As a result we can much easier add new fields in
>> case future NICs allow us to e.g. specify a bound ip address?
> 
> Actually that is probably a good idea.  Suggestions on the name are
> welcome.  Otherwise I will try to come up with something in a bit as I
> am currently going through and flushing out all the driver specific
> VXLAN and GENEVE build flags.

Hmmm... struct net_device_hw_offload, to be most generic? Maybe we can
even drop the udp_enc in the name and go completely generic:

int (*ndo_apply_offload)(..., struct hw_offload).

(enc reminded me too much at encryption)

Another idea, should we add error indications also for the future? We
can signal if a specific card was not able to enable offloading.
Different situations can be signaled: port list depleted, protocol
unsupported etc.

Might make sense for later postprocessing and signaling to user space.

Thanks,
Hannes
