From: Ben Greear <greearb@candelatech.com>
Subject: Re: MACVLANs really best solution? How about a bridge with multiple
 bridge virtual interfaces? (was Re: [PATCH] macvlan: Support creating macvlans
 from macvlans)
Date: Sat, 07 Mar 2009 08:30:49 -0800
Message-ID: <49B2A139.8040507@candelatech.com>
References: <20090307211527.6e76d0b9.nanog@85d5b20a518b8f6864949bd940457dc124746ddc.nosense.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Patrick McHardy <kaber@trash.net>,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	"Eric W. Biederman" <ebiederm@xmission.com>,
	shemminger@linux-foundation.org
To: Mark Smith
	<nanog@85d5b20a518b8f6864949bd940457dc124746ddc.nosense.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.candelatech.com ([208.74.158.172]:42504 "EHLO
	ns3.lanforge.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755033AbZCGQbf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 7 Mar 2009 11:31:35 -0500
In-Reply-To: <20090307211527.6e76d0b9.nanog@85d5b20a518b8f6864949bd940457dc124746ddc.nosense.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Mark Smith wrote:
> Hi,
>
> Ben said,
>   
>> I wouldn't deny sending with wrong source mac..ethernet interfaces can 
>> do this,
>> and mac-vlan should look as much like ethernet is possible.
>>     
>
> I agree, however there's further things that mac-vlans aren't
> currently doing as virtual ethernet interfaces that real ones do.
> Unicast ethernet traffic sent out one mac-vlan interface with a
> destination address of another mac-vlan interface on the same host
> isn't delivered. mac-vlan interfaces, even though they're conceptually
> located on the same ethernet segment, are currently isolated from each
> other for unicast traffic.
>   
At least for my use, having them all blindly TX is fine.  For thousands
of interfaces, if you did this right and also delivered all broadcast 
packets locally
(ie, ARP), you will cause a lot of overhead, and unless you are running 
a patched
kernel (or namespaces perhaps), you can't really communicate with 
yourself over the
network anyway using IP.

For the behaviour you want, try adding pairs of VETH interfaces and add 
one end
of the veth's to the bridge.  Add a physical port to the bridge for 
egress.  Since this
can be done, I don't really see any reason to change mac-vlan 
significantly...

If the veth/bridge thing doesn't work, then let us know, as I think that 
would be
a bug.  I use a similar-to-veth virtual-device pair in this way and it 
works fine.

Thanks,
Ben

-- 
Ben Greear <greearb@candelatech.com> 
Candela Technologies Inc  http://www.candelatech.com


