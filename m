From: Felix Radensky <felix@allot.com>
Subject: Ethernet bridge performance
Date: Thu, 07 Aug 2003 12:12:07 +0300
Sender: netdev-bounce@oss.sgi.com
Message-ID: <3F3217E7.2080903@allot.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="Boundary_(ID_RVVz94TACxHZ39XZVjgHQQ)"
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.

--Boundary_(ID_RVVz94TACxHZ39XZVjgHQQ)
Content-type: text/plain; charset=us-ascii; format=flowed
Content-transfer-encoding: 7BIT

Hi,

I'm evaluating a performance of a dual port ethernet bridge, and the
results are a bit disappointing. I would appreciate any hints on improving
the results.

I'm using a Dual Xeon 2.66 GHz box based on Intel  5701 chipset with  1G
of RAM. NICs are e1000 82546 connected to PCIX bus. Kernel is 2.4.22-pre8,
e1000  driver version 5.1.13-k1 with NAPI support. NICs' interrupts are 
bound
to CPU0.

The test consists of sending 200 byte UDP packets from 2 ports of Gigabit
IXIA traffic generator to 2 bridge ports. The bridge is capable to sustain
the rate of ~170000 pps from each IXIA port without drops. I was
expecting it to be able to do at least 250000 pps (our own bridge code 
 based
on 2.2.x kernel sustains ~266000 pps on the same hardware).
e1000 driver drops 0 packets, all drops occur at higher level.

The output of oprofile attached. I'd be happy to provide any info you may
need.

Thanks in advance for your help.

Felix.

--Boundary_(ID_RVVz94TACxHZ39XZVjgHQQ)
Content-type: text/plain; name=oprofile.log
Content-transfer-encoding: 7BIT
Content-disposition: inline; filename=oprofile.log

