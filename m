From: =?UTF-8?B?UGF3ZcWCIFN0YXN6ZXdza2k=?= <pstaszewski@itcare.pl>
Subject: Problem wit route cache
Date: Mon, 08 Feb 2010 14:16:50 +0100
Message-ID: <4B700EC2.5090207@itcare.pl>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
To: Linux Network Development list <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from r242-20.iq.pl ([86.111.242.20]:34078 "EHLO smtp.iq.pl"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751700Ab0BHNX3 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 8 Feb 2010 08:23:29 -0500
Received: from unknown (HELO [192.168.1.100]) (itcare_pstaszewski@[95.48.69.170])
          (envelope-sender <pstaszewski@itcare.pl>)
          by smtp2.iq.pl with AES256-SHA encrypted SMTP
          for <netdev@vger.kernel.org>; 8 Feb 2010 13:16:48 -0000
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello

 From some time i have problem with route cache in linux
this is an info that i have in dmesg:

Route hash chain too long!
Adjust your secret_interval!
Route hash chain too long!
Adjust your secret_interval!
Route hash chain too long!
Adjust your secret_interval!
Route hash chain too long!
Adjust your secret_interval!
Route hash chain too long!
Adjust your secret_interval!
Route hash chain too long!
Adjust your secret_interval!
Route hash chain too long!
Adjust your secret_interval!
Route hash chain too long!
Adjust your secret_interval!
vlan0811: 9 rebuilds is over limit, route caching disabled
Route hash chain too long!
Adjust your secret_interval!

The problem is that change of  net.ipv4.route.secret_interval is change 
nothing -- no matter that i set secret_interval from dfault 3600 to 2 or 
10000 i have always the same info about route cahce is disabled.
Also i change this parameter net.ipv4.rt_cache_rebuild_count from 
default 4 to 9 and the same info - i try also change this to 12 but also 
this change nothing.

The machine that have this info is:
2x Intel(R) Xeon(R) CPU           X5450  @ 3.00GHz
12GB of RAM

Network controllers are:
04:00.0 Ethernet controller: Intel Corporation 82573E Gigabit Ethernet 
Controller (Copper) (rev 03)
05:00.0 Ethernet controller: Intel Corporation 82573L Gigabit Ethernet 
Controller

And the weird thing is that i need to set affinity for my nics to "ff" 
because when i bind network card to one cpu this cpu have always 100%

Router traffic is about 700Mbit/s RX + 700Mbit/s TX on eth0 (with 2 
tagged vlans) and the same traffic on eth1 that is untagged
This traffic is forwarded by this router.

Simple topology:

Clients<- ibgp ->  [ vlan0811@eth0 + vlan0508@eth0 - BGP process - eth1 ]<- ebgp ->  Internet Provisers

Some info about fibtrie:
  cat /proc/net/fib_triestat
Basic info: size of leaf: 40 bytes, size of tnode: 56 bytes.
Main:
         Aver depth:     2.58
         Max depth:      6
         Leaves:         297506
         Prefixes:       312472
         Internal nodes: 69968
           1: 35673  2: 14840  3: 10980  4: 4729  5: 2315  6: 956  7: 364  8: 109  9: 1  16: 1
         Pointers: 570018
Null ptrs: 202545
Total size: 36990  kB

Counters:
---------
gets = 2797832581
backtracks = 149015808
semantic match passed = 2789993308
semantic match miss = 766703
null node hit= 860359377
skipped node resize = 0

Local:
         Aver depth:     3.66
         Max depth:      4
         Leaves:         15
         Prefixes:       16
         Internal nodes: 11
           1: 8  2: 3
         Pointers: 28
Null ptrs: 3
Total size: 3  kB

Counters:
---------
gets = 2792656726
backtracks = 2185449412
semantic match passed = 5895311
semantic match miss = 0
null node hit= 818902
skipped node resize = 0


And interrupts
cat /proc/interrupts
            CPU0       CPU1       CPU2       CPU3       CPU4       CPU5       CPU6       CPU7
   0:         80         21         32         27         38         39         38         34   IO-APIC-edge      timer
   1:          0          1          0          0          0          0          1          0   IO-APIC-edge      i8042
   9:          0          0          0          0          0          0          0          0   IO-APIC-fasteoi   acpi
  14:          0          0          0          0          0          0          0          0   IO-APIC-edge      ide0
  15:          0          0          0          0          0          0          0          0   IO-APIC-edge      ide1
  20:          0          0          0          0          0          0          0          0   IO-APIC-fasteoi   uhci_hcd:usb3
  21:          0          0          0          0          0          0          0          0   IO-APIC-fasteoi   uhci_hcd:usb6
  22:          0          0          0          0          0          0          0          0   IO-APIC-fasteoi   ehci_hcd:usb1, uhci_hcd:usb5
  23:          0          0          0          0          0          0          0          0   IO-APIC-fasteoi   ehci_hcd:usb2, uhci_hcd:usb4
  29:      73903        136        135        135        134        138        136        136   PCI-MSI-edge      ahci
  30:  101136854  101509497  101627297  100701508  101684077  101870217  101154425  100604465   PCI-MSI-edge      eth0
  31:   91772747   92037311   92317341   92231065   91248484   91062342   91778136   92328099   PCI-MSI-edge      eth1
  32:          0          0          0          0          0          1          1          0   PCI-MSI-edge
  33:          0          1          0          0          0          0          0          1   PCI-MSI-edge
  34:          0          0          1          0          0          1          0          0   PCI-MSI-edge
  35:          1          0          0          1          0          0          0          0   PCI-MSI-edge
  36:          0          0          0          0          1          0          0          1   PCI-MSI-edge
  37:          1          0          0          0          0          0          1          0   PCI-MSI-edge
  38:          0          0          0          1          1          0          0          0   PCI-MSI-edge
  39:          0          1          1          0          0          0          0          0   PCI-MSI-edge
NMI:          0          0          0          0          0          0          0          0   Non-maskable interrupts
LOC:  407733660  395964025  431438426  402307801  434522968  420170984  400450633  390318324   Local timer interrupts
SPU:          0          0          0          0          0          0          0          0   Spurious interrupts
PMI:          0          0          0          0          0          0          0          0   Performance monitoring interrupts
PND:          0          0          0          0          0          0          0          0   Performance pending work
RES:      14378      15781      19276       5691      14761      13579      16846      15629   Rescheduling interrupts
CAL:        378        383         92         86        364        354         92         89   Function call interrupts
TLB:        551        577        433        272        602        543        329        683   TLB shootdowns
ERR:          0
MIS:          0




Regards
Pawel




