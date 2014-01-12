From: sowmini varadhan <sowmini05@gmail.com>
Subject: Re: a vxlan question.
Date: Sun, 12 Jan 2014 13:38:16 -0500
Message-ID: <CACP96tR3uBQ_kizgB-WhnwA_SQ17BPc5SF9_3SPbnfWwhW0KqA@mail.gmail.com>
References: <CACP96tSOA70sAE_b-Ff6=gOySg0sHQQMRwpuNaA1n5HvgFAzSA@mail.gmail.com>
	<20140112102503.398a0047@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: netdev@vger.kernel.org, sowmini.varadhan@hp.com
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lb0-f175.google.com ([209.85.217.175]:38619 "EHLO
	mail-lb0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751570AbaALSiS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 12 Jan 2014 13:38:18 -0500
Received: by mail-lb0-f175.google.com with SMTP id w6so4696421lbh.20
        for <netdev@vger.kernel.org>; Sun, 12 Jan 2014 10:38:17 -0800 (PST)
In-Reply-To: <20140112102503.398a0047@nehalam.linuxnetplumber.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Jan 12, 2014 at 1:25 PM, Stephen Hemminger
<stephen@networkplumber.org> wrote:


> The VXLAN like all layer 2 tunnels is not allowed to respond IP packets
> in the inner header.

Ok, so I see that the other tunnels don't relay packets, but
I noticed that they do take note of  FRAG_NEEDED and
update the soft state (e.g., ipip_err)

> One of the principles of network virtualization
> is that the inner network IP space may overlap or be invalid in the
> outer IP domain. Therefore an intermediate system (like VXLAN) does
> not have a valid IP in the inner domain to send a response.

Understood. And I recognize that the other tunnel drivers
don't relay pmtu today.

 But if you have  the rfc1812 conformant 576 bytes of the offending IP
in your error, you should have enough information (vmi, mac addrs,
vlans, IP addrs) to figure out who generated this packet?

>
> Another way to look at is that VXLAN is more of L2 bridge rather
> than a L3 router.

Well I guess the difference is that this flavor of L2 bridge
does in fact reduce the mtu by adding the udp/ip header.
Thus if I was a VM talking to another VM on my own pod
(i.e, no vxlan encaps in the way), I'd have a different mtu than if
I migrated to to another ToR/pod, and ended up with a reduced
mtu (I'd need to either bump up to 1600 byte mtus so that the
VM could continue to send 1500 byte pre-encaps frames, or
figure out the reduced mtu via pmtu, no?)

At the very least, shouldn't the VTEP track the reduced mtu
(in the same way that other tunnel drivers do)?

--Sowmini
