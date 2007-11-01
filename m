From: Ben Greear <greearb@candelatech.com>
Subject: Re: expected behavior of PF_PACKET on NETIF_F_HW_VLAN_RX device?
Date: Wed, 31 Oct 2007 18:06:34 -0700
Message-ID: <4729269A.6090606@candelatech.com>
References: <18216.52455.698606.497464@zeus.sw.starentnetworks.com> <20071031123359.3954befc@freepuppy.rosehill>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Dave Johnson <djohnson+linux-kernel@sw.starentnetworks.com>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	Bin Guo <bguo@sw.starentnetworks.com>
To: Stephen Hemminger <shemminger@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ns2.lanforge.com ([66.165.47.211]:44262 "EHLO ns2.lanforge.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752080AbXKABGq (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 31 Oct 2007 21:06:46 -0400
In-Reply-To: <20071031123359.3954befc@freepuppy.rosehill>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Stephen Hemminger wrote:
> On Wed, 31 Oct 2007 14:43:51 -0400
> Dave Johnson <djohnson+linux-kernel@sw.starentnetworks.com> wrote:
>
>   
>> Depending on the network driver, I'm seeing different behavior if
>> a .1q packet is received to an PF_PACKET, SOCK_RAW, ETH_P_ALL socket.
>>
>>
>> On devices what do not use NETIF_F_HW_VLAN_RX, the packet socket gets
>> the complete packet with vlan tag included as the driver simply calls
>> netif_receive_skb() or equivilant.  packet_rcv() then gets the whole
>> thing vlan tag included and sends this through the socket.
>>
>> vlan_skb_recv() also gets these all and will drop them because there
>> are no vlans configured.
>>
>>     
>
> The VLAN acceleration grabs and hides the tag. It is a design flaw
> that should be fixed, feel free to post a patch.
>   
There may be several ways to 'fix' this.  Perhaps it would be worth 
discussing what
we want the end result to be at least?

Should we always pass the vlan header up to raw sockets as part of the
data payload?

Or, maybe pass it in an auxiliary message such as how timestamps may be 
passed?

The first option seems cleaner, but maybe there are performance problems 
with this
approach?

We should also define what a NIC should do with VLANs it doesn't 
explicitly know
about.   I think it should pass them up the stack with VLAN tag intact, 
but again, perhaps
there are reasons not to do that?

DaveM did the HW Accel for VLANs if I remember correctly...perhaps he 
has some input?

Thanks,
Ben

-- 
Ben Greear <greearb@candelatech.com> 
Candela Technologies Inc  http://www.candelatech.com


