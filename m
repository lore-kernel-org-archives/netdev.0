From: Luca Deri <deri@ntop.org>
Subject: Re: PF_RING: Include in main line kernel?
Date: Wed, 14 Oct 2009 22:17:30 +0200
Message-ID: <8B385E10-4BE2-48A6-BDE0-0AA1A603275E@ntop.org>
References: <a07586b0910140733s1976cd05u39286de42d9fac23@mail.gmail.com> <20091014090125.535ee0dc@nehalam> <a07586b0910141002m2a9f4466j412245fdae4e5372@mail.gmail.com> <20091014123328.1ebe35ea@s6510>
Mime-Version: 1.0 (Apple Message framework v1076)
Content-Type: text/plain; charset=us-ascii; format=flowed; delsp=yes
Content-Transfer-Encoding: 7bit
Cc: Brad Doctor <brad.doctor@gmail.com>, netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from jake.unipi.it ([131.114.21.22]:41547 "EHLO jake.ntop.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S933677AbZJNUSP (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 14 Oct 2009 16:18:15 -0400
In-Reply-To: <20091014123328.1ebe35ea@s6510>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Stephen
many thanks for your feedback I appreciated it.

The reason why I decided to patch dev.c is because I wanted PF_RING to  
decide whether the packet journey shall continue or not. In other  
words with my solution PF_RING applications can decide whether the  
received packets will also be delivered to upper layers (and to other  
kernel network components). This configurable 'early packet drop'  
allows the overall performance to be significantly increased as  
received packets are not supposed to be delivered to upper layers;  
this is a typical situations for many monitoring devices.

Another reason, is that having a hook in dev.c, device drivers can  
pass PF_RING packets directly without going through the standard  
kernel mechanisms. For instance I have developed some drivers that if  
they detect the presence of PF_RING, pass received packets directly to  
PF_RING instead of going with NAPI.

These are reasons behind my design choices. However if you believe  
that my arguments are not enough, and it's better to use a different  
approach, I'm prepared to change the implementation. Please let me  
know what you want me to change in order to include PF_RING into the  
kernel source tree.

If you want to test it, for your convenience I have created a patch  
for kernel 2.6.31.3:
https://svn.ntop.org/svn/ntop/trunk/PF_RING/patches/linux-2.6.31.3-1-686-smp-PF_RING.patch.gz

Regards Luca


On Oct 14, 2009, at 9:33 PM, Stephen Hemminger wrote:

> On Wed, 14 Oct 2009 11:02:45 -0600
> Brad Doctor <brad.doctor@gmail.com> wrote:
>
>> Good point for sure. We will make the change and get back to you.
>> Thanks for the quick reply, we appreciate it very much!
>>
>> -brad
>>
>> On Wed, Oct 14, 2009 at 10:01 AM, Stephen Hemminger
>> <shemminger@vyatta.com> wrote:
>>> On Wed, 14 Oct 2009 08:33:08 -0600
>>> Brad Doctor <brad.doctor@gmail.com> wrote:
>>>
>>>> Greetings,
>>>>
>>>> On behalf of the users and developers of the PF_RING project, we  
>>>> would
>>>> like to ask consideration to include the PF_RING module in the main
>>>> line kernel.
>>>>
>>>> PF_RING (http://www.ntop.org/PF_RING.html) is a kernel module that
>>>> implements an mmap()-ed memory ring for accelerating packet capture
>>>> and for providing all the basic features a network monitoring
>>>> application needs. PF_RING includes several features such as packet
>>>> filtering, balancing across capture applications, packet reflection
>>>> (i.e. capture application can decide to bounce selected packets  
>>>> onto
>>>> an as-specified interface). Packets are filtered both using BPF and
>>>> using ACL-like rules (e.g. tcp and ports from 80 to 100). Using
>>>> PF_RING it is also possible to exploit multiple RX queues  
>>>> provided by
>>>> modern NIC adapters. PF_RING achieves a significant speedup by  
>>>> making
>>>> only one copy of the packet. Additionally, PF_RING is able to  
>>>> operate
>>>> in a capture-only installation, further increasing performance.
>>>>
>>>> PF_RING has been around since 2003 and is very mature with an  
>>>> active
>>>> contributing developer base. The developer and user community use a
>>>> mailing list (http://listgateway.unipi.it/pipermail/ntop-misc/) for
>>>> discussions and submissions. PF_RING is used in several projects,
>>>> ranging from distributions such as DD-WRT/OpenWrt to improving
>>>> performance of applications like Snort and Wireshark. Many  
>>>> commercial
>>>> companies around the world in the field of intrusion detection and
>>>> traffic analysis rely on PF_RING for accelerating their products  
>>>> and
>>>> operations.
>>>>
>>>> The PF_RING module relies on a small patch to net/core/dev.c that
>>>> intercepts when a packet is received/transmitted so that it can be
>>>> passed to the PF_RING module when present and with an active  
>>>> listener.
>>>> Other than these minor changes, all the PF_RING code is
>>>> self-contained, comprising jut two files: ring.c and ring.h.  
>>>> PF_RING
>>>> is the result of many years of research and development  
>>>> specifically
>>>> into high-speed packet capture, and is homegrown. PF_RING uses the
>>>> stock GPL license.
>>>>
>>>> We feel that PF_RING is ready to be included with the mainline  
>>>> kernel.
>>>> We are ready and eager to support PF_RING for the long term.
>>>>
>>>> Thank you in advance for your consideration!
>>>
>>> I was going to wrap pfring up for the staging tree.
>>> The code you put in network receive path is not necessary;
>>> it would be cleaner to just use existing packet type all hook, and
>>> then PF_RING could be a loadable module without having to be  
>>> compiled in.
>>>
>>> --
>>>
>
> If you want, I'll try and do it. Are there any tests other
> than just ntop?

