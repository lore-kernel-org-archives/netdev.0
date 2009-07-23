From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] be2net: Adding support for 802.1ad (q-in-q mode)
Date: Thu, 23 Jul 2009 09:23:01 -0700 (PDT)
Message-ID: <20090723.092301.115261115.davem@davemloft.net>
References: <4A6831E7.3020302@trash.net>
	<20090723100533.GB3172@serverengines.com>
	<4A6837A8.9040208@trash.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: sarveshwarb@serverengines.com, netdev@vger.kernel.org
To: kaber@trash.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:53964
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752462AbZGWQWz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 23 Jul 2009 12:22:55 -0400
In-Reply-To: <4A6837A8.9040208@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Patrick McHardy <kaber@trash.net>
Date: Thu, 23 Jul 2009 12:12:56 +0200

> Sarveshwar Bandi wrote:
>> On 23/07/09 11:48 +0200, Patrick McHardy wrote:
>>> Sarveshwar Bandi wrote:
>>>> On 23/07/09 11:25 +0200, Patrick McHardy wrote:
>>>>> adapter->vlan_grp will always be the VLAN group associated directly with
>>>>> the device, which is the group for the outer tag, not the inner one. So
>>>>> this can't properly associate packets with the correct VLAN device.
>>>>>
>>>> In this case, vid is the inner vlan id in the packet. This is also the
>>>> vlan id configured by vconfig. 
>>>
>>> So where does the outer tag come from then? Please provide an example
>>> how to configure this using Q-in-Q.
>>>
>> The outer vlan is totally transparent to the host. It is used by the NIC 
>> to demux packets across multiple pci network functions. Currently the 
>> outer vlan tags are configured on the NIC by OEM provided utilities.
> 
> I see. A proper changelog entry would have explained that and avoided
> all this confusion. Not that I think using another tool for this is a
> good solution, but no objections from a functional POV.

Using OEM tools makes no sense, there should be something like an
ethtool interface for changing this setting and appropriate changes
to the common userland tools to provide access to them.

I'm not putting this change in until there is common infrastructure
submitted to common tools to control this configuration.
