From: "Avuton Olrich" <avuton@gmail.com>
Subject: Re: Realtek RTL-8169 having receive errors
Date: Tue, 25 Mar 2008 15:51:44 -0700
Message-ID: <3aa654a40803251551ka5e6287uab79d99626e75ae2@mail.gmail.com>
References: <3aa654a40803241717g218f3d51pec42ecbb29835248@mail.gmail.com>
	 <20080325221050.GA2277@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: "Francois Romieu" <romieu@fr.zoreil.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ug-out-1314.google.com ([66.249.92.173]:36099 "EHLO
	ug-out-1314.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754118AbYCYWvq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 25 Mar 2008 18:51:46 -0400
Received: by ug-out-1314.google.com with SMTP id z38so2552094ugc.16
        for <netdev@vger.kernel.org>; Tue, 25 Mar 2008 15:51:45 -0700 (PDT)
In-Reply-To: <20080325221050.GA2277@electric-eye.fr.zoreil.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Mar 25, 2008 at 3:10 PM, Francois Romieu <romieu@fr.zoreil.com> wrote:
> Avuton Olrich <avuton@gmail.com> :
>  [...]
>
> > On my production server, I recently updated to the latest git at the
>  > time and I'm getting receive errors. I'd like to try to minimize the
>  > resets, but I'd also like to help track down this problem. Is there a
>  > way I can debug this, rather then downgrading back to 2.6.22.x (the
>  > stable kernels in between didn't work for different reasons). Thanks!
>  [...]
>
> > On device:
>  > eth1      Link encap:Ethernet  HWaddr 00:14:85:35:CE:4D
>  >           inet addr:10.0.0.1  Bcast:10.0.0.0  Mask:255.255.0.0
>  >           UP BROADCAST RUNNING MULTICAST  MTU:1500  Metric:1
>  >           RX packets:101004007 errors:106876 dropped:0 overruns:0 frame:106876
>
>  Please increase the device verbosity level ('ethtool -s eth1 msglvl 255')
>  and send what appears in dmesg.

shapeshifter ~ # ethtool -s eth1 msglvl 255
Cannot set new msglvl: Operation not supported

Do I need something else in my config?

>  Otherwise dmesg from boot, ethtool -S output and /proc/interrupts content
>  for both a working 2.6.22.x and latest git could be interesting but they
>  may be harder to collect with a production server.

Now, these are from the currently running kernel. I can pull the
latest kernel and test it again tonight, hopefully.

shapeshifter ~ # ethtool -S eth1
NIC statistics:
     tx_bytes: 199033976570
     tx_zero_rexmt: 184258538
     tx_one_rexmt: 0
     tx_many_rexmt: 0
     tx_late_collision: 0
     tx_fifo_errors: 0
     tx_carrier_errors: 0
     tx_excess_deferral: 0
     tx_retry_error: 0
     rx_frame_error: 0
     rx_extra_byte: 0
     rx_late_collision: 0
     rx_runt: 0
     rx_frame_too_long: 0
     rx_over_errors: 0
     rx_crc_errors: 108524
     rx_frame_align_error: 0
     rx_length_error: 4
     rx_unicast: 104284558
     rx_multicast: 3356
     rx_broadcast: 7885
     rx_packets: 104295799
     rx_errors_total: 108524
     tx_errors_total: 0

shapeshifter ~ # cat /proc/interrupts
           CPU0       CPU1
  0:         42          0   IO-APIC-edge      timer
  1:          0         28   IO-APIC-edge      i8042
  7:          1          0   IO-APIC-edge
  8:          0          0   IO-APIC-edge      rtc
  9:          0          0   IO-APIC-fasteoi   acpi
 14:      27729    6124688   IO-APIC-edge      pata_amd
 15:          0          0   IO-APIC-edge      pata_amd
 16:     784752  245169854   IO-APIC-fasteoi   ahci, pata_jmicron, eth0
 17:     121196   47475173   IO-APIC-fasteoi   EMU10K1
 18:         46      17389   IO-APIC-fasteoi   firewire_ohci
 20:          0          2   IO-APIC-fasteoi   ehci_hcd:usb1
 21:      60882    3060838   IO-APIC-fasteoi   sata_nv
 22:      68106    5839827   IO-APIC-fasteoi   sata_nv
 23:    1041438  372192700   IO-APIC-fasteoi   ohci_hcd:usb2, eth1
NMI:          0          0   Non-maskable interrupts
LOC:  334766509  334766278   Local timer interrupts
RES:   50657706   18555312   Rescheduling interrupts
CAL:       5711       1594   function call interrupts
TLB:     686733     521563   TLB shootdowns
TRM:          0          0   Thermal event interrupts
THR:          0          0   Threshold APIC interrupts
SPU:          0          0   Spurious interrupts
ERR:          1

>  Trying the 2.6.23 driver with a 2.6.22.x kernel would help narrow the
>  regression too.

I can't even boot 2.6.23, so that's not doable. I will work on taking
this machine down sometime this week, if it's possible and necessary.
Thanks for the help.
--
avuton
--
 Anyone who quotes me in their sig is an idiot. -- Rusty Russell.
