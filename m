From: Arvid Brodin <arvid.brodin@enea.com>
Subject: Re: bridge: HSR support
Date: Fri, 28 Oct 2011 17:34:18 +0200
Message-ID: <4EAACB7A.4090207@enea.com>
References: <4E948A04.8060400@enea.com> <20111011112821.28cd3e51@nehalam.linuxnetplumber.net> <4E94D67A.9060207@enea.com> <4EA5738B.8080008@enea.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Arvid Brodin <arvid.brodin@enea.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sestofw01.enea.se ([192.36.1.252]:13219 "HELO mx-3.enea.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with SMTP
	id S932447Ab1J1PeV (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 28 Oct 2011 11:34:21 -0400
In-Reply-To: <4EA5738B.8080008@enea.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Arvid Brodin wrote:
> Stephen Hemminger wrote:
>> On Tue, 11 Oct 2011 20:25:08 +0200
>> Arvid Brodin <arvid.brodin@enea.com> wrote:
>>
>>> Hi,
>>>
>>> I want to add support for HSR ("High-availability Seamless Redundancy",
>>> IEC-62439-3) to the bridge code. With HSR, all connected units have two network
>>> ports and are connected in a ring. All new Ethernet packets are sent on both
>>> ports (or passed through if the current unit is not the originating unit). The
>>> same packet is never passed twice. Non-HSR units are not allowed in the ring.
>>>
>>> This gives instant, reconfiguration-free failover.
>>>
*snip*
> 
> I need to do two things:
> 
> 1) Bind two network interfaces into one (say, eth0 & eth1 => hsr0). Frames sent on
>    hsr0 should get an HSR tag (including the correct EtherType) and go out on both
>    eth0 and eth1.
> 
> 2) Ingress frames on eth0 & eth1, with EtherType 0x88fb, should be captured and 
>    handled specially (either received on hsr0 or forwarded to the other bound 
>    physical interface).
> 
> Any ideas on the best way to implement this -- what's the nicest place to "hook
> into" for this?
> 

Ok, so after a lot of reading and looking through code I have this idea of a
standalone solution:

1) Add ioctls to create (and remove) "hsr" netdevs which encapsulates two
   physical Ethernet interfaces each (somewhat like the bridge code does, but
   with precisely 2 interfaces slaved).

2) Use dev_add_pack() to register protocol ("EtherType") 0x88FB. The device
   that the frames come in on are checked for being a slave to a hsr netdev,
   and handled accordingly.

It would be great to get some input on the sanity of this solution before I get
too much time invested in it!


Thanks,
-- 
Arvid Brodin
Enea Services Stockholm AB
