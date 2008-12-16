From: Dor Laor <dlaor@redhat.com>
Subject: Re: [PATCH] AF_VMCHANNEL address family for	guest<->host	communication.
Date: Tue, 16 Dec 2008 02:01:27 +0200
Message-ID: <4946EFD7.7080606@redhat.com>
References: <20081214115054.4066.14557.stgit@dhcp-1-237.tlv.redhat.com> <20081214.224436.55256593.davem@davemloft.net> <4946717F.2090809@codemonkey.ws> <494697D4.6080300@goop.org> <4946A5E0.5080303@codemonkey.ws> <4946DF97.7070600@goop.org> <4946E36D.8060503@codemonkey.ws> <20081215235253.GB24579@ioremap.net>
Reply-To: dlaor@redhat.com
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Anthony Liguori <anthony@codemonkey.ws>,
	Jeremy Fitzhardinge <jeremy@goop.org>, netdev@vger.kernel.org,
	David Miller <davem@davemloft.net>, kvm@vger.kernel.org,
	virtualization@lists.linux-foundation.org
To: Evgeniy Polyakov <zbr@ioremap.net>
Return-path: <kvm-owner@vger.kernel.org>
In-Reply-To: <20081215235253.GB24579@ioremap.net>
Sender: kvm-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Evgeniy Polyakov wrote:
> On Mon, Dec 15, 2008 at 05:08:29PM -0600, Anthony Liguori (anthony@codemonkey.ws) wrote:
>   
>> The KVM model is that a guest is a process.  Any IO operations original 
>> from the process (QEMU).  The advantage to this is that you get very 
>> good security because you can use things like SELinux and simply treat 
>> the QEMU process as you would the guest.  In fact, in general, I think 
>> we want to assume that QEMU is guest code from a security perspective.
>>
>> By passing up the network traffic to the host kernel, we now face a 
>> problem when we try to get the data back.  We could setup a tun device 
>> to send traffic to the kernel but then the rest of the system can see 
>> that traffic too.  If that traffic is sensitive, it's potentially unsafe.
>>     
>
> You can even use unix sockets in this case, and each socket will be
> named as virtio channels names. IIRC tun/tap devices can be virtualizen
> with recent kernels, which also solves all problems of shared access.
>
> There are plenty of ways to implement this kind of functionality instead
> of developing some new protocol, which is effectively a duplication of
> what already exists in the kernel.
>
>   

Well, it is kinda pv-unix-domain-socket.
I did not understand how a standard unix domain in the guest can reach 
the host according
to your solution.

The initial implementation was some sort of pv-serial. Serial itself is 
low performing and
there is no naming services what so every. Gleb did offer the netlink 
option as a beginning
but we though a new address family would be more robust (you say too 
robust).
So by suggestion new address family what can think of it as a 
pv-unix-domain-socket.
Networking IS used since we think it is a good 'wheel'.
Indeed, David is right that instead of adding a new chunk of code we can 
re-use the
existing one. But we do have some 'new' (afraid to tell virtualization) 
problems that
might prevent us of using a standard virtual nic:
    - Even if we can teach iptables to ignore this interface, other
      3rd firewall might not obey: What if the VM is a Checkpoint firewall?
      What if the VM is windows? + using a non MS firewall?
    - Who will assign IPs for the vnic? How can I assure there is no ip 
clash?
       The standard dhcp for the other standard vnics might not be in 
our control.

So I do understand the idea of using a standard network interface. It's 
just not that simple.
So ideas to handle the above are welcomed.
Otherwise we might need to go back to serial/pv-serial approach.

btw: here are the usages/next usages of vmchannel:
VMchannel is a host-guest interface and in the future guest-guest interface.
Currently/soon it is used for
    - guest statistics
    - guest info
    - guest single sign own
    - guest log-in log-out
    - mouse channel for multiple monitors
    - cut&paste (guest-host, sometimes client-host-guest, company 
firewall blocks client-guest).
    - fencing (potentially)

tw2: without virtualization we wouldn't have new passionate issues to 
discuss about!
Cheers,
Dor
