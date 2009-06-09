From: Gil Beniamini <gil.beniamini@gmail.com>
Subject: Re: SOCK_RAW does not receive broadcast (with VLAN unless PROMISC)
Date: Tue, 9 Jun 2009 14:27:00 +0300
Message-ID: <91ac27070906090427k6f57745xc72f9fcb6801957a@mail.gmail.com>
References: <91ac27070906081105x30171bedra10d244d382a6934@mail.gmail.com>
	 <20090608.143454.161329513.davem@davemloft.net>
	 <4A2E4077.8080407@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from fg-out-1718.google.com ([72.14.220.155]:42832 "EHLO
	fg-out-1718.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755413AbZFIL1B convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 9 Jun 2009 07:27:01 -0400
In-Reply-To: <4A2E4077.8080407@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

9Jun09, The problem was seen with eth1 using driver e1000e, but also
was reproduced on 3c59x, to me it seems that the problem is not
related to a specific nic driver.
VLAN is running for other NICs, but on the application specific nic
(eth1) I use PF_PACKET (SOCK_RAW) , in order to get =A0the raw-packet
from the underlying device, and this start working again (like in
older kernel) as soon as the application set the socket to PROMISC
mode.
Thanks Gil

On Tue, Jun 9, 2009 at 1:59 PM, Patrick McHardy<kaber@trash.net> wrote:
> David Miller wrote:
>>
>> From: Gil Beniamini <gil.beniamini@gmail.com>
>> Date: Mon, 8 Jun 2009 21:05:25 +0300
>>
>>> My application is using PF_PACKET and SOCK_RAW in order to receive =
all
>>> Ethernet packets for the machine-unicast MAC plus all broadcast
>>> packets (like ARP broadcast).
>>
>>> That worked OK with kernel 2.6.20 (Ubuntu 7.04 with or without VLAN=
).
>>>
>>> Now with kernel 2.6.28 (Ubuntu 9.04) it works OK only without-VLAN,
>>> but with VLAN the application receive only packets for the
>>> machine-unicast MAC, but no broadcast (like ARP broadcast) packets,
>>> only if I set the socket to PROMISC mode, I start receive also
>>> broadcast packets.
>
> Which driver are you using? Are you sniffing on the VLAN device
> or on the underlying device?
>
>
