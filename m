From: Dean Jenkins <Dean_Jenkins@mentor.com>
Subject: D-Link DUB E100 C1 not working when pinged by "ping 172.17.0.1 -c
 1 -s 1965"
Date: Wed, 17 Apr 2013 12:55:37 +0100
Message-ID: <516E8DB9.9060805@mentor.com>
References: <1366136460-30732-1-git-send-email-bigeasy@linutronix.de> <516E3EED.4000200@ti.com> <516E52EC.60901@linutronix.de> <516E6165.8050908@ti.com> <516E6538.8060804@linutronix.de> <516E7492.9090608@ti.com> <516E7E26.10603@linutronix.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
	Greg Kroah-Hartman <gregkh@suse.de>,
	Lucas Stach <dev@lynxeye.de>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay1.mentorg.com ([192.94.38.131]:53794 "EHLO
	relay1.mentorg.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S966064Ab3DQL4r (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 17 Apr 2013 07:56:47 -0400
In-Reply-To: <516E7E26.10603@linutronix.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

I think the drivers/net/usb/asix.c drivers is broken for the C1 hardware 
of the D-Link DUB E100 USB Ethernet Adapter.

I setup my ARM target board with D-Link DUB E100 C1 USB Ethernet Adapter 
by using
ifconfig eth0 172.17.0.1

On a Linux PC directly connected via an Ethernet cable to the target I do
ping 172.17.0.1 -c 1 -s 1965

but no response is received by the PC.

The ARM target generates errors such as:
[  202.519377] asix 1-2:1.0: eth0: asix_rx_fixup() Bad Header Length
[  202.525593] asix 1-2:1.0: eth0: asix_rx_fixup() Bad RX Length 1925

Note that this following ping works OK by shortening the length by 1:
ping 172.17.0.1 -c 1 -s 1964

Note that this ping test causes IP fragmentation to be used.

I am using a modified 2.6.34.13 kernel with back-ported changes for the 
ASIX driver.

I note that Linux 3.9-rc7 has an additional change to asix_rx_fixup() 
that looks helpful. I backported that commit 
8b5b6f5413e97c3e8bafcdd67553d508f4f698cd to the ARM now
ping 172.17.0.1 -c 1 -s 1965

gives the following run-time kernel errors on the ARM target and the 
ping does not work
[ 1193.872116] asix 1-2:1.0: eth0: asix_rx_fixup() Bad Header Length 
0xffff2f13, offset 6

It is possible that my back-porting is wrong or I have commits missing.

As the ping test is simple, please can anyone with a D-Link DUB E100 C1 
USB Ethernet Adapter run my ping test on any platform to see whether any 
Linux version has a working ASIX driver for this C1 hardware.

I note that the ASIX driver split into multiple files in Linux 3.6 which 
complicates back-porting.

Thanks for any observations of a working ASIX driver for this C1 
hardware variant using my ping test.

Regards,
Dean Jenkins
Mentor Graphics
