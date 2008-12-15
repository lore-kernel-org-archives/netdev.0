From: Anthony Liguori <anthony@codemonkey.ws>
Subject: Re: [PATCH] AF_VMCHANNEL address family for guest<->host communication.
Date: Mon, 15 Dec 2008 09:02:23 -0600
Message-ID: <4946717F.2090809@codemonkey.ws>
References: <20081214115054.4066.14557.stgit@dhcp-1-237.tlv.redhat.com> <20081214.224436.55256593.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: gleb@redhat.com, netdev@vger.kernel.org,
	virtualization@lists.linux-foundation.org, kvm@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <kvm-owner@vger.kernel.org>
In-Reply-To: <20081214.224436.55256593.davem@davemloft.net>
Sender: kvm-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

David Miller wrote:
> From: Gleb Natapov <gleb@redhat.com>
> Date: Sun, 14 Dec 2008 13:50:55 +0200
>
>   
>> It is undesirable to use TCP/IP for this purpose since network
>> connectivity may not exist between host and guest and if it exists the
>> traffic can be not routable between host and guest for security reasons
>> or TCP/IP traffic can be firewalled (by mistake) by unsuspecting VM user.
>>     
>
> I don't really accept this argument, sorry.
>   

I couldn't agree more.  That doesn't mean I don't think this isn't 
valuable though.

Each of these sockets are going to be connected to a backend (to 
implement guest<=>copy/paste for instance).  We want to implement those 
backends in userspace and preferably in QEMU.

Using some raw protocol over ethernet means you don't have reliability.  
If you use a protocol to get reliability (like TCP), you now have to 
implement a full TCP/IP stack in userspace or get the host kernel 
involved.  I'd rather not get the host kernel involved from a security 
perspective.

An inherently reliable socket transport solves the above problem while 
keeping things simple.  Note, this is not a new concept.  There is 
already an AF_IUCV for s390.  VMware is also developing an AF_VMCI 
socket family.

Regards,

Anthony Liguori
