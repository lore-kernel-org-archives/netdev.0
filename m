From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: Re: expected behavior of PF_PACKET on NETIF_F_HW_VLAN_RX device?
Date: Wed, 31 Oct 2007 18:23:37 -0700
Message-ID: <47292A99.5070805@linux-foundation.org>
References: <18216.52455.698606.497464@zeus.sw.starentnetworks.com> <20071031123359.3954befc@freepuppy.rosehill> <4729269A.6090606@candelatech.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Dave Johnson <djohnson+linux-kernel@sw.starentnetworks.com>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	Bin Guo <bguo@sw.starentnetworks.com>
To: Ben Greear <greearb@candelatech.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2.linux-foundation.org ([207.189.120.14]:44229 "EHLO
	smtp2.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752540AbXKABXq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 31 Oct 2007 21:23:46 -0400
In-Reply-To: <4729269A.6090606@candelatech.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Ben Greear wrote:
> Stephen Hemminger wrote:
>> On Wed, 31 Oct 2007 14:43:51 -0400
>> Dave Johnson <djohnson+linux-kernel@sw.starentnetworks.com> wrote:
>>
>>  
>>> Depending on the network driver, I'm seeing different behavior if
>>> a .1q packet is received to an PF_PACKET, SOCK_RAW, ETH_P_ALL socket.
>>>
>>>
>>> On devices what do not use NETIF_F_HW_VLAN_RX, the packet socket gets
>>> the complete packet with vlan tag included as the driver simply calls
>>> netif_receive_skb() or equivilant.  packet_rcv() then gets the whole
>>> thing vlan tag included and sends this through the socket.
>>>
>>> vlan_skb_recv() also gets these all and will drop them because there
>>> are no vlans configured.
>>>
>>>     
>>
>> The VLAN acceleration grabs and hides the tag. It is a design flaw
>> that should be fixed, feel free to post a patch.
>>   
> There may be several ways to 'fix' this.  Perhaps it would be worth 
> discussing what
> we want the end result to be at least?
>
> Should we always pass the vlan header up to raw sockets as part of the
> data payload?
>
> Or, maybe pass it in an auxiliary message such as how timestamps may 
> be passed?
>
> The first option seems cleaner, but maybe there are performance 
> problems with this
> approach?
>
> We should also define what a NIC should do with VLANs it doesn't 
> explicitly know
> about.   I think it should pass them up the stack with VLAN tag 
> intact, but again, perhaps
> there are reasons not to do that?
>
> DaveM did the HW Accel for VLANs if I remember correctly...perhaps he 
> has some input?

The code in AF_PACKET should fix the skb before passing to user space so 
that there is
no difference between accel and non-accel hardware.  Internal choices 
shouldn't
leak to user space.  Ditto, the receive checksum offload should be fixed 
up as well.

