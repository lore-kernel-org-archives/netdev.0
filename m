From: Mike Manning <mmanning@brocade.com>
Subject: Re: [PATCH net] vlan: Propagate MAC address changes properly
Date: Tue, 3 May 2016 16:18:42 +0100
Message-ID: <5728C152.7090007@brocade.com>
References: <5723D930.6040004@brocade.com> <572489C5.3020502@brocade.com>
 <20160503.001651.132843090236435270.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-000f0801.pphosted.com ([67.231.152.113]:49521 "EHLO
	mx0b-000f0801.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S932884AbcECPS4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 3 May 2016 11:18:56 -0400
In-Reply-To: <20160503.001651.132843090236435270.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 05/03/2016 05:16 AM, David Miller wrote:
> From: Mike Manning <mmanning@brocade.com>
> Date: Sat, 30 Apr 2016 11:32:37 +0100
> 
>> The MAC address of the physical interface is only copied to the VLAN
>> when it is first created, resulting in an inconsistency after MAC
>> address changes of only newly created VLANs having an up-to-date MAC.
>>
>> Continuing to inherit the MAC address unless explicitly changed for
>> the VLAN allows IPv6 EUI64 addresses for the VLAN to reflect the change
>> and thus for DAD to behave as expected for the given MAC.
>>
>> Signed-off-by: Mike Manning <mmanning@brocade.com>
> 
> What is this code really trying to achieve?
> 
> Is it "Propagate real device MAC changes to undelying vlan device,
> but not if the user set the vlan MAC explicitly."?

Right, I will update the subject header to make this clearer

> 
> If so, implement that instead of all of these confusing tests.
> 
> If the vlan device's set_mac_address operation is ever called,
> set a boolean value in the vlan device private to true and test
> it here.
> 

Given that this information is implicit in real_dev_addr, I am reluctant
to add another member to the vlan_dev_priv data structure, especially given
that there may be a large number of VLANs. Instead I have added a variable
real_addr_in_use in vlan_sync_address() to make this clearer.
