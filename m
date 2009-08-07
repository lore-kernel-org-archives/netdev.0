From: david@lang.hm
Subject: RE: [Bridge] [PATCH] macvlan: add tap device backend
Date: Fri, 7 Aug 2009 13:17:31 -0700 (PDT)
Message-ID: <alpine.DEB.1.10.0908071313260.28013@asgard.lang.hm>
References: <0199E0D51A61344794750DC57738F58E6D6A6CD7F6@GVW1118EXC.americas.hpqcorp.net> <004f01ca1792$b24a7a90$16df6fb0$@edu> <20090807123554.7c2bc27c@nehalam> <0199E0D51A61344794750DC57738F58E6D6A6CD7FE@GVW1118EXC.americas.hpqcorp.net>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII; format=flowed
Cc: Stephen Hemminger <shemminger@vyatta.com>,
	"Paul Congdon (UC Davis)" <ptcongdon@ucdavis.edu>,
	"drobbins@funtoo.org" <drobbins@funtoo.org>,
	"'Arnd Bergmann'" <arnd@arndb.de>,
	"herbert@gondor.apana.org.au" <herbert@gondor.apana.org.au>,
	"mst@redhat.com" <mst@redhat.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"bridge@lists.linux-foundation.org"
	<bridge@lists.linux-foundation.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"ogerlitz@voltaire.com" <ogerlitz@voltaire.com>,
	"evb@yahoogroups.com" <evb@yahoogroups.com>,
	"davem@davemloft.net" <davem@davemloft.net>
To: "Fischer, Anna" <anna.fischer@hp.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.lang.hm ([64.81.33.126]:35586 "EHLO bifrost.lang.hm"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932605AbZHGUSl (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 7 Aug 2009 16:18:41 -0400
In-Reply-To: <0199E0D51A61344794750DC57738F58E6D6A6CD7FE@GVW1118EXC.americas.hpqcorp.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 7 Aug 2009, Fischer, Anna wrote:

> Subject: RE: [Bridge] [PATCH] macvlan: add tap device backend
> 
>> Subject: Re: [Bridge] [PATCH] macvlan: add tap device backend
>>
>> On Fri, 7 Aug 2009 12:10:07 -0700
>> "Paul Congdon \(UC Davis\)" <ptcongdon@ucdavis.edu> wrote:
>>
>>> Responding to Daniel's questions...
>>>
>>>> I have some general questions about the intended use and benefits
>> of
>>>> VEPA, from an IT perspective:
>>>>
>>>> In which virtual machine setups and technologies do you forsee this
>>>> interface being used?
>>>
>>> The benefit of VEPA is the coordination and unification with the
>> external network switch.  So, in environments where you are
>> needing/wanting your feature rich, wire speed, external network device
>> (firewall/switch/IPS/content-filter) to provide consistent policy
>> enforcement, and you want your VMs traffic to be subject to that
>> enforcement, you will want their traffic directed externally.  Perhaps
>> you have some VMs that are on a DMZ or clustering an application or
>> implementing a multi-tier application where you would normally place a
>> firewall in-between the tiers.
>>
>> I do have to raise the point that Linux is perfectly capable of keeping
>> up without
>> the need of an external switch.  Whether you want policy external or
>> internal is
>> a architecture decision that should not be driven by mis-information
>> about performance.
>
> VEPA is not only about enabling faster packet processing (like firewall/switch/IPS/content-filter etc) by doing this on the external switch.
>
> Due to rather low performance of software-based I/O virtualization approaches a lot of effort has recently been going into hardware-based implementations of virtual network interfaces like SRIOV NICs provide. Without VEPA, such a NIC would have to implement sophisticated virtual switching capabilities. VEPA however is very simple and therefore perfectly suited for a hardware-based implementation. So in the future, it will give you direct I/O like performance and all the capabilities your adjacent switch provides.
>

the performance overhead isn't from switching the packets, it's from 
running the firewall/IDS/etc software on the same system.

with VEPA the communications from one VM to another VM running on the same 
host will be forced to go out the interface to the datacenter switching 
fabric. The overall performance of the network link will be slightly 
slower, but it allows for other devices to be inserted into the path.

this is something that I would want available if I were to start using VMs 
for things. I don't want to have to duplicate my IDS/firewalling functions 
within each host system as well as having them as part of the switching 
fabric.

David Lang
