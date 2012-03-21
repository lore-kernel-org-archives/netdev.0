From: John Fastabend <john.r.fastabend@intel.com>
Subject: Re: [net-next PATCH v0 1/5] net: add generic PF_BRIDGE:RTM_ FDB hooks
Date: Tue, 20 Mar 2012 17:53:17 -0700
Message-ID: <4F69267D.4050500@intel.com>
References: <CB8E57D1.494C3%roprabhu@cisco.com> <4F6921D6.9090306@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Roopa Prabhu <roprabhu@cisco.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([143.182.124.21]:25164 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1759193Ab2CUAyS (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 20 Mar 2012 20:54:18 -0400
In-Reply-To: <4F6921D6.9090306@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 3/20/2012 5:33 PM, John Fastabend wrote:
> On 3/20/2012 3:50 PM, Roopa Prabhu wrote:
>>
>>> On 3/18/12 11:51 PM, "John Fastabend" <john.r.fastabend@intel.com> wrote:
>>>
>>>> This adds two new flags NTF_MASTER and NTF_LOWERDEV that can
>>>> now be used to specify where PF_BRIDGE netlink commands should
>>>> be sent. NTF_MASTER sends the commands to the 'dev->master'
>>>> device for parsing. Typically this will be the linux net/bridge,
>>>> macvlan, or open-vswitch devices. Also without any flags set
>>>> the command will be handled by the master device as well so
>>>> that current user space tools continue to work as expected.
>>
> [...]
> 
>>  
>> Sorry John for getting back on this very late.
>> Am trying to see how this will work for macvlan.
>>  
>>  Am wondering if the below is how you think might work,
>>  - macvlan implements ndo_fdb_add, del, dump
>>  - macvlan_fdb_add {
>>       if (macvlan passthrough mode) {
>>          if (lowerdev->ndo_fdb_add) {
>>              lowerdev->ndo_fdb_add(addr) with NTF_LOWERDEV
>>          }
>>          else {
>>              /* This is because, we don't want all devices to have to
>>                 implement ndo_fdb_add. Eg Devices without an embedded bridge
>>                 */.
>>              dev_uc_add_excl(lowerdev, addr)
>>          }
>>    }
>>  
>>  Let me see if I can write a sample patch.
>>  
> 
> Yes this is what I expect. I'll post the sample patch I've been
> working with here in just a second. The tricky part is dealing
> with the promisc mode. In your previous series you just removed
> doesn't seem correct to me because we already have a precedent
> set i.e. macvlan passthru comes up in promisc mode and doesn't
> require any filters.
> 
> .John

ah dang that msg won't hit netdev because I stupidly named the
patch with three Xs.

but to follow up yes NTF_SELF seems like a better name. I'll
change it when I submit again after net-next opens up and
I also posted my RFC for macvlan feel free to use that as a
starting point if it works for you.

Thanks,
.John
