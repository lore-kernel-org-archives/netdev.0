From: Don Dutile <ddutile@redhat.com>
Subject: Re: New commands to configure IOV features
Date: Fri, 20 Jul 2012 16:15:57 -0400
Message-ID: <5009BC7D.9000608@redhat.com>
References: <5003DC9B.8000706@broadcom.com>	<5005BD00.4090106@redhat.com>			<5005D45D.1040302@genband.com>		 <20120717.141153.46613285253481776.davem@davemloft.net>		 <500978C7.5050004@genband.com> <50097FBD.9080202@redhat.com>	 <1342806146.2678.31.camel@bwh-desktop.uk.solarflarecom.com>	 <5009B186.6000806@genband.com> <1342814473.2678.65.camel@bwh-desktop.uk.solarflarecom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Chris Friesen <chris.friesen@genband.com>,
	David Miller <davem@davemloft.net>, yuvalmin@broadcom.com,
	gregory.v.rose@intel.com, netdev@vger.kernel.org,
	linux-pci@vger.kernel.org
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:15062 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751985Ab2GTUQF (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 20 Jul 2012 16:16:05 -0400
In-Reply-To: <1342814473.2678.65.camel@bwh-desktop.uk.solarflarecom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 07/20/2012 04:01 PM, Ben Hutchings wrote:
> On Fri, 2012-07-20 at 13:29 -0600, Chris Friesen wrote:
>> On 07/20/2012 11:42 AM, Ben Hutchings wrote:
>>>
>>> The ethtool API is typically used for net device operations that can be
>>> largely devolved to individual drivers, and which the network stack can
>>> mostly ignore (though offload features are an historical exception to
>>> this).  It started with Ethernet link settings, but many operations are
>>> applicable (and implemented by) other types of network device.
>>
>> That (potentially) accounts for all network devices, but it leaves all
>> the other devices that could export virtual functions.
>>
>> Why should I need to use a different API to enable virtual functions on
>> my network device and my storage controller?
>
> Indeed; I was merely making the point that it would be quite valid to
> use that means for setting VF network parameters for any network device
> that supports IOV.
>
Yes, I read Ben's reply as supporting the proposition of VF enablement
at the PCI level.

>> (And why should "ethtool" or "ip" care that it's a virtual function?)
>
> VFs may be assigned to a guest which is not fully trusted by the
> hypervisor or privileged domain.  (This can sometimes be true for PFs
> too, depending on the capabilities of the hypervisor and guest OS.)
> Some configuration may therefore need to be done via a trusted PF.
>
Correct!  The security domain (for KVM) is the host, thus, the host
assignes VF attributes *before* they are given to the guest.... The guest
is just a consumer, at least that's been my experience with VF devices to date,
but I could see how an improper VF design could allow untrusted/guest
(ethtool/netlink) ops on the VF.

>> What Don and I are suggesting is that the concept of virtual functions
>> is a PCI thing, so it should be dealt with at the PCI layer.  Regardless
>> of the type of device the export of virtual functions is conceptually
>> the same thing, so it should use the same API.
>>
>> Once the device exists, then domain-specific APIs would be used to
>> configure it the same way that they would configure a physical device.
>
> To an extent, but not entirely.
>
> Currently, the assigned MAC address and (optional) VLAN tag for each
> networking VF are configured via the PF net device (though this is done
> though the rtnetlink API rather than ethtool).
Yes, through the PF, which is suppose to remain in the trusted host/hypervisor
domain.  (Do a 'man ip' on RHEL6 and look at 'ip link set'  where it then mentions
the parameter 'vf'.).

>
> Ben.
>
