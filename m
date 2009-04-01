From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [Bugme-new] [Bug 12969] New: WARNING: at lib/dma-debug.c:539
 check_sync+0xe9/0x341() (Not tainted)
Date: Wed, 1 Apr 2009 16:50:15 -0700
Message-ID: <20090401165015.8481f9e0.akpm@linux-foundation.org>
References: <bug-12969-10286@http.bugzilla.kernel.org/>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: bugme-daemon@bugzilla.kernel.org, netdev@vger.kernel.org,
	sergio@sergiomb.no-ip.org, Joerg Roedel <joerg.roedel@amd.com>
To: zambrano@broadcom.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([140.211.169.13]:54754 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754799AbZDAXxI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 1 Apr 2009 19:53:08 -0400
In-Reply-To: <bug-12969-10286@http.bugzilla.kernel.org/>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


(switched to email.  Please respond via emailed reply-to-all, not via the
bugzilla web interface).

On Sun, 29 Mar 2009 11:43:19 GMT
bugzilla-daemon@bugzilla.kernel.org wrote:

> http://bugzilla.kernel.org/show_bug.cgi?id=12969
> 
>            Summary: WARNING: at lib/dma-debug.c:539
>                     check_sync+0xe9/0x341() (Not tainted)
>            Product: Drivers
>            Version: 2.5
>           Platform: All
>         OS/Version: Linux
>               Tree: Fedora
>             Status: NEW
>           Severity: normal
>           Priority: P1
>          Component: Network
>         AssignedTo: drivers_network@kernel-bugs.osdl.org
>         ReportedBy: sergio@sergiomb.no-ip.org
>         Regression: Yes
> 
> 
> ------------[ cut here ]------------                                            
> WARNING: at lib/dma-debug.c:539 check_sync+0xe9/0x341() (Not tainted)           
> Hardware name: HP Compaq nx6110 (PY501EA#AB9)                                   
> b44 0000:02:0e.0: DMA-API: device driver tries to sync DMA memory it has not
> allocated [device address=0x0000000075941040] [size=1566 bytes]  
> Modules linked in: llc bnep l2cap bluetooth autofs4 lm90 hwmon i2c_i801 sunrpc
> ipv6 cpufreq_ondemand acpi_cpufreq uinput snd_intel8x0m snd_intel8x0
> snd_ac97_codec snd_seq_dummy ac97_bus snd_seq_oss snd_seq_midi_event snd_seq
> snd_seq_device snd_pcm_oss snd_mixer_oss snd_pcm b44 ssb firewire_ohci
> snd_timer ipw2200 iTCO_wdt mii firewire_core snd iTCO_vendor_support libipw
> yenta_socket crc_itu_t lib80211 rsrc_nonstatic soundcore snd_page_alloc joydev
> pcspkr wmi serio_raw ata_generic pata_acpi i915 drm i2c_algo_bit i2c_core video
> output [last unloaded: scsi_wait_scan]                                          
> Pid: 2418, comm: S58ntpd Not tainted 2.6.29-16.fc10.i686.PAE #1                 
> Call Trace:                                                                     
>  [<c04396d1>] warn_slowpath+0x7c/0xbd                                           
>  [<c0457fe1>] ? register_lock_class+0x17/0x290                                  
>  [<c0458d61>] ? mark_lock+0x1e/0x349                                            
>  [<c0556448>] ? _raw_spin_unlock+0x74/0x78                                      
>  [<c0458d61>] ? mark_lock+0x1e/0x349                                            
>  [<c055a060>] ? check_sync+0x37/0x341                                           
>  [<c055a112>] check_sync+0xe9/0x341                                             
>  [<c0711245>] ? _spin_unlock_irqrestore+0x45/0x55                               
>  [<c04592db>] ? trace_hardirqs_on+0xb/0xd                                       
>  [<c055a4d1>] debug_dma_sync_single_for_device+0x2f/0x39                        
>  [<f828f722>] dma_sync_single_for_device+0x4a/0x59 [b44]                        
>  [<f828f76f>] ssb_dma_sync_single_for_device+0x3e/0x48 [b44]                    
>  [<f8291d1e>] b44_recycle_rx+0x18c/0x196 [b44]                                  
>  [<f8291f9f>] b44_poll+0x277/0x3c0 [b44]                                        
>  [<c0687bb9>] net_rx_action+0xa1/0x1ca                                          
>  [<c043e30a>] __do_softirq+0x9d/0x154                                           
>  [<c043e413>] do_softirq+0x52/0x7e                                              
>  [<c043e56f>] irq_exit+0x49/0x77                                                
>  [<c040b22e>] do_IRQ+0x97/0xad                                                  
>  [<c0409dac>] common_interrupt+0x2c/0x34                                        

This would appear to be reporting a bug in b44's DMA API usage.  See
the newly-added documentation in Documentation/DMA-API.txt, starting
with

	Part III - Debug drivers use of the DMA-API

The line numbers have changed, but it is:

		err_printk(ref->dev, NULL, "DMA-API: device driver tries "
			   "to free DMA memory it has not allocated "
			   "[device address=0x%016llx] [size=%llu bytes]\n",
			   ref->dev_addr, ref->size);


