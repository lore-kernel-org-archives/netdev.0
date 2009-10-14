From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: PF_RING: Include in main line kernel?
Date: Wed, 14 Oct 2009 09:01:25 -0700
Message-ID: <20091014090125.535ee0dc@nehalam>
References: <a07586b0910140733s1976cd05u39286de42d9fac23@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Luca Deri <deri@ntop.org>
To: Brad Doctor <brad.doctor@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:51648 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756755AbZJNQCG (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 14 Oct 2009 12:02:06 -0400
In-Reply-To: <a07586b0910140733s1976cd05u39286de42d9fac23@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 14 Oct 2009 08:33:08 -0600
Brad Doctor <brad.doctor@gmail.com> wrote:

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
> 
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

I was going to wrap pfring up for the staging tree.
The code you put in network receive path is not necessary;
it would be cleaner to just use existing packet type all hook, and
then PF_RING could be a loadable module without having to be compiled in.

-- 
