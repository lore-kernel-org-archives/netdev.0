From: Rusty Russell <rusty@rustcorp.com.au>
Subject: Re: No sysfs directory for openvswitch module when built-in
Date: Mon, 04 Feb 2013 16:29:51 +1030
Message-ID: <87boc0liug.fsf@rustcorp.com.au>
References: <CAM_iQpVgEchb8UsxUP=w6OMbYx=zuP2yv=QwFhe8rPCbNBreVg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: LKML <linux-kernel@vger.kernel.org>,
	Linux Kernel Network Developers <netdev@vger.kernel.org>
To: Cong Wang <xiyou.wangcong@gmail.com>,
	Jesse Gross <jesse@nicira.com>,
	"David S. Miller" <davem@davemloft.net>, "Greg KH" <greg@kroah.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CAM_iQpVgEchb8UsxUP=w6OMbYx=zuP2yv=QwFhe8rPCbNBreVg@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Cong Wang <xiyou.wangcong@gmail.com> writes:
> Hello, Rusty, Jesse,
>
> I met an interesting problem when I compile openvswitch module as a
> built-in (actually I compile ALL kernel modules as built-in), there is
> no /sys/module/openvswitch/ directory created by the kernel in this
> case.
...
> What's worse, the user-space init script thinks openvswitch module is
> not loaded by checking the exist of this directory, therefore refuses
> to start.

We only know built-in "modules" exist if we see a parameter or version
which mention them.  Looking for /sys/module/openvswitch/ is almost as
flawed as looking in /proc/modules.

I hacked up something which lists KBUILD_MODNAME for every element in my
kernel which did EXPORT_KERNEL or module_init, and most of them can
never be modules, though any could have parameters.  Even if we changed
the build system so we could tell things which "could have been a
module", it's silly.

In summary, you really need to test features, not presence of modules.

Cheers,
Rusty.

PS. Here's the list:

