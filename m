From: Vlad Yasevich <vyasevic@redhat.com>
Subject: Re: [RFC PATCH bridge 0/5] Add basic VLAN support to bridges
Date: Thu, 30 Aug 2012 10:41:00 -0400
Message-ID: <503F7B7C.7050608@redhat.com>
References: <1345750195-31598-1-git-send-email-vyasevic@redhat.com> <20120830123724.GE20228@redhat.com> <503F6C8D.9000402@redhat.com> <20120830143457.GA21646@redhat.com>
Reply-To: vyasevic@redhat.com
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: "Michael S. Tsirkin" <mst@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:54311 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752453Ab2H3OlE (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 30 Aug 2012 10:41:04 -0400
Received: from int-mx01.intmail.prod.int.phx2.redhat.com (int-mx01.intmail.prod.int.phx2.redhat.com [10.5.11.11])
	by mx1.redhat.com (8.14.4/8.14.4) with ESMTP id q7UEf4lM005912
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=OK)
	for <netdev@vger.kernel.org>; Thu, 30 Aug 2012 10:41:04 -0400
In-Reply-To: <20120830143457.GA21646@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 08/30/2012 10:34 AM, Michael S. Tsirkin wrote:
> On Thu, Aug 30, 2012 at 09:37:17AM -0400, Vlad Yasevich wrote:
>> On 08/30/2012 08:37 AM, Michael S. Tsirkin wrote:
>>> On Thu, Aug 23, 2012 at 03:29:50PM -0400, Vlad Yasevich wrote:
>>>> This series of patches provides an ability to add VLAN IDs to the bridge
>>>> ports.  This is similar to what can be found in most switches.  The bridge
>>>> port may have any number of VLANs added to it including vlan 0 for untagged
>>>> traffic.  When vlans are added to the port, only traffic tagged with particular
>>>> vlan will forwarded over this port.  Additionally, vlan ids are added to FDB
>>>> entries and become part of the lookup.  This way we correctly identify the FDB
>>>> entry.
>>>>
>>>> There are still pieces missing.  I don't yet support adding a static fdb entry
>>>> with a particular vlan.  There is no netlink support for carrying a vlan id.
>>>>
>>>> I'd like to hear thoughts of whether this is usufull and something we should
>>>> persue.
>>>>
>>>> The default behavior ofthe bridge is unchanged if no vlans have been
>>>> configured.
>>>
>>> Overall the feature looks good, I can think of some uses
>>> for it - for example, it could become useful for VMs if
>>> we add support to tap essentially stripping tags in Xmit but maybe you
>>> could be more explicit about what you have in mind?
>>> Do you plan to add tap support as well?
>>
>> Yes,  this is something I've thought of.  Not sure if it would be at tap
>> or bridge itself.  Need to work out where best to do it.
>
> It's certainly much easier to do in tap.
> A 20 line patch should do it.
> Does stripping tags seem like something bridge should do?

I agree.  It would be easier in tap.  There also the other side of 
adding tags for outbound traffic.  This would allow auto-access like 
functionality where the guest itself doesn't know anything about vlans,
but the bridge port will add/remove vlans as appropriate.  This is on
the list of features I want to support.

-vlad

>
>>> Also - what tool support do you plan?
>>
>> the patchset includes brctl to configure, but that seems to be
>> getting deprecated.  I am working on iproute2 to add capability to
>> configure this.
>>
>>>
>>> I also found some coding style issues and some bugs in
>>> the patchset. Sent on list.
>>
>> Thanks
>> -vlad
>>
>>>
>>> Hope this helps.
>>>
