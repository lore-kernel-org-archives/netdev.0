From: Rene Mayrhofer <rene.mayrhofer@gibraltar.at>
Subject: Re: [PATCH] sky2: only enable Vaux if capable of wakeup
Date: Fri, 4 Sep 2009 13:55:47 +0200
Message-ID: <200909041355.47389.rene.mayrhofer@gibraltar.at>
References: <4A9928C9.7000907@ring3k.org> <200908311158.57972.rene.mayrhofer@gibraltar.at> <20090903091625.2e6aff91@nehalam>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	Mike McCormack <mikem@ring3k.org>, netdev@vger.kernel.org,
	Richard Leitner <leitner@esys.at>
To: Stephen Hemminger <shemminger@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from jupiter1.gibraltar.at ([80.120.3.98]:37562 "EHLO
	mail1.gibraltar.at" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756737AbZIDL4N (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 4 Sep 2009 07:56:13 -0400
In-Reply-To: <20090903091625.2e6aff91@nehalam>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Am Donnerstag, 3. September 2009 18:16:25 schrieb Stephen Hemminger:
> While perusing vendor driver, I saw that it did not enable the Vaux
> power unless device was able to wake from lan for D3cold.
> This might help for Rene's power issue.

Unfortunately still no go:

[/etc/local]# /etc/init.d/networking restart
Reconfiguring network interfaces...[  876.000122] sky2 0000:02:00.0: error 
interrupt status=0xffffffff
[  876.007018] sky2 0000:02:00.0: PCI hardware error (0xffff)                                         
[  876.013131] sky2 0000:02:00.0: PCI Express error (0xffffffff)                                      
[  876.019542] sky2 gibsrv: ram data read parity error                                                
[  876.024972] sky2 gibsrv: ram data write parity error                                               
[  876.030507] sky2 gibsrv: MAC parity error                                                          
[  876.034979] sky2 gibsrv: RX parity error                                                           
[  876.039364] sky2 gibsrv: TCP segmentation error                                                    
[  876.044498] BUG: unable to handle kernel NULL pointer dereference at 
0000038d                      
[  876.048401] IP: [<f9822c05>] sky2_mac_intr+0x30/0xc1 [sky2]                                        
[  876.048401] *pde = 00000000                                                                        
[  876.048401] Oops: 0000 [#1] PREEMPT SMP                                                            
[  876.048401] last sysfs file: 
/sys/devices/system/cpu/cpu0/cpufreq/scaling_setspeed                 
[  876.048401] Modules linked in: sky2 xt_multiport cpufreq_userspace 
ip6t_REJECT xt_DSCP xt_length xt_mark xt_dscp xt_MARK xt_IMQ xt_CONNMARK 
xt_comment xt_policy ip6t_LOG xt_tcpudp ip6table_mangle iptable_mangle 
ip6table_filter ip6_tables sit tunnel4 8021q garp stp llc ipt_LOG xt_limit 
xt_state iptable_nat iptable_filter ip_tables x_tables dm_mod lm90 led_class 
p4_clockmod speedstep_lib freq_table tun imq nf_nat_ftp nf_nat 
nf_conntrack_ftp nf_conntrack_ipv6 nf_conntrack_ipv4 nf_conntrack 
nf_defrag_ipv4 ipv6 iTCO_wdt evdev rng_core parport_pc parport serio_raw 
processor i2c_i801 i2c_core button pcspkr intel_agp squashfs loop aufs 
exportfs nls_utf8 nls_cp437 ide_generic sd_mod ata_generic pata_acpi skge 
ata_piix ide_pci_generic ide_core thermal fan thermal_sys                                  
[  876.135785]                                                                                                                        
[  876.135785] Pid: 17610, comm: wpasupplicant Not tainted (2.6.30.5 #20)                                                             
[  876.158382] EIP: 0060:[<f9822c05>] EFLAGS: 00010286 CPU: 0                                                                         
[  876.158382] EIP is at sky2_mac_intr+0x30/0xc1 [sky2]                                                                               
[  876.158382] EAX: f9840f88 EBX: 00000001 ECX: 00000008 EDX: 000000ff                                                                
[  876.158382] ESI: 00000000 EDI: f620e180 EBP: f7137eb4 ESP: f7137e9c                                                                
[  876.158382]  DS: 0068 ES: 0068 FS: 00d8 GS: 00e0 SS: 0068                                                                          
[  876.185866] Process wpasupplicant (pid: 17610, ti=f7136000 task=f18daff0 
task.ti=f7136000)                                         
[  876.197466] Stack:                                                                                                                 
[  876.197466]  00000080 ff20e180 cf1993a7 f70fb520 ffffffff ffffffff f7137f28 f9826375                                               
[  876.210259]  c2523680 c2522a20 00000040 f620e188 c184526c 00000000 f620e180 
ffffffff                                               
[  876.216099]  cf1993a7 f70e6800 c1af8fc3 cf1993a7 f7137f04 c1845b23 cf1993a7 
c2522a20                                               
[  876.220633] Call Trace:                                                                                                            
[  876.220633]  [<f9826375>] ? sky2_poll+0x1d2/0xa09 [sky2]                                                                           
[  876.235944]  [<c184526c>] ? insert_work+0xa5/0xbf                                                                                  
[  876.235944]  [<c1af8fc3>] ? _spin_unlock_irqrestore+0x31/0x44                                                                      
[  876.247398]  [<c1845b23>] ? __queue_work+0x36/0x4d                                                                                 
[  876.247398]  [<c1a80b63>] ? __qdisc_run+0x73/0x1ca                                                                                 
[  876.258378]  [<c1a6ebc5>] ? net_rx_action+0x9e/0x1ae                                                                               
[  876.258378]  [<c1838e5e>] ? __do_softirq+0xb2/0x188                                                                                
[  876.258378]  [<c1838f73>] ? do_softirq+0x3f/0x5c                                                                                   
[  876.258378]  [<c18390fd>] ? irq_exit+0x37/0x80                                                                                     
[  876.279685]  [<c18146fa>] ? smp_apic_timer_interrupt+0x7c/0x9b                                                                     
[  876.286027]  [<c1803a31>] ? apic_timer_interrupt+0x31/0x40                                                                         
[  876.286027] Code: c7 56 53 89 d3 83 ec 0c 65 a1 14 00 00 00 89 45 f0 31 c0 
8b 74 97 3c c1 e2 07 89 d0 05 08 0f 00 00 89 55 e8 03 07 8a 10 88 55 ef <f6> 
86 8d 03 00 00 02 74 12 0f b6 c2 50 56 68 84 83 82 f9 e8 bd                                                      
[  876.286027] EIP: [<f9822c05>] sky2_mac_intr+0x30/0xc1 [sky2] SS:ESP 
0068:f7137e9c                                                  
[  876.317157] CR2: 000000000000038d                                                                                                  
[  876.329711] ---[ end trace da166dbaaae741d0 ]---                                                                                   
[  876.334933] Kernel panic - not syncing: Fatal exception in interrupt                                                               
[  876.342084] Pid: 17610, comm: wpasupplicant Tainted: G      D    2.6.30.5 
#20                                                      

Message from[  876.350143] Call Trace:
 syslogd@gibralt[  876.354354]  [<c1af5bf7>] ? printk+0x1d/0x30
ar3-esys-master [  876.360562]  [<c1af5b35>] panic+0x53/0xf8   
at Sep  4 13:55:[  876.366471]  [<c1806787>] oops_end+0x9f/0xbf
01 ...                                                         
 kernel[  876.372675]  [<c181d7ef>] no_context+0x15d/0x178     
:[  876.048401] [  876.379258]  [<c181db53>] 
__bad_area_nosemaphore+0x349/0x362
Oops: 0000 [#1] [  876.386999]  [<c197afed>] ? vsnprintf+0x2de/0x332           
PREEMPT SMP                                                                    
[  876.393669]  [<c197ada0>] ? vsnprintf+0x91/0x332                            

Message from [  876.400274]  [<c1af8fc3>] ? _spin_unlock_irqrestore+0x31/0x44
syslogd@gibralta[  876.408099]  [<c1af8fc3>] ? 
_spin_unlock_irqrestore+0x31/0x44
r3-esys-master a[  876.415929]  [<c18340f7>] ? release_console_sem+0x18b/0x1c9
t Sep  4 13:55:0[  876.423575]  [<c181db89>] bad_area_nosemaphore+0x1d/0x34
1 ...
 kernel:[  876.430916]  [<c181de56>] do_page_fault+0x10d/0x24b
[  876.048401] l[  876.437791]  [<c181dd49>] ? do_page_fault+0x0/0x24b
ast sysfs file: [  876.444668]  [<c1af945d>] error_code+0x7d/0x90
/sys/devices/sys[  876.451059]  [<c1970068>] ? blk_alloc_devt+0x59/0xb9
tem/cpu/cpu0/cpu[  876.458035]  [<f9822c05>] ? sky2_mac_intr+0x30/0xc1 [sky2]
freq/scaling_set[  876.465579]  [<f9826375>] sky2_poll+0x1d2/0xa09 [sky2]
speed

Mess[  876.472728]  [<c184526c>] ? insert_work+0xa5/0xbf
age from syslogd[  876.479407]  [<c1af8fc3>] ? 
_spin_unlock_irqrestore+0x31/0x44
@gibraltar3-esys[  876.487231]  [<c1845b23>] ? __queue_work+0x36/0x4d
-master at Sep  [  876.494009]  [<c1a80b63>] ? __qdisc_run+0x73/0x1ca
[  876.500782]  [<c1a6ebc5>] net_rx_action+0x9e/0x1ae

 kernel:[  876.[  876.507564]  [<c1838e5e>] __do_softirq+0xb2/0x188
185866] Process [  876.514244]  [<c1838f73>] do_softirq+0x3f/0x5c
wpasupplicant (p[  876.520622]  [<c18390fd>] irq_exit+0x37/0x80
id: 17610, ti=f7[  876.526807]  [<c18146fa>] 
smp_apic_timer_interrupt+0x7c/0x9b
136000 task=f18d[  876.534521]  [<c1803a31>] apic_timer_interrupt+0x31/0x40
aff0 task.ti=f71[  876.541855] Rebooting in 30 seconds..

best regards,
Rene

-- 
-------------------------------------------------
Gibraltar firewall       http://www.gibraltar.at/
