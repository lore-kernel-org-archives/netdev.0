From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: MACVLANs really best solution? How about a bridge with multiple bridge virtual interfaces? (was Re: [PATCH] macvlan: Support creating macvlans from macvlans)
Date: Sat, 07 Mar 2009 10:13:16 -0800
Message-ID: <m11vt9fbgj.fsf@fess.ebiederm.org>
References: <20090307211527.6e76d0b9.nanog@85d5b20a518b8f6864949bd940457dc124746ddc.nosense.org>
	<49B2A139.8040507@candelatech.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Mark Smith
	<nanog@85d5b20a518b8f6864949bd940457dc124746ddc.nosense.org>,
	Patrick McHardy <kaber@trash.net>,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	shemminger@linux-foundation.org
To: Ben Greear <greearb@candelatech.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out01.mta.xmission.com ([166.70.13.231]:42734 "EHLO
	out01.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756032AbZCGSNY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 7 Mar 2009 13:13:24 -0500
In-Reply-To: <49B2A139.8040507@candelatech.com> (Ben Greear's message of "Sat\, 07 Mar 2009 08\:30\:49 -0800")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Ben Greear <greearb@candelatech.com> writes:

> Mark Smith wrote:
>> Hi,
>>
>> Ben said,
>>   
>>> I wouldn't deny sending with wrong source mac..ethernet interfaces can do
>>> this,
>>> and mac-vlan should look as much like ethernet is possible.
>>>     
>>
>> I agree, however there's further things that mac-vlans aren't
>> currently doing as virtual ethernet interfaces that real ones do.
>> Unicast ethernet traffic sent out one mac-vlan interface with a
>> destination address of another mac-vlan interface on the same host
>> isn't delivered. mac-vlan interfaces, even though they're conceptually
>> located on the same ethernet segment, are currently isolated from each
>> other for unicast traffic.
>>   
> At least for my use, having them all blindly TX is fine.  For thousands
> of interfaces, if you did this right and also delivered all broadcast packets
> locally
> (ie, ARP), you will cause a lot of overhead, and unless you are running a
> patched
> kernel (or namespaces perhaps), you can't really communicate with yourself over
> the
> network anyway using IP.
>
> For the behaviour you want, try adding pairs of VETH interfaces and add one end
> of the veth's to the bridge.  Add a physical port to the bridge for egress.
> Since this
> can be done, I don't really see any reason to change mac-vlan significantly...
>
> If the veth/bridge thing doesn't work, then let us know, as I think that would
> be
> a bug.  I use a similar-to-veth virtual-device pair in this way and it works
> fine.

There is one scenario in which macvlans totally beat bridging veth
devices.  macvlans support the full set of stateless hardware
offloads that the hardware supports.  Whereas veth device support none
of them.

I don't think changing macvlans makes a lot of sense.  Beyond the
pain of making it work, there are the semantic differences of local
broadcast working.

Doing something so that bridges have roughly the same performance 
as macvlans would be very nice.  I think it requires advertising
most if not all stateless hardware offloads, and then implementing
them in software on the endpoints that don't support them.

I did get as far as implementing a first draft at looping packets back
locally and behaviour difference for broadcasts and multicast
differences made macvlans a bad fit.  For clean code something like
the bridge code where you don't use the original interface directly
for sending and receiving traffic seems required.

Eric
