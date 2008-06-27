From: Tom Quetchenbach <virtualphtn@gmail.com>
Subject: Re: s2io: packet reordering with 2.6.25.4
Date: Thu, 26 Jun 2008 17:05:35 -0700
Message-ID: <48642ECF.4090905@gmail.com>
References: <4862DEA4.8020305@gmail.com> <48635341.8010609@gmail.com> <48635708.8070100@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, ram.vepa@neterion.com,
	santosh.rastapur@neterion.com, sivakumar.subramani@neterion.com,
	sreenivasa.honnur@neterion.com
To: Jarek Poplawski <jarkao2@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from wx-out-0506.google.com ([66.249.82.228]:7360 "EHLO
	wx-out-0506.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751706AbYF0AFP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 26 Jun 2008 20:05:15 -0400
Received: by wx-out-0506.google.com with SMTP id h29so153698wxd.4
        for <netdev@vger.kernel.org>; Thu, 26 Jun 2008 17:05:14 -0700 (PDT)
In-Reply-To: <48635708.8070100@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Jarek Poplawski wrote:
> 
>> Out of curiosity: is there affinity set for eths' irqs or they are
>> balanced between cpus? (/proc/interrupts?)

No affinity set, but they're not exactly balanced either:

           CPU0       CPU1
  0:         73          0   IO-APIC-edge      timer
  1:          0          2   IO-APIC-edge      i8042
  2:          0          0    XT-PIC-XT        cascade
  8:          0          1   IO-APIC-edge      rtc
 12:          0          5   IO-APIC-edge      i8042
 25:         47      53074   IO-APIC-fasteoi   eth0
 26:         21        334   IO-APIC-fasteoi   eth1
 28:        358    1280440   IO-APIC-fasteoi   eth2 Neterion 10 Gigabit
Ethernet-SR PCI-X 2.0 DDR Adapter
NMI:          0          0   Non-maskable interrupts
LOC:     227793     227721   Local timer interrupts
RES:       6483       3213   Rescheduling interrupts
CAL:         40         31   function call interrupts
TLB:       1119        105   TLB shootdowns
TRM:          0          0   Thermal event interrupts
THR:          0          0   Threshold APIC interrupts
SPU:          0          0   Spurious interrupts
ERR:          0

Anyhow, it looks like setting CPU affinity for the card on the receiver
(echo 1 > /proc/irq/28/smp_affinity) does eliminate the reordering, at
least with UDP at up to 2.5 Gbit/s (which is as fast as iperf can spit
out packets on this machine). So, it looks like the "mystery" is solved :-)

> 
> ...and maybe ifconfig on TX side?

eth2      Link encap:Ethernet  HWaddr 00:0C:FC:00:0D:3F
          inet addr:10.4.72.3  Bcast:10.4.72.15  Mask:255.255.255.240
          UP BROADCAST RUNNING MULTICAST  MTU:1500  Metric:1
          RX packets:7 errors:0 dropped:0 overruns:0 frame:0
          TX packets:10 errors:0 dropped:0 overruns:0 carrier:0
          collisions:0 txqueuelen:1000
          RX bytes:496 (496.0 b)  TX bytes:532 (532.0 b)
          Interrupt:28

Thanks
-Tom
