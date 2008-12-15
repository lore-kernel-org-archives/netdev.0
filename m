From: Jeremy Fitzhardinge <jeremy@goop.org>
Subject: Re: [PATCH] AF_VMCHANNEL address family for guest<->host	communication.
Date: Mon, 15 Dec 2008 09:45:56 -0800
Message-ID: <494697D4.6080300@goop.org>
References: <20081214115054.4066.14557.stgit@dhcp-1-237.tlv.redhat.com>	<20081214.224436.55256593.davem@davemloft.net> <4946717F.2090809@codemonkey.ws>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	kvm@vger.kernel.org, virtualization@lists.linux-foundation.org
To: Anthony Liguori <anthony@codemonkey.ws>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw.goop.org ([64.81.55.164]:57631 "EHLO mail.goop.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755411AbYLORp6 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 15 Dec 2008 12:45:58 -0500
In-Reply-To: <4946717F.2090809@codemonkey.ws>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Anthony Liguori wrote:
> David Miller wrote:
>   
>> From: Gleb Natapov <gleb@redhat.com>
>> Date: Sun, 14 Dec 2008 13:50:55 +0200
>>
>>   
>>     
>>> It is undesirable to use TCP/IP for this purpose since network
>>> connectivity may not exist between host and guest and if it exists the
>>> traffic can be not routable between host and guest for security reasons
>>> or TCP/IP traffic can be firewalled (by mistake) by unsuspecting VM user.
>>>     
>>>       
>> I don't really accept this argument, sorry.
>>     

Yes.  There's no reason why the management stack couldn't implement its 
own private idiot-proofing network for this kind of thing.

> Each of these sockets are going to be connected to a backend (to 
> implement guest<=>copy/paste for instance).  We want to implement those 
> backends in userspace and preferably in QEMU.
>
> Using some raw protocol over ethernet means you don't have reliability.  
> If you use a protocol to get reliability (like TCP), you now have to 
> implement a full TCP/IP stack in userspace or get the host kernel 
> involved.  I'd rather not get the host kernel involved from a security 
> perspective.
>   

There's nothing wrong with user-mode TCP, or you could run your TCP 
stack in a special-purpose guest if you're really paranoid.

> An inherently reliable socket transport solves the above problem while 
> keeping things simple.  Note, this is not a new concept.  There is 
> already an AF_IUCV for s390.  VMware is also developing an AF_VMCI 
> socket family.
>   

The trouble is that it presumes that the host and guest (or whoever the 
endpoints are) are on the same physical machine and will remain that 
way.  Given that live migration is a feature that people seem to like, 
then you'd end up needing to transport this protocol over a real network 
anyway - and at that point you may as well use proper TCP/IP.   The 
alternative is to say either "if you use this feature you can't migrate, 
and you can only resume on the same host", or "you can use this feature, 
and we'll work out a global namespace and proxy it over TCP for you".  
Neither seems very satisfactory.

    J
