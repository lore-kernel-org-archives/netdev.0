From: carlos@fisica.ufpr.br (Carlos Carvalho)
Subject: Re: appearing again: kernel: eth0: too many iterations (6) in
 nv_nic_irq
Date: Mon, 28 Jan 2008 23:52:50 -0200
Message-ID: <18334.34546.45174.858242@fisica.ufpr.br>
References: <18333.55687.621653.838538@fisica.ufpr.br>
	<20080128080656.1cc8a4e0@deepthought>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from fisica.ufpr.br ([200.17.209.129]:38108 "EHLO fisica.ufpr.br"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751444AbYA2Bwx (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 28 Jan 2008 20:52:53 -0500
In-Reply-To: <20080128080656.1cc8a4e0@deepthought>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Stephen Hemminger (shemminger@linux-foundation.org) wrote on 28 January 2008 08:06:
 >On Mon, 28 Jan 2008 11:32:55 -0200
 >carlos@fisica.ufpr.br (Carlos Carvalho) wrote:
 >
 >> It seems that this problem with NVidia's nic comes up more and more...
 >> From time to time we get this in the log:
 >> 
 >> Jan 27 14:43:12 duvel kernel: eth0: too many iterations (6) in nv_nic_irq.
 >> 
 >> We algo get
 >> 
 >> Jan 27 11:32:43 duvel kernel: KERNEL: assertion ((int)tcp_packets_in_flight(tp) >= 0) failed at net/ipv4/tcp_input.c (1274)
 >> 
 >> But at different moments, as shown above. Are they related? What's the
 >> meaning of the "assertion failed" one?
 >> 
 >> The messages are more likely to appear when traffic is high
 >> (>500Mb/s). This is with 2.6.22.16.
 >> 
 >> Any suggestions?
 >
 >Use NAPI which is available as configuration option in this driver.

Already in use.

 >Increase the max_interrupt_work from the ridiculously low value of 5
 >to something more larger like 15, with module parameter in
 >/etc/modprobe.d/options:
 >
 >options forcedeth max_interrupt_work=15

Will try.

 >Also, see if you motherboard supports MSI, if so add "msi=1" module parameter

It does, I have this in the config:

CONFIG_ARCH_SUPPORTS_MSI=y
CONFIG_PCI_MSI=y

How can I set these options with the driver compiled in the kernel and
not as a module? I can change the max_interrupt_work in the source but
what about msi?

Any ideas about the assertion ((int)tcp_packets_in_flight...?
