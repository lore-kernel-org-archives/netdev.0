From: Brent Cook <bcook@bpointsys.com>
Subject: Re: PF_RING: Include in main line kernel?
Date: Wed, 14 Oct 2009 13:19:43 -0500
Message-ID: <200910141319.43884.bcook@bpointsys.com>
References: <a07586b0910140733s1976cd05u39286de42d9fac23@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Luca Deri <deri@ntop.org>
To: Brad Doctor <brad.doctor@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from 65-36-7-9.static.grandenetworks.net ([65.36.7.9]:33562 "EHLO
	bpointsys.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1755709AbZJNS0F (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 14 Oct 2009 14:26:05 -0400
In-Reply-To: <a07586b0910140733s1976cd05u39286de42d9fac23@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wednesday 14 October 2009 09:33:08 Brad Doctor wrote:
> Greetings,
> 
> On behalf of the users and developers of the PF_RING project, we would
> like to ask consideration to include the PF_RING module in the main
> line kernel.
> 
> PF_RING (http://www.ntop.org/PF_RING.html) is a kernel module that
> implements an mmap()-ed memory ring for accelerating packet capture
> and for providing all the basic features a network monitoring
> application needs. PF_RING includes several features such as packet
> filtering, balancing across capture applications, packet reflection
> (i.e. capture application can decide to bounce selected packets onto
> an as-specified interface). Packets are filtered both using BPF and
> using ACL-like rules (e.g. tcp and ports from 80 to 100). Using
> PF_RING it is also possible to exploit multiple RX queues provided by
> modern NIC adapters. PF_RING achieves a significant speedup by making
> only one copy of the packet. Additionally, PF_RING is able to operate
> in a capture-only installation, further increasing performance.

What is the difference between PF_RING and the existing
PACKET_RX_RING support (which is now complemented by PACKET_TX_RING). 

ggaoed makes use of both of these, though it is one of the few open-source projects I've found that do: http://code.google.com/p/ggaoed/

I've used PACKET_RX_RING with SO_ATTACH_FILTER to implement filtering via BPF code. You can also set PACKET_COPY_THRESH to filter on size, etc. Has anyone done a PF_RING/PACKET_RX_RING speed comparison? They seem feature-wise pretty similar.

> PF_RING has been around since 2003 and is very mature with an active
> contributing developer base. The developer and user community use a
> mailing list (http://listgateway.unipi.it/pipermail/ntop-misc/) for
> discussions and submissions. PF_RING is used in several projects,
> ranging from distributions such as DD-WRT/OpenWrt to improving
> performance of applications like Snort and Wireshark. Many commercial
> companies around the world in the field of intrusion detection and
> traffic analysis rely on PF_RING for accelerating their products and
> operations.
> 
> The PF_RING module relies on a small patch to net/core/dev.c that
> intercepts when a packet is received/transmitted so that it can be
> passed to the PF_RING module when present and with an active listener.
> Other than these minor changes, all the PF_RING code is
> self-contained, comprising jut two files: ring.c and ring.h. PF_RING
> is the result of many years of research and development specifically
> into high-speed packet capture, and is homegrown. PF_RING uses the
> stock GPL license.
> 
> We feel that PF_RING is ready to be included with the mainline kernel.
> We are ready and eager to support PF_RING for the long term.
> 
> Thank you in advance for your consideration!
> 
> -brad
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 
