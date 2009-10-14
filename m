From: Luca Deri <deri@ntop.org>
Subject: Re: PF_RING: Include in main line kernel?
Date: Wed, 14 Oct 2009 21:54:26 +0200
Message-ID: <903D7FEC-34E8-4F70-ABC0-E56A3A5FBBE6@ntop.org>
References: <a07586b0910140733s1976cd05u39286de42d9fac23@mail.gmail.com> <200910141319.43884.bcook@bpointsys.com>
Mime-Version: 1.0 (Apple Message framework v1076)
Content-Type: text/plain; charset=us-ascii; format=flowed; delsp=yes
Content-Transfer-Encoding: 7bit
Cc: Brad Doctor <brad.doctor@gmail.com>, netdev@vger.kernel.org
To: Brent Cook <bcook@bpointsys.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from jake.unipi.it ([131.114.21.22]:53734 "EHLO jake.ntop.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757097AbZJNUGL (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 14 Oct 2009 16:06:11 -0400
In-Reply-To: <200910141319.43884.bcook@bpointsys.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Brent
contrary to other socket types, PF_RING allows
- packets to be filtered using both BPF and ACL-like filters
- parsing information is returned as metadata with the packet (i.e.  
you don't have to parse the packet again as it happens with BPF)
- ACL-like filters allows you to specify advanced features such as  
port ranges or packet payload match

I agree with you that PF_RING has some overlaps with PACKET_RX/ 
TX_RING, but the main idea behind PF_RING is not just to accelerate  
packet capture. For instance in PF_RING you can have actions attached  
to rules, or extend PF_RING filtering/packet handling by means of  
plugins.
For instance I have coded PF_RING plugins for parsing and filtering  
inside PF_RING protocols such as SIP, RTP, RTCP just to name a few  
that I would like to release after PF_RING kernel integration.

For all those who want to see what you can do with PF_RING, I suggest  
to read this tutorial: http://luca.ntop.org/MulticorePacketCapture.pdf

Regards Luca

PF_RING allows you to specify mutiple
On Oct 14, 2009, at 8:19 PM, Brent Cook wrote:

> On Wednesday 14 October 2009 09:33:08 Brad Doctor wrote:
>> Greetings,
>>
>> On behalf of the users and developers of the PF_RING project, we  
>> would
>> like to ask consideration to include the PF_RING module in the main
>> line kernel.
>>
>> PF_RING (http://www.ntop.org/PF_RING.html) is a kernel module that
>> implements an mmap()-ed memory ring for accelerating packet capture
>> and for providing all the basic features a network monitoring
>> application needs. PF_RING includes several features such as packet
>> filtering, balancing across capture applications, packet reflection
>> (i.e. capture application can decide to bounce selected packets onto
>> an as-specified interface). Packets are filtered both using BPF and
>> using ACL-like rules (e.g. tcp and ports from 80 to 100). Using
>> PF_RING it is also possible to exploit multiple RX queues provided by
>> modern NIC adapters. PF_RING achieves a significant speedup by making
>> only one copy of the packet. Additionally, PF_RING is able to operate
>> in a capture-only installation, further increasing performance.
>
> What is the difference between PF_RING and the existing
> PACKET_RX_RING support (which is now complemented by PACKET_TX_RING).
>
> ggaoed makes use of both of these, though it is one of the few open- 
> source projects I've found that do: http://code.google.com/p/ggaoed/
>
> I've used PACKET_RX_RING with SO_ATTACH_FILTER to implement  
> filtering via BPF code. You can also set PACKET_COPY_THRESH to  
> filter on size, etc. Has anyone done a PF_RING/PACKET_RX_RING speed  
> comparison? They seem feature-wise pretty similar.
>
>> PF_RING has been around since 2003 and is very mature with an active
>> contributing developer base. The developer and user community use a
>> mailing list (http://listgateway.unipi.it/pipermail/ntop-misc/) for
>> discussions and submissions. PF_RING is used in several projects,
>> ranging from distributions such as DD-WRT/OpenWrt to improving
>> performance of applications like Snort and Wireshark. Many commercial
>> companies around the world in the field of intrusion detection and
>> traffic analysis rely on PF_RING for accelerating their products and
>> operations.
>>
>> The PF_RING module relies on a small patch to net/core/dev.c that
>> intercepts when a packet is received/transmitted so that it can be
>> passed to the PF_RING module when present and with an active  
>> listener.
>> Other than these minor changes, all the PF_RING code is
>> self-contained, comprising jut two files: ring.c and ring.h. PF_RING
>> is the result of many years of research and development specifically
>> into high-speed packet capture, and is homegrown. PF_RING uses the
>> stock GPL license.
>>
>> We feel that PF_RING is ready to be included with the mainline  
>> kernel.
>> We are ready and eager to support PF_RING for the long term.
>>
>> Thank you in advance for your consideration!
>>
>> -brad
>> --
>> To unsubscribe from this list: send the line "unsubscribe netdev" in
>> the body of a message to majordomo@vger.kernel.org
>> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>>

