From: Florian Fainelli <f.fainelli@gmail.com>
Subject: NFS over NAT causes e1000e transmit hangs
Date: Tue, 18 Apr 2017 11:18:17 -0700
Message-ID: <42af0e78-3107-1605-f8e1-d73a8c441ff0@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8bit
Cc: netdev@vger.kernel.org
To: intel-wired-lan@lists.osuosl.org, jeffrey.t.kirsher@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wr0-f195.google.com ([209.85.128.195]:34246 "EHLO
        mail-wr0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750710AbdDRSSW (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 18 Apr 2017 14:18:22 -0400
Received: by mail-wr0-f195.google.com with SMTP id u18so130593wrc.1
        for <netdev@vger.kernel.org>; Tue, 18 Apr 2017 11:18:21 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

I am using NFS over a NAT with two e1000e adapters and with eth1 being
the LAN interface and eth0 the WAN interface. The kernel is Ubuntu's
16.10 kernel: 4.8.0-46-generic. The device doing NAT over NFS is just
mounting a remote folder and doing normal execution/file accesses. It's
enough to untar a file from this device onto a NFS share to expose the
problem.

The transmit hangs look like the ones below, doing a rmmod/insmod does
not help eliminated the problem, nor does a power cycle. Stopping the
NFS over NAT definitively does let the adapter recover.

Happy to test any patches/newer kernels if you think there is something
obviously wrong. It *seems* to have started when I updated to 4.8.x, and
I was not able to see this under 4.4, so first things could be to try a
bisection, time permitting.

The two devices involved in the NAT are:

fainelli@fainelli-desktop:[~/../linux]$ lspci -s 0000:09:00.0 -v
09:00.0 Ethernet controller: Intel Corporation 82574L Gigabit Network
Connection
        Subsystem: Intel Corporation Gigabit CT Desktop Adapter
        Flags: bus master, fast devsel, latency 0, IRQ 17
        Memory at ef6c0000 (32-bit, non-prefetchable) [size=128K]
        Memory at ef600000 (32-bit, non-prefetchable) [size=512K]
        I/O ports at b000 [size=32]
        Memory at ef6e0000 (32-bit, non-prefetchable) [size=16K]
        Expansion ROM at ef680000 [disabled] [size=256K]
        Capabilities: <access denied>
        Kernel driver in use: e1000e
        Kernel modules: e1000e

fainelli@fainelli-desktop:[~/../linux]$ lspci -s 0000:00:19.0 -v
00:19.0 Ethernet controller: Intel Corporation 82579LM Gigabit Network
Connection (rev 05)
        Subsystem: Dell 82579LM Gigabit Network Connection
        Flags: bus master, fast devsel, latency 0, IRQ 43
        Memory at ef900000 (32-bit, non-prefetchable) [size=128K]
        Memory at ef929000 (32-bit, non-prefetchable) [size=4K]
        I/O ports at f040 [size=32]
        Capabilities: <access denied>
        Kernel driver in use: e1000e
        Kernel modules: e1000e

[516481.589090] e1000e 0000:00:19.0 eth0: Detected Hardware Unit Hang:
                  TDH                  <9b>
                  TDT                  <b0>
                  next_to_use          <b0>
                  next_to_clean        <96>
                buffer_info[next_to_clean]:
                  time_stamp           <107b0fc76>
                  next_to_watch        <9b>
                  jiffies              <107b10048>
                  next_to_watch.status <0>
                MAC Status             <40080083>
                PHY Status             <796d>
                PHY 1000BASE-T Status  <3c00>
                PHY Extended Status    <3000>
                PCI Status             <10>
[516483.573120] e1000e 0000:00:19.0 eth0: Detected Hardware Unit Hang:
                  TDH                  <9b>
                  TDT                  <b0>
                  next_to_use          <b0>
                  next_to_clean        <96>
                buffer_info[next_to_clean]:
                  time_stamp           <107b0fc76>
                  next_to_watch        <9b>
                  jiffies              <107b10238>
                  next_to_watch.status <0>
                MAC Status             <40080083>
                PHY Status             <796d>
                PHY 1000BASE-T Status  <3c00>
                PHY Extended Status    <3000>
                PCI Status             <10>
[516485.589452] e1000e 0000:00:19.0 eth0: Detected Hardware Unit Hang:
                  TDH                  <9b>
                  TDT                  <b0>
                  next_to_use          <b0>
                  next_to_clean        <96>
                buffer_info[next_to_clean]:
                  time_stamp           <107b0fc76>
                  next_to_watch        <9b>
                  jiffies              <107b10430>
                  next_to_watch.status <0>
                MAC Status             <40080083>
                PHY Status             <796d>
                PHY 1000BASE-T Status  <3c00>
                PHY Extended Status    <3000>
                PCI Status             <10>
[516487.573397] e1000e 0000:00:19.0 eth0: Detected Hardware Unit Hang:
                  TDH                  <9b>
                  TDT                  <b0>
                  next_to_use          <b0>
                  next_to_clean        <96>
                buffer_info[next_to_clean]:
                  time_stamp           <107b0fc76>
                  next_to_watch        <9b>
                  jiffies              <107b10620>
                  next_to_watch.status <0>
                MAC Status             <40080083>
                PHY Status             <796d>
                PHY 1000BASE-T Status  <3c00>
                PHY Extended Status    <3000>
                PCI Status             <10>
[516487.700509] e1000e 0000:00:19.0 eth0: Reset adapter unexpectedly
[516491.526799] e1000e: eth0 NIC Link is Up 1000 Mbps Full Duplex, Flow
Control: Rx/Tx

Thanks for reading, here is a virtual potato: 0.
-- 
Florian
