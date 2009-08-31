From: Rene Mayrhofer <rene.mayrhofer@gibraltar.at>
Subject: Re: [PATCH] sky2: Don't try to turn led off in sky2_down()
Date: Mon, 31 Aug 2009 11:58:57 +0200
Message-ID: <200908311158.57972.rene.mayrhofer@gibraltar.at>
References: <4A9928C9.7000907@ring3k.org>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Stephen Hemminger <shemminger@linux-foundation.org>,
	netdev@vger.kernel.org, Richard Leitner <leitner@esys.at>
To: Mike McCormack <mikem@ring3k.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from jupiter.gibraltar.at ([80.120.3.98]:54183 "EHLO
	mail1.gibraltar.at" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750892AbZHaJ7K (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 31 Aug 2009 05:59:10 -0400
In-Reply-To: <4A9928C9.7000907@ring3k.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Am Samstag, 29. August 2009 15:10:33 schrieb Mike McCormack:
> There are a few problems with the following line of code in sky2_down()
>
>      sky2_write16(hw, B0_Y2LED, LED_STAT_OFF);
>
>  * It doesn't specify which port's LED to turn off.
>  * We don't turn send LED_STAT_ON on in sky2_up()
>  * B0_LED is 0x0006 in the vendor driver, but 0x0005 in sky2.
>    B0_LED is right next to B0_POWER_CTRL, so this is possibly
>    accounts for the device being accidently powered down as
>    reported by Rene Mayrhofer.

With this patch applied to the net-next version from Friday, I now got this:

[~]# /etc/init.d/networking restart
Reconfiguring network interfaces...[  403.000092] sky2 0000:03:00.0: error 
interrupt status=0xffffffff
[  403.006905] sky2 0000:03:00.0: PCI hardware error (0xffff)                                         
[  403.013095] sky2 0000:03:00.0: PCI Express error (0xffffffff)                                      
[  403.019586] sky2 dmz: ram data read parity error                                                   
[  403.024814] sky2 dmz: ram data write parity error                                                  
[  403.030130] sky2 dmz: MAC parity error                                                             
[  403.034392] sky2 dmz: RX parity error                                                              
[  403.038560] sky2 dmz: TCP segmentation error                                                       
[  403.043531] BUG: unable to handle kernel NULL pointer dereference at 
0000038d                      
[  403.047392] IP: [<f8078ce0>] sky2_mac_intr+0x30/0xc1 [sky2]                                        
[  403.047392] *pde = 00000000                                                                        
[  403.047392] Thread overran stack, or stack corrupted                                               
[  403.047392] Oops: 0000 [#1] PREEMPT SMP                                                            
[  403.047392] last sysfs file: 
/sys/devices/system/cpu/cpu0/cpufreq/scaling_setspeed                 
[  403.047392] Modules linked in: xt_multiport cpufreq_userspace ip6t_REJECT 
xt_DSCP xt_length xt_mark xt_dscp xt_MARK xt_IMQ xt_CONNMARK xt_comment 
xt_policy ip6t_LOG xt_tcpudp ip6table_mangle iptable_mangle ip6table_filter 
ip6_tables sit tunnel4 8021q garp stp llc ipt_LOG xt_limit xt_state 
iptable_nat iptable_filter ip_tables x_tables dm_mod lm90 led_class p4_clockmod 
speedstep_lib freq_table tun imq nf_nat_ftp nf_nat nf_conntrack_ftp 
nf_conntrack_ipv6 nf_conntrack_ipv4 nf_conntrack nf_defrag_ipv4 ipv6 evdev 
iTCO_wdt parport_pc parport i2c_i801 i2c_core serio_raw rng_core button 
processor intel_agp pcspkr squashfs loop aufs exportfs nls_utf8 nls_cp437 
ide_generic sd_mod ata_generic pata_acpi ata_piix ide_pci_generic ide_core 
skge sky2 thermal fan thermal_sys                                  
[  403.047392]                                                                                                                        
[  403.047392] Pid: 0, comm: swapper Not tainted (2.6.30.5 #20)                                                                       
[  403.047392] EIP: 0060:[<f8078ce0>] EFLAGS: 00010286 CPU: 0                                                                         
[  403.047392] EIP is at sky2_mac_intr+0x30/0xc1 [sky2]                                                                               
[  403.047392] EAX: f8098f88 EBX: 00000001 ECX: 00000008 EDX: 000000ff                                                                
[  403.047392] ESI: 00000000 EDI: f68f5080 EBP: c1c8de3c ESP: c1c8de24                                                                
[  403.191036]  DS: 0068 ES: 0068 FS: 00d8 GS: 00e0 SS: 0068                                                                          
[  403.191036] Process swapper (pid: 0, ti=c1c8c000 task=c1c3f1d4 
task.ti=c1c8c000)                                                   
[  403.202984] Stack:                                                                                                                 
[  403.202984]  00000080 ff8f5080 4aa8b206 f70e54c0 ffffffff ffffffff c1c8deb0 f807c33b                                               
[  403.202984]  00000000 c1c8dea4 00000040 f68f5088 c184526c 00000000 f68f5080 
ffffffff                                               
[  403.202984]  00000001 f7224400 c2523140 00006497 00000001 00000000 4aa8b206 
c25229c8                                               
[  403.202984] Call Trace:                                                                                                            
[  403.202984]  [<f807c33b>] ? sky2_poll+0x1d2/0xa07 [sky2]                                                                           
[  403.202984]  [<c184526c>] ? insert_work+0xa5/0xbf                                                                                  
[  403.202984]  [<c1af8f7f>] ? _spin_unlock_irq+0x2f/0x42                                                                             
[  403.202984]  [<c1a6ebc5>] ? net_rx_action+0x9e/0x1ae                                                                               
[  403.202984]  [<c1838e5e>] ? __do_softirq+0xb2/0x188                                                                                
[  403.202984]  [<c1838f73>] ? do_softirq+0x3f/0x5c                                                                                   
[  403.202984]  [<c18390fd>] ? irq_exit+0x37/0x80                                                                                     
[  403.202984]  [<c18146fa>] ? smp_apic_timer_interrupt+0x7c/0x9b                                                                     
[  403.202984]  [<c1803a31>] ? apic_timer_interrupt+0x31/0x40                                                                         
[  403.202984]  [<c1840068>] ? complete_signal+0x97/0x1ac                                                                             
[  403.202984]  [<c180a262>] ? mwait_idle+0xad/0x116                                                                                  
[  403.202984]  [<c1801e2f>] ? cpu_idle+0x96/0xc3                                                                                     
[  403.202984]  [<c1ae6629>] ? rest_init+0x75/0x88                                                                                    
[  403.202984]  [<c102aa10>] ? start_kernel+0x32d/0x343                                                                               
[  403.202984]  [<c102a072>] ? _sinittext+0x72/0x88                                                                                   
[  403.323244] Code: c7 56 53 89 d3 83 ec 0c 65 a1 14 00 00 00 89 45 f0 31 c0 
8b 74 97 3c c1 e2 07 89 d0 05 08 0f 00 00 89 55 e8 03 07 8a 10 88 55 ef <f6> 
86 8d 03 00 00 02 74 12 0f b6 c2 50 56 68 74 e3 07 f8 e8 e2                                                      
[  403.323244] EIP: [<f8078ce0>] sky2_mac_intr+0x30/0xc1 [sky2] SS:ESP 
0068:c1c8de24                                                  
[  403.323244] CR2: 000000000000038d                                                                                                  
[  403.365775] ---[ end trace 7f4d83bf1130e18d ]---                                                                                   
[  403.370999] Kernel panic - not syncing: Fatal exception in interrupt                                                               
[  403.378154] Pid: 0, comm: swapper Tainted: G      D    2.6.30.5 #20                                                                
[  403.385185] Call Trace:                                                                                                            
[  403.388006]  [<c1af5bf7>] ? printk+0x1d/0x30                                                                                       
[  403.392861]  [<c1af5b35>] panic+0x53/0xf8                                                                                          
[  403.397404]  [<c1806787>] oops_end+0x9f/0xbf                                                                                       
[  403.402234]  [<c181d7ef>] no_context+0x15d/0x178                                                                                   
[  403.407443]  [<c181db53>] __bad_area_nosemaphore+0x349/0x362                                                                       
[  403.413797]  [<c197afed>] ? vsnprintf+0x2de/0x332                                                                                  
[  403.419104]  [<c197ada0>] ? vsnprintf+0x91/0x332                                                                                   
[  403.424312]  [<c1af8fc3>] ? _spin_unlock_irqrestore+0x31/0x44                                                                      
[  403.430773]  [<c1af8fc3>] ? _spin_unlock_irqrestore+0x31/0x44                                                                      
[  403.437280]  [<c18340f7>] ? release_console_sem+0x18b/0x1c9                                                                        
[  403.443583]  [<c181db89>] bad_area_nosemaphore+0x1d/0x34                                                                           
[  403.449590]  [<c181de56>] do_page_fault+0x10d/0x24b
[  403.455119]  [<c181dd49>] ? do_page_fault+0x0/0x24b
[  403.460654]  [<c1af945d>] error_code+0x7d/0x90
[  403.465759]  [<c1970068>] ? blk_alloc_devt+0x59/0xb9
[  403.471421]  [<f8078ce0>] ? sky2_mac_intr+0x30/0xc1 [sky2]
[  403.477684]  [<f807c33b>] sky2_poll+0x1d2/0xa07 [sky2]
[  403.483502]  [<c184526c>] ? insert_work+0xa5/0xbf
[  403.488843]  [<c1af8f7f>] ? _spin_unlock_irq+0x2f/0x42
[  403.494664]  [<c1a6ebc5>] net_rx_action+0x9e/0x1ae
[  403.500102]  [<c1838e5e>] __do_softirq+0xb2/0x188

Message from[  403.505490]  [<c1838f73>] do_softirq+0x3f/0x5c
 syslogd@gibralt[  403.511881]  [<c18390fd>] irq_exit+0x37/0x80
ar3-esys-master [  403.518089]  [<c18146fa>] 
smp_apic_timer_interrupt+0x7c/0x9b
at Aug 31 11:56:[  403.525829]  [<c1803a31>] apic_timer_interrupt+0x31/0x40
58 ...
 kernel[  403.533177]  [<c1840068>] ? complete_signal+0x97/0x1ac
:[  403.047392] [  403.540336]  [<c180a262>] ? mwait_idle+0xad/0x116
Oops: 0000 [#1] [  403.547010]  [<c1801e2f>] cpu_idle+0x96/0xc3
PREEMPT SMP
[  403.553229]  [<c1ae6629>] rest_init+0x75/0x88

Message from [  403.559515]  [<c102aa10>] start_kernel+0x32d/0x343
syslogd@gibralta[  403.566324]  [<c102a072>] _sinittext+0x72/0x88
r3-esys-master a[  403.572752] Rebooting in 30 seconds..

Potentially the last system reset was similar but just didn't print the stack 
trace for some reason (that is, on the previous reboot with the very same 
sky2.ko loaded, the system just hard-locked and rebooted itself after 30s 
without printing anything to the serial console).

best regards,
Rene

-- 
-------------------------------------------------
Gibraltar firewall       http://www.gibraltar.at/
