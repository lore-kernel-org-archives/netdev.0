From: John Fastabend <john.fastabend@gmail.com>
Subject: Re: [PATCH net-next] net: Add phys_port identifier to struct net_device
 and export it to sysfs
Date: Fri, 21 Jun 2013 10:11:07 -0700
Message-ID: <51C4892B.8000806@gmail.com>
References: <20130617181004.GA1364@fedora-17-guest.dell.com>  <51BF59D8.10806@gmail.com>  <E31FB011129F30488D5861F383904915210BB90367@BLRX7MCDC201.AMER.DELL.COM>  <1371656194.1956.25.camel@bwh-desktop.uk.level5networks.com>  <E31FB011129F30488D5861F383904915210BB9042A@BLRX7MCDC201.AMER.DELL.COM> <1371670481.1956.105.camel@bwh-desktop.uk.level5networks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Ben Hutchings <bhutchings@solarflare.com>, netdev@vger.kernel.org,
	john.r.fastabend@intel.com
To: Narendra_K@Dell.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vb0-f50.google.com ([209.85.212.50]:41389 "EHLO
	mail-vb0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1423404Ab3FURLc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 21 Jun 2013 13:11:32 -0400
Received: by mail-vb0-f50.google.com with SMTP id w16so6104522vbb.23
        for <netdev@vger.kernel.org>; Fri, 21 Jun 2013 10:11:31 -0700 (PDT)
In-Reply-To: <1371670481.1956.105.camel@bwh-desktop.uk.level5networks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 06/19/2013 12:34 PM, Ben Hutchings wrote:
> On Thu, 2013-06-20 at 00:23 +0530, Narendra_K@Dell.com wrote:
>>> -----Original Message-----
>>> From: Ben Hutchings [mailto:bhutchings@solarflare.com]
>>> Sent: Wednesday, June 19, 2013 9:07 PM
>>> To: K, Narendra
>>> Cc: john.fastabend@gmail.com; netdev@vger.kernel.org;
>>> john.r.fastabend@intel.com
>>> Subject: Re: [PATCH net-next] net: Add phys_port identifier to struct
>>> net_device and export it to sysfs
>>>
>>> On Wed, 2013-06-19 at 07:29 -0700, Narendra_K@Dell.com wrote:
>>> [...]
>>>> 2. show_phys_port  function sees a consistent value of
>>>> 'netdev->phys_port.port_id and netdev->phys_port.port_id_len '  if
>>>> another execution path changes the value of 'netdev->phys_port.port_id
>>>> and netdev->phys_port.port_id_len '  with write_lock(&dev_base_lock)
>>>> held (similar to how dev->operstate is being changed).
>>> [...]
>>>
>>> If the physical port ID can change dynamically (I hadn't thought of that, but an
>>> embedded switch could support such reconfiguration) then any such change
>>> also needs to be announced through rtnetlink.  Actually, I think the value
>>> needs to be included in rtnetlink information anyway.
>>>
>>
>> Ok. Thank you Ben. I had not thought about this scenario.  I was
>> thinking about the reason to hold the dev_base_lock.  Do you think
>> points 1 and 2 are correct reason to hold the dev_base_lock ?
>
> I think so.
>
>> If correct,  I think the 'show_broadcast' function also needs to be
>> fixed as it is not holding the lock.
>
> I think the broadcast address should never change during the lifetime of
> a device, so it doesn't need the lock.  That might not be true for all
> layer 2 protocols though.
>
> Ben.
>

Also, do you think this will be primarily useful for partitioning
devices that expose multiple physical functions? Or do you see
a use case for SR-IOV with virtual functions as well. The pyhs_port
attribute provides a common interface for both cases which is good I
suppose in the VF case however the host can already learn this. I
gather from your original post here that you are aware of all this.

quoting:
> I was thinking about the scenario of VF0 and VF1 coming from PF0 in the host
> Network Controller 1 being direct assigned to a KVM guest via VTD and netdevices
> from VF0 and VF1 being bonded in the guest. Assuming that physical port number used
> by VF0 and VF1 is 1, additional information is needed to identify if port number 1
> is on Network controller 1 or Network controller 2. (In the host we could use
> PCI b/d/f to differentiate two Network Controllers). I think it is similar to
> hybrid guest acceleration on the VF assignment aspect.

I'm curious though why would the host/libvirt assign two VFs from the
same PF to a guest like this? Is this really a host mis-configuration
that you want a way to detect in the guest?

Thanks,
John

-- 
John Fastabend         Intel Corporation