8250_core, 8250_pci, ac, access, acpi, acpi_i2c, addrconf_core, aead,
aerdriver, aes_generic, af_inet, af_netlink, af_packet, agpgart, ahci,
aio, amd, amd64_agp, amd_nb, anon_inodes, apic, arc4, argv_split, arp,
asn1_decoder, asymmetric_keys, async, ata_piix, atkbd, atomic64_32,
attr, attribute_container, autoprobe, average, backing_dev, backlight,
bad_inode, balloon_compaction, battery, bcd, bin, bio, bitblit, bitmap,
bitrev, blk_core, blk_exec, blk_flush, blk_ioc, blk_iopoll, blk_lib,
blk_map, blk_merge, blk_settings, blk_softirq, blk_tag, blk_timeout,
block_dev, boot, bootflag, bounce, bsearch, buffer, bus, bus, button,
cache_smp, capability, cfbcopyarea, cfbfillrect, cfbimgblt, cfg80211,
chainiv, char_dev, check_signature, chip, class, clock, clockevents,
clocksource, cmdline, common, common, configs, consolemap, container,
core, core, core, coredump, cpu, cpu, cpu, cpu_rmap, cpuidle, cpumask,
cputime, crc16, crc32, crc32c, crc_t10dif, cred, crypto, crypto_algapi,
crypto_blkcipher, crypto_hash, crypto_wq, cryptomgr, cstate, ctype,
datagram, datagram, dcache, dd, debug_core, debug_locks, debugfs,
dec_and_lock, delay, delayacct, dev, dev_addr_lists, devinet, devpts,
devres, devres, devres, dir, direct_io, div64, dma, dma_buf,
dma_coherent, dma_mapping, dmapool, dmi_scan, dnotify, driver, driver,
drm, drm_kms_helper, dst, dummychip, dumpstack, dumpstack_32,
dynamic_queue_limits, e1000e, e820, elevator, eseqiv, eth, ethtool,
eventfd, exec, exec_domain, exit, ext2, ext3, ext4, exthdrs_core, fan,
fb, fb_notify, fbcon, fbdev, fcntl, fib_frontend, fib_rules, fib_rules,
fib_trie, file, file, file_table, filemap, filesystems, filter,
find_last_bit, find_next_bit, firmware, firmware_class, flex_array,
flow, flow_dissector, font, fork, freezer, fremap, fs_struct,
fs_writeback, fsnotify, gcd, gen_estimator, gen_stats, generic,
generic_ops, genetlink, genhd, group, groups, halfmd4, hexdump, hid,
hid_a4tech, hid_apple, hid_belkin, hid_cherry, hid_chicony, hid_cypress,
hid_ezkey, hid_generic, hid_gyration, hid_logitech, hid_microsoft,
hid_monterey, hid_petalynx, hid_pl, hid_samsung, hid_sony, hid_sunplus,
highmem, highmem_32, host_bridge, hpet, hrtimer, htirq, hung_task,
hvc_console, hw_breakpoint, hw_breakpoint, hweight, hwmon, hypervisor,
i2c_algo_bit, i2c_boardinfo, i2c_core, i386, i386_ksyms_32, i387, i8042,
i810, i810fb, i8253, i915, icmp, ide_core, ide_gd_mod, ide_generic,
ide_pci_generic, ide_scan_pci, idr, igmp, inet_connection_sock,
inet_fragment, inet_hashtables, inet_lro, inet_timewait_sock, inetpeer,
init_32, init_task, inode, inotify_user, input_core, int_sqrt,
intel_agp, intel_gtt, io_apic, io_delay, ioapic, ioctl, ioctl, iomap,
iomap_32, iomap_copy, ioprio, ioremap, ioremap, iovec, ip_fragment,
ip_input, ip_options, ip_output, ip_sockglue, ip_tables, irq, irq,
irq_32, irq_work, irqdesc, jbd, jbd2, jiffies, kasprintf, kdebugfs, key,
keyboard, keyring, kfifo, kgdboc, klist, kmod, kobject, kobject_uevent,
krng, kstrtox, ksysfs, kthread, ladder, lcm, led_class, led_core,
led_triggers, legacy, lglock, libahci, libata, libfs, libps2,
link_watch, list_debug, list_sort, llist, locks, logo, mac80211,
maccess, main, main, main, main, manage, match, mbcache, mce, md5, md5,
memcpy_32, memory, mempool, memweight, menu, mii, misc, mlock, mm_init,
mmap, mmu_context, mmu_notifier, module, mount, mousedev, mpage, mpi,
mshyperv, msr, msr_reg_export, msr_smp, mutex, mutex_debug, n_tty,
namei, namespace, neighbour, net_namespace, net_sysfs, netevent,
netfilter, netfilter, netpoll, nf_conntrack, nf_conntrack_ipv4,
nf_defrag_ipv4, nlattr, nls_base, nmi, nobootmem, noop_iosched,
notification, notifier, nvram, oid_registry, oom_kill, open, output,
output_core, page_alloc, page_writeback, pageattr, panic, params,
paravirt, parser, partition_generic, pat, pcbios, pci, pci_dma,
pci_driver, pci_iomap, pci_quirks, pcieportdrv, pcips2, pcompress,
percpu, percpu_counter, perf_event, perf_event_amd, perf_event_amd_ibs,
perf_event_intel, perfctr_watchdog, permission, pgtable_32, physaddr,
pid, piix, ping, pipe, platform, plist, pm, pnp, posix_acl, posix_clock,
posix_timers, power_supply, printk, probe, probe_32, probe_roms, proc,
process, process_32, processor, protocol, protocol, psmouse, ptrace,
pty, public_key, qos, qos, quirks, radix_tree, ramfs, random, random32,
ratelimit, raw, rbtree, rcupdate, rcutree, read_write, readahead,
readdir, reboot, reciprocal_div, relay, remove, request_key,
request_sock, resource, rfkill, rmap, rng, rom, route, rsa, rtc,
rtmutex, rtnetlink, rwsem, rwsem, scatterlist, sch_generic, scm,
scsi_ioctl, scsi_mod, sd_mod, search, secure_seq, select, semaphore,
seq_file, serial_core, serio, setup, setup_bus, setup_percpu, setup_res,
sha1, sha1_generic, sha512_generic, shmem, signal, skbuff, slab_common,
slot, slub, smp, smp, smpboot, smpboot, sock, sock_diag, socket,
softcursor, softirq, sort, soundcore, spinlock, spinlock_debug, splice,
srcu, stack, staging, stat, statfs, stats, stop_machine, stream, string,
string_32, string_helpers, strncpy_from_user, strnlen_user, super,
suspend, swap, swapfile, symlink, sync, syncookies, sys, syscall,
syscore, sysctl, sysctl_net, sysfs, sysrq, tcp, tcp_cong, tcp_cubic,
tcp_input, tcp_ipv4, tcp_metrics, tcp_minisocks, tcp_output, tcp_timer,
therm_throt, thermal, thermal_sys, thinkpad_acpi, tick_sched, tileblit,
time, time, timeconv, timekeeping, timer, timerqueue, tlb, topology,
transport_class, traps, truncate, tsc, tty_buffer, tty_io, tty_ioctl,
tty_ldisc, tty_mutex, tty_port, udp, udplite, unix, usb_common, usbcore,
usbhid, usbmon, user, user_defined, user_return_notifier, usercopy,
usercopy_32, util, utils, uuid, vdso32_setup, version, vesafb, vgaarb,
vgacon, vgastate, video, virtio, virtio_blk, virtio_console, virtio_net,
virtio_pci, virtio_ring, vlan_core, vmalloc, vmscan, vmstat, vmware,
vpd, vsprintf, vt, vt_ioctl, wait, wakeup, workqueue, x509_key_parser,
x86_init, x_tables, xattr, xattr_acl, xfrm4_input, xfrm4_output,
xfrm_input, xfrm_output, xfrm_policy, xfrm_replay, xfrm_state,
xt_tcpudp, zlib_inflate
