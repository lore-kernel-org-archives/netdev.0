From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [Bugme-new] [Bug 30952] New: asix driver broken since 2.6.35
Date: Mon, 14 Mar 2011 14:43:09 -0700
Message-ID: <20110314144309.a303662f.akpm@linux-foundation.org>
References: <bug-30952-10286@https.bugzilla.kernel.org/>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: bugzilla-daemon@bugzilla.kernel.org,
	bugme-daemon@bugzilla.kernel.org, lipski.bogdan@gmail.com
To: linux-usb@vger.kernel.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([140.211.169.13]:52498 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754101Ab1CNVnc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 14 Mar 2011 17:43:32 -0400
In-Reply-To: <bug-30952-10286@https.bugzilla.kernel.org/>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


(switched to email.  Please respond via emailed reply-to-all, not via the
bugzilla web interface).

The reporter says "workaround suggested in:
https://bugzilla.kernel.org/show_bug.cgi?id=16831 seems to work well
for me as well".  That workaround appears to be "dump the kernel driver
and use the driver off the vendor's website".


On Sat, 12 Mar 2011 14:02:37 GMT
bugzilla-daemon@bugzilla.kernel.org wrote:

> https://bugzilla.kernel.org/show_bug.cgi?id=30952
> 
>            Summary: asix driver broken since 2.6.35
>            Product: Drivers
>            Version: 2.5
>     Kernel Version: 2.6.35+
>           Platform: All
>         OS/Version: Linux
>               Tree: Mainline
>             Status: NEW
>           Severity: normal
>           Priority: P1
>          Component: Network
>         AssignedTo: drivers_network@kernel-bugs.osdl.org
>         ReportedBy: lipski.bogdan@gmail.com
>         Regression: Yes
> 
> 
> Hey,
> 
> there a few reports in here logged but I am not sure if they are 100% the same,
> anyway you can close this one as duplicate if so.
> https://bugzilla.kernel.org/show_bug.cgi?id=16831
> https://bugzilla.kernel.org/show_bug.cgi?id=29082
> 
> config:
> - gentoo x64, fully updated
> - tried kernels 2.6.36/2.6.37/2.6.37.3
> - network card d-link dub-e100:
> asix 5-2:1.0: eth2: register 'asix' at usb-0000:00:1d.7-2, ASIX AX88772 USB 2.0
> Ethernet
> 
> Bus 005 Device 002: ID 2001:3c05 D-Link Corp. [hex] DUB-E100 Fast Ethernet
> [asix]
> Device Descriptor:
>   bLength                18
>   bDescriptorType         1
>   bcdUSB               2.00
>   bDeviceClass          255 Vendor Specific Class
>   bDeviceSubClass       255 Vendor Specific Subclass
>   bDeviceProtocol         0
>   bMaxPacketSize0        64
>   idVendor           0x2001 D-Link Corp. [hex]
>   idProduct          0x3c05 DUB-E100 Fast Ethernet [asix]
>   bcdDevice            0.01
>   iManufacturer           1 D-Link Corporation
>   iProduct                2 DUB-E100
>   iSerial                 3 000001
>   bNumConfigurations      1
> 
> card is connected directly to scientific atlanta epc2203 cable/voip modem for
> internet access, reason is isp locks it down to mac address and i really don't
> like calling them in case motherboard changes etc...
> 
> 
> the problem:
> 1. under 2.6.34 (tried 2.6.34-gentoo) everything seems to be well.
> 2. patch from 2.6.35/signed off by Jussi Kivilinna "[PATCH] asix: check packet
> size against mtu+ETH_HLEN instead of ETH_FRAME_LEN"
> => since this patch I am getting a lot of "asix_rx_fixup() Bad RX Length" and
> packets get dropped, under ifconfig I see RX error counter increasing for every
> message logged in dmesg, number of RX errors can shoot up easily to couple
> hundred thousands in just a few hours.
> 3. tried to revert this patch in 2.6.37.3 as it seems to be just a one-liner,
> but it looks like other patches applied to asix.c since 2.6.34 have also some
> influence. anyway when reverting this single patch the behaviour with plenty of
> error messages logged under dmesg stops and there are no RX errors logged under
> ifconfig. however it seems that after some time card starts loosing the packets
> again - i will update this report later if I have any further findings.
> 


