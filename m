From: Pekka Enberg <penberg@cs.helsinki.fi>
Subject: Re: [Bug 10575] New: WARNING: at mm/slub.c:2444
Date: Tue, 29 Apr 2008 23:01:54 +0300
Message-ID: <48177EB2.2070309@cs.helsinki.fi>
References: <bug-10575-27@http.bugzilla.kernel.org/>	<20080429082231.2c5470ff.akpm@linux-foundation.org>	<481773A6.5050507@trash.net> <20080429123741.bce81cf8.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Patrick McHardy <kaber@trash.net>, htmldeveloper@gmail.com,
	bugme-daemon@bugzilla.kernel.org, netdev@vger.kernel.org,
	clameter@sgi.com
To: Andrew Morton <akpm@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from courier.cs.helsinki.fi ([128.214.9.1]:46158 "EHLO
	mail.cs.helsinki.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752900AbYD2UHs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 29 Apr 2008 16:07:48 -0400
In-Reply-To: <20080429123741.bce81cf8.akpm@linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Andrew Morton wrote:
> On Tue, 29 Apr 2008 21:14:46 +0200
> Patrick McHardy <kaber@trash.net> wrote:
> 
>> Andrew Morton wrote:
>>> (switched to email.  Please respond via emailed reply-to-all, not via the
>>> bugzilla web interface).
>>>
>>> On Tue, 29 Apr 2008 06:31:36 -0700 (PDT) bugme-daemon@bugzilla.kernel.org wrote:
>>>
>>>   
>>>> kernel version:
>>>>
>>>> cat include/config/kernel.release 
>>>> 2.6.25-sched-devel.git-x86-latest.git
>>>>
>>>> Shutting down the system generated the following errors:
>>>>
>>>> Apr 28 00:20:22 funnyman libvirtd: Shutting down on signal 15
>>>> Apr 28 00:20:25 funnyman kernel: sky2 eth0: Link is down.
>>>> Apr 28 00:20:25 funnyman xinetd[3373]: Exiting...
>>>> Apr 28 00:20:30 funnyman kernel: ------------[ cut here ]------------
>>>> Apr 28 00:20:30 funnyman kernel: WARNING: at mm/slub.c:2444
>>>> kmem_cache_destroy+0xfe/0x108()
>>>> Apr 28 00:20:30 funnyman kernel: Modules linked in: rfcomm hidp l2cap bluetooth
>>>> button ext2 btrfs hfsplus usb_storage nls_utf8 bridge autofs4 nf_conntrack(-)
>>>> xt_tcpudp x_tables sunrpc loop dm_multipath video output sbs sbshc battery ac
>>>> ipv6 parport_pc lp parport snd_usb_audio snd_usb_lib snd_rawmidi snd_hwdep
>>>> snd_hda_intel snd_seq_dummy snd_seq_oss snd_seq_midi_event snd_seq
>>>> snd_seq_device snd_pcm_oss sg firewire_ohci snd_mixer_oss snd_pcm firewire_core
>>>> crc_itu_t snd_timer snd pata_jmicron soundcore serio_raw sky2 snd_page_alloc
>>>> pcspkr i2c_i801 iTCO_wdt iTCO_vendor_support i2c_core floppy dm_snapshot
>>>> dm_zero dm_mirror dm_mod ahci ata_generic ata_piix libata sd_mod scsi_mod ext3
>>>> jbd ehci_hcd ohci_hcd uhci_hcd [last unloaded: xt_state]
>>>> Apr 28 00:20:30 funnyman kernel: Pid: 11669, comm: modprobe Not tainted
>>>> 2.6.25-sched-devel.git-x86-latest.git #1
>>>> Apr 28 00:20:30 funnyman kernel:  [<c042bad6>] warn_on_slowpath+0x46/0x56
>>>> Apr 28 00:20:30 funnyman kernel:  [<c0415a33>] ? apic_wait_icr_idle+0x16/0x1d
>>>> Apr 28 00:20:30 funnyman kernel:  [<c0415243>] ?
>>>> __send_IPI_dest_field+0x50/0x54
>>>> Apr 28 00:20:30 funnyman kernel:  [<c04020e5>] ? send_IPI_mask+0xd/0xf
>>>> Apr 28 00:20:30 funnyman kernel:  [<c046773c>] ?
>>>> get_pageblock_flags_group+0x50/0x6e
>>>> Apr 28 00:20:30 funnyman kernel:  [<c046777e>] ?
>>>> get_pageblock_migratetype+0x24/0x27
>>>> Apr 28 00:20:30 funnyman kernel:  [<c0468472>] ? free_hot_page+0xf/0x11
>>>> Apr 28 00:20:30 funnyman kernel:  [<c0468494>] ? __free_pages+0x20/0x2b
>>>> Apr 28 00:20:30 funnyman kernel:  [<c047f471>] ? __free_slab+0xac/0xb4
>>>> Apr 28 00:20:30 funnyman kernel:  [<c0480754>] kmem_cache_destroy+0xfe/0x108
>>>> Apr 28 00:20:30 funnyman kernel:  [<f8d337c0>] nf_conntrack_cleanup+0x53/0x7a
>>>> [nf_conntrack]
>>>> Apr 28 00:20:30 funnyman kernel:  [<f8d3766d>]
>>>> nf_conntrack_standalone_fini+0x1c/0x1e [nf_conntrack]
>>>> Apr 28 00:20:30 funnyman kernel:  [<c044b56f>] sys_delete_module+0x177/0x1af
>>>> Apr 28 00:20:30 funnyman kernel:  [<c0472c00>] ? remove_vma+0x31/0x53
>>>> Apr 28 00:20:30 funnyman kernel:  [<c0473468>] ? do_munmap+0x182/0x19c
>>>> Apr 28 00:20:30 funnyman kernel:  [<c0404bae>] sysenter_past_esp+0x6a/0x90
>>>> Apr 28 00:20:30 funnyman kernel:  [<c0640000>] ? pci_scan_bridge+0x1dc/0x2eb
>>>> Apr 28 00:20:30 funnyman hcid[9436]: Got disconnected from the system message
>>>> bus
>>>> Apr 28 00:20:30 funnyman kernel:  =======================
>>>> Apr 28 00:20:30 funnyman rpc.statd[2994]: Caught signal 15, un-registering and
>>>> exiting.
>>>> Apr 28 00:20:30 funnyman kernel: ---[ end trace eb2ec02455daeda8 ]---
>>>> Apr 28 00:20:30 funnyman portmap[11769]: connect from 127.0.0.1 to
>>>> unset(status): request from unprivileged port
>>>> Apr 28 00:20:30 funnyman pcscd: pcscdaemon.c:529:signal_trap() Preparing for
>>>> suicide
>>>>
>>>> and mm/slub.c:2444 are as follows:
>>>>
>>>>  2433  * Close a cache and release the kmem_cache structure
>>>>    2434  * (must be used for caches created using kmem_cache_create)
>>>>    2435  */
>>>>    2436 void kmem_cache_destroy(struct kmem_cache *s)
>>>>    2437 {
>>>>    2438         down_write(&slub_lock);
>>>>    2439         s->refcount--;
>>>>    2440         if (!s->refcount) {
>>>>    2441                 list_del(&s->list);
>>>>    2442                 up_write(&slub_lock);
>>>>    2443                 if (kmem_cache_close(s))
>>>>    2444                         WARN_ON(1);
>>>>    2445                 sysfs_slab_remove(s);
>>>>    2446         } else
>>>>    2447                 up_write(&slub_lock);
>>>>    2448 }
>>>>    2449 EXPORT_SYMBOL(kmem_cache_destroy);
>>>>
>>>> How to reproduce:
>>>>
>>>> Not sure how, as it occur during shutdown.
>>>>     
>>> Looks like nf_contrack is destroying a slab cache which still has
>>> live objects.
>>>
>>> I think this came up a few days ago but I'm not sure if it was fixed?
>> I believe Stephen fixed a use-after-free in bridging a few days ago,
>> are you referring to this? Otherwise a pointer would be appreciated.
> 
> <checks>
> 
> Sorry, I confused it with a similar-looking USB trace.  Pekka added some
> additional debug at that site which might help here - it will tell us the
> name of the slab cache:

Well, it's obviously nf_conntrack_cachep but this is the second time I 
see the SLUB WARN_ON trigger but can't find anything wrong with the 
code. Christoph, if you look at nf_conntrack_cleanup() in 
net/netfilter/nf_conntrack_core.c:

  i_see_dead_people:
         nf_conntrack_flush();
         if (atomic_read(&nf_conntrack_count) != 0) {
                 schedule();
                 goto i_see_dead_people;
         }

Yeah, yikes, but in nf_conntrack_alloc() we do

         atomic_inc(&nf_conntrack_count);

before

         ct = kmem_cache_zalloc(nf_conntrack_cachep, GFP_ATOMIC);

So I don't see how we can call kmem_cache_destroy() with unfree'd 
objects in it... Can you take a look at this?

And oh, Peter, if you can trigger this with mainline, please do post the 
oops. I should give us better information what's happening.

		Pekka