CPU: P4 / Xeon, speed 2666.83 MHz (estimated)
Counted GLOBAL_POWER_EVENTS events (time during which processor is not stopped) with a unit mask of 0x01 (count cycles when processor is active) count 1333415
vma      samples  %           symbol name
c01a13ac 7983     12.5065     eth_type_trans
c01a1590 7629     11.9519     qdisc_restart
c0197720 7365     11.5383     skb_release_data
c010c170 5962      9.3403     do_gettimeofday
c019a9b4 5207      8.1575     dev_queue_xmit
c012df98 4243      6.6472     free_block
c019ad44 3404      5.3328     netif_rx
c01974e0 3266      5.1166     alloc_skb
c012e1b4 2600      4.0733     kmalloc
c012e3b8 2448      3.8351     kfree
c019b284 2401      3.7615     process_backlog
c012debc 1941      3.0408     kmem_cache_alloc_batch
c0197790 1555      2.4361     kfree_skbmem
c01977f8 1296      2.0304     __kfree_skb
c012e07c 1203      1.8847     kmem_cache_alloc
c019afa4 1079      1.6904     net_tx_action
c019b0bc 932       1.4601     netif_receive_skb
c01a1a04 750       1.1750     pfifo_fast_dequeue
c019accc 445       0.6972     get_sample_stats
c012e338 431       0.6752     kmem_cache_free
c01a1990 222       0.3478     pfifo_fast_enqueue
c01087f0 180       0.2820     do_IRQ
c01142a8 152       0.2381     schedule
c010c434 131       0.2052     timer_interrupt
c010b04c 123       0.1927     IRQ0x31_interrupt
c010b040 115       0.1802     IRQ0x30_interrupt
c011c400 82        0.1285     cpu_raise_softirq
c019b3ac 62        0.0971     net_rx_action
c01052a0 57        0.0893     default_idle
c011be40 55        0.0862     do_softirq
c0112b28 47        0.0736     end_level_ioapic_irq
c016b210 39        0.0611     add_timer_randomness
c016afb0 38        0.0595     add_entropy_words
c016b0a4 37        0.0580     batch_entropy_store
c0105944 35        0.0548     __switch_to
c0115778 32        0.0501     wake_up_process
c0112de0 23        0.0360     do_check_pgt_cache
c010b760 22        0.0345     apic_timer_interrupt
c010ae10 21        0.0329     common_interrupt
c01da960 13        0.0204     __rdtsc_delay
c0106f3d 11        0.0172     restore_all
c0111d0c 11        0.0172     smp_apic_timer_interrupt
c01245a8 11        0.0172     check_pgt_cache
c016b158 11        0.0172     batch_entropy_process
c0107138 9         0.0141     page_fault
c0108654 9         0.0141     handle_IRQ_event
c010ae30 9         0.0141     IRQ0x00_interrupt
c0125414 9         0.0141     do_wp_page
c011f1b0 8         0.0125     update_one_process
c011f36c 8         0.0125     timer_bh
c011c33c 7         0.0110     ksoftirqd
c0113eb8 6         0.0094     reschedule_idle
c011c0cc 5         0.0078     tasklet_hi_action
c011c204 5         0.0078     bh_action
c010ae23 4         0.0063     call_do_IRQ
c011eb90 4         0.0063     add_timer
c011f284 4         0.0063     update_process_times
c0125970 4         0.0063     do_anonymous_page
c016b320 4         0.0063     add_interrupt_randomness
c0106ef4 3         0.0047     system_call
c010c78c 3         0.0047     inc_new_microsec_time
c0124850 3         0.0047     zap_page_range
c01daa70 3         0.0047     __generic_copy_to_user
c010b778 2         0.0031     call_apic_timer_interrupt
c0112ae8 2         0.0031     ack_edge_ioapic_irq
c011327c 2         0.0031     do_page_fault
c01147c8 2         0.0031     __wake_up
c011ee88 2         0.0031     tqueue_bh
c0124698 2         0.0031     copy_page_range
c0125a5c 2         0.0031     do_no_page
c01282d8 2         0.0031     __find_get_page
c0128e1c 2         0.0031     file_read_actor
c01d1880 2         0.0031     fn_hash_lookup
c01db1b0 2         0.0031     number
c01052f4 1         0.0016     cpu_idle
c0106628 1         0.0016     setup_frame
c0106fb0 1         0.0016     ret_from_intr
c0106fb7 1         0.0016     ret_from_exception
c0106fe4 1         0.0016     error_code
c01114f8 1         0.0016     flush_tlb_page
c01198ec 1         0.0016     get_module_list
c0119d30 1         0.0016     s_show
c011c2d0 1         0.0016     __run_task_queue
c011f73c 1         0.0016     do_timer
c012093c 1         0.0016     sys_rt_sigprocmask
c0125bf8 1         0.0016     handle_mm_fault
c0125cc8 1         0.0016     pte_alloc
c0125fd8 1         0.0016     lock_vma_mappings
c0126348 1         0.0016     do_mmap_pgoff
c012ca90 1         0.0016     vmfree_area_pages
c012dcac 1         0.0016     kmem_cache_grow
c012f000 1         0.0016     __lru_cache_del
c0130288 1         0.0016     rmqueue
c01308a8 1         0.0016     __free_pages
c0130acf 1         0.0016     .text.lock.page_alloc
c0134460 1         0.0016     fd_install
c013fb70 1         0.0016     link_path_walk
c01557f8 1         0.0016     proc_pid_statm
c016b078 1         0.0016     credit_entropy_store
c01804dc 1         0.0016     ide_inb
c0180524 1         0.0016     ide_outb
c0180a60 1         0.0016     drive_is_ready
c0198d3c 1         0.0016     skb_headerinit
c01a58e4 1         0.0016     ip_route_input_slow
c01a8324 1         0.0016     ip_rcv
c01d0c68 1         0.0016     fib_semantic_match

--Boundary_(ID_RVVz94TACxHZ39XZVjgHQQ)--
