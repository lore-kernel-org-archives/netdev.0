From: Anthony Liguori <anthony@codemonkey.ws>
Subject: Re: [PATCH] AF_VMCHANNEL address family for guest<->host communication.
Date: Mon, 15 Dec 2008 14:44:26 -0600
Message-ID: <4946C1AA.4080404@codemonkey.ws>
References: <20081214115054.4066.14557.stgit@dhcp-1-237.tlv.redhat.com>	<20081214.224436.55256593.davem@davemloft.net>	<4946717F.2090809@codemonkey.ws> <20081215.114315.165733593.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: gleb@redhat.com, netdev@vger.kernel.org,
	virtualization@lists.linux-foundation.org, kvm@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <kvm-owner@vger.kernel.org>
In-Reply-To: <20081215.114315.165733593.davem@davemloft.net>
Sender: kvm-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

David Miller wrote:
> From: Anthony Liguori <anthony@codemonkey.ws>
> Date: Mon, 15 Dec 2008 09:02:23 -0600
>
>   
>> There is already an AF_IUCV for s390.
>>     
>
> This is a scarecrow and irrelevant to this discussion.
>
> And this is exactly why I asked that any arguments in this thread
> avoid talking about virtualization technology and why it's "special."
>   

You cannot completely avoid talking about virtualization here.  I agree 
that an argument based on, "we need it for virtualization", why?, 
"virtualization!" is not sufficient.

You still didn't address my earlier question though.

What we need is a mechanism for implementing paravirtual device drivers 
in userspace.  On a modern Linux system, a lot of important things are 
done in userspace (mostly around X) so having some code in the guest's 
userspace is important.

We want this communication mechanism to be simple and reliable as we 
want to implement the backends drivers in the host userspace with 
minimum mess.

Within the guest, we need the interface to be always available and we 
need an addressing scheme that is hypervisor specific.  Yes, we can 
build this all on top of TCP/IP.  We could even build it on top of a 
serial port.  Both have their down-sides wrt reliability and complexity.

The most natural userspace interface that meets all of these 
requirements would appear to be a new socket family.  We could also use 
another userspace interface (netlink was originally proposed, a chardev 
is possible, or a virtual file system).

Do you have another recommendation?

Regards,

Anthony Liguori

> This proposed patch here is asking to add new infrastructure for
> hypervisor facilities that will be _ADDED_ and for which we have
> complete control over.
>
> Whereas the S390 folks have to deal with existing infrastructure which
> is largely outside of their control.  So if they implement access
> mechanisms for that, it's fine.
>
> I would be doing the same thing if I added a protocol socket layer for
> accessing the Niagara hypervisor virtualization channels.
>   

