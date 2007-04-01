From: Dave Sperry <dave_sperry@ieee.org>
Subject: Re: Poor UDP performance using 2.6.21-rc5-rt5
Date: Sun, 01 Apr 2007 18:00:24 -0400
Message-ID: <46102B78.90702@ieee.org>
References: <461004CE.1030009@ieee.org> <461010F9.7040706@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: linux-rt-users@vger.kernel.org, linux-kernel@vger.kernel.org,
	netdev <netdev@vger.kernel.org>
To: Nivedita Singhvi <niv@us.ibm.com>
Return-path: <linux-rt-users-owner@vger.kernel.org>
In-Reply-To: <461010F9.7040706@us.ibm.com>
Sender: linux-rt-users-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Nivedita Singhvi wrote:
> Dave Sperry wrote:
>> Hi
>
> (adding netdev to cc list)
>
>> I have a dual core Opteron machine that exhibits poor UDP performance 
>> (RT consumes more than 2X cpu) with the 2.6.21-rc5-rt5 as compared to 
>> 2.6.21-rc5. Top shows the IRQ handler consuming a lot of CPU.
>
> Dave, any chance you've got oprofile working on the -rt5?
Yes, I have a opreport from about 15 seconds in the middle of the test 
below is the top of the report.

> And I'm assuming nothing very different in the stats or errors
> through both runs?
correct. no errors, the throughput in the RT was less, I assume it was 
CPU bound.

Thanks
Dave.

CPU: AMD64 processors, speed 2211.36 MHz (estimated)
Counted CPU_CLK_UNHALTED events (Cycles outside of halt state) with a 
unit mask of 0x00 (No unit mask) count 100000
samples  %        image name               app name                 
symbol name
16375    13.2965  vmlinux                  vmlinux                  
__sched_text_start
7820      6.3498  vmlinux                  vmlinux                  
copy_user_generic_string
7019      5.6994  forcedeth.ko             forcedeth                
nv_start_xmit_optimized
6733      5.4672  forcedeth.ko             forcedeth                
nv_nic_irq_optimized
6572      5.3365  vmlinux                  vmlinux                  
__switch_to
6440      5.2293  vmlinux                  vmlinux                  
pfifo_fast_dequeue
5796      4.7063  vmlinux                  vmlinux                  
handle_IRQ_event
4557      3.7003  vmlinux                  vmlinux                  
ip_output
4452      3.6150  vmlinux                  vmlinux                  
try_to_wake_up
3698      3.0028  forcedeth.ko             forcedeth                
nv_tx_done_optimized
3599      2.9224  vmlinux                  vmlinux                  
udp_sendmsg
3424      2.7803  vmlinux                  vmlinux                  
reschedule_interrupt
3308      2.6861  vmlinux                  vmlinux                  
IRQ0xc1_interrupt
3095      2.5131  vmlinux                  vmlinux                  
ip_append_data
2835      2.3020  vmlinux                  vmlinux                  
kmem_cache_free
2274      1.8465  vmlinux                  vmlinux                  
thread_return
2080      1.6890  vmlinux                  vmlinux                  kfree
1864      1.5136  vmlinux                  vmlinux                  
dev_queue_xmit
1862      1.5119  vmlinux                  vmlinux                  
sock_sendmsg
1606      1.3041  libc-2.5.so              libc-2.5.so              
__sendto_nocancel
1464      1.1888  vmlinux                  vmlinux                  memset_c
1439      1.1685  vmlinux                  vmlinux                  
__ip_route_output_key
1344      1.0913  vmlinux                  vmlinux                  schedule
1167      0.9476  oprofiled                oprofiled                (no 
symbols)
1010      0.8201  vmlinux                  vmlinux                  
sock_wfree
998       0.8104  vmlinux                  vmlinux                  memcpy_c
910       0.7389  vmlinux                  vmlinux                  
__might_sleep
880       0.7146  vmlinux                  vmlinux                  
system_call
735       0.5968  vmlinux                  vmlinux                  
preempt_schedule_irq
726       0.5895  vmlinux                  vmlinux                  
__bitmap_empty
722       0.5863  vmlinux                  vmlinux                  
atomic_notifier_call_chain
701       0.5692  vmlinux                  vmlinux                  
current_kernel_time
681       0.5530  vmlinux                  vmlinux                  
release_sock
663       0.5384  vmlinux                  vmlinux                  
rt_hash_code
660       0.5359  vmlinux                  vmlinux                  
pfifo_fast_enqueue
618       0.5018  vmlinux                  vmlinux                  cpu_idle
617       0.5010  vmlinux                  vmlinux                  
kthread_should_stop
601       0.4880  vmlinux                  vmlinux                  
__alloc_skb
591       0.4799  oprofile                 oprofile                 (no 
symbols)
551       0.4474  vmlinux                  vmlinux                  
__wake_up
505       0.4101  vmlinux                  vmlinux                  
kfree_skbmem
494       0.4011  vmlinux                  vmlinux                  
inet_sendmsg
450       0.3654  netperf                  netperf                  
send_udp_stream
448       0.3638  vmlinux                  vmlinux                  
__kfree_skb
391       0.3175  vmlinux                  vmlinux                  
common_interrupt
366       0.2972  vmlinux                  vmlinux                  
find_next_bit
346       0.2810  vmlinux                  vmlinux                  
ret_from_intr
343       0.2785  vmlinux                  vmlinux                  
fget_light
333       0.2704  vmlinux                  vmlinux                  
retint_swapgs
327       0.2655  vmlinux                  vmlinux                  
exit_intr
312       0.2533  vmlinux                  vmlinux                  tracesys
309       0.2509  vmlinux                  vmlinux                  
rt_spin_lock_slowlock
306       0.2485  vmlinux                  vmlinux                  
cond_resched_softirq_context
303       0.2460  vmlinux                  vmlinux                  
retint_kernel
296       0.2404  vmlinux                  vmlinux                  
cond_resched
256       0.2079  bash                     bash                     (no 
symbols)
252       0.2046  vmlinux                  vmlinux                  
preempt_schedule
248       0.2014  vmlinux                  vmlinux                  
int_ret_from_sys_call
242       0.1965  vmlinux                  vmlinux                  
restore_args
226       0.1835  libc-2.5.so              libc-2.5.so              sendto
199       0.1616  vmlinux                  vmlinux                  
copy_from_user
181       0.1470  vmlinux                  vmlinux                  
notifier_call_chain
165       0.1340  forcedeth.ko             forcedeth                
nv_rx_process_optimized
163       0.1324  vmlinux                  vmlinux                  
int_very_careful
139       0.1129  libc-2.5.so              libc-2.5.so              
__gconv_transform_utf8_internal
114       0.0926  vmlinux                  vmlinux                  
__handle_mm_fault
114       0.0926  vmlinux                  vmlinux                  
get_task_mm
104       0.0844  vmlinux                  vmlinux                  
find_first_bit
103       0.0836  vmlinux                  vmlinux                  
int_restore_rest
96        0.0780  vmlinux                  vmlinux                  
dummy_socket_sendmsg
87        0.0706  vmlinux                  vmlinux                  
copy_page_c
83        0.0674  jbd                      jbd                      (no 
symbols)
79        0.0641  vmlinux                  vmlinux                  
clear_page_c
77        0.0625  vmlinux                  vmlinux                  
exit_idle
76        0.0617  libc-2.5.so              libc-2.5.so              mbrtowc
72        0.0585  vmlinux                  vmlinux                  
apic_timer_interrupt
67        0.0544  vmlinux                  vmlinux                  __delay
66        0.0536  vmlinux                  vmlinux                  
page_fault
65        0.0528  vmlinux                  vmlinux                  
unmap_vmas
62        0.0503  vmlinux                  vmlinux                  
rt_spin_lock_slowunlock
55        0.0447  ext3                     ext3                     (no 
symbols)
55        0.0447  vmlinux                  vmlinux                  
__spin_lock_irqsave
53        0.0430  vmlinux                  vmlinux                  
rt_read_lock
50        0.0406  vmlinux                  vmlinux                  
int_with_check
44        0.0357  vmlinux                  vmlinux                  
rt_read_unlock
41        0.0333  libc-2.5.so              libc-2.5.so              
_int_malloc
40        0.0325  vmlinux                  vmlinux                  
enter_idle
36        0.0292  vmlinux                  vmlinux                  
find_get_page
33        0.0268  vmlinux                  vmlinux                  
do_page_fault
32        0.0260  libc-2.5.so              libc-2.5.so              _dl_addr
29        0.0235  vmlinux                  vmlinux                  
__d_lookup
28        0.0227  vmlinux                  vmlinux                  
copy_page_range
26        0.0211  libc-2.5.so              libc-2.5.so              
_int_free
24        0.0195  vmlinux                  vmlinux                  
__spin_unlock_irqrestore
24        0.0195  vmlinux                  vmlinux                  
iret_label
24        0.0195  vmlinux                  vmlinux                  memcpy
24        0.0195  vmlinux                  vmlinux                  
vm_normal_page
23        0.0187  vmlinux                  vmlinux                  
kmem_cache_alloc
23        0.0187  vmlinux                  vmlinux                  rb_erase
23        0.0187  vmlinux                  vmlinux                  
retint_restore_args
21        0.0171  vmlinux                  vmlinux                  rb_first
19        0.0154  vmlinux                  vmlinux                  
__link_path_walk
18        0.0146  libc-2.5.so              libc-2.5.so              strlen
18        0.0146  vmlinux                  vmlinux                  
do_wp_page
17        0.0138  vmlinux                  vmlinux                  find_vma
16        0.0130  libpthread-2.5.so        libpthread-2.5.so        
pthread_cond_timedwait@@GLIBC_2.3.2
16        0.0130  vmlinux                  vmlinux                  
flush_tlb_page
15        0.0122  vmlinux                  vmlinux                  
rb_insert_color
15        0.0122  vmlinux                  vmlinux                  
rt_mutex_lock
14        0.0114  libc-2.5.so              libc-2.5.so              
_dl_mcount_wrapper_check
14        0.0114  netperf                  netperf                  .plt
13        0.0106  vmlinux                  vmlinux                  
cache_alloc_refill
13        0.0106  vmlinux                  vmlinux                  
get_page_from_freelist
12        0.0097  libc-2.5.so              libc-2.5.so              malloc
12        0.0097  vmlinux                  vmlinux                  
copy_process
12        0.0097  vmlinux                  vmlinux                  
hrtimer_run_queues
12        0.0097  vmlinux                  vmlinux                  
release_pages
11        0.0089  ld-2.5.so                ld-2.5.so                
_dl_cache_libcmp
11        0.0089  libc-2.5.so              libc-2.5.so              free
11        0.0089  vmlinux                  vmlinux                  memset
10        0.0081  libc-2.5.so              libc-2.5.so              strcpy
10        0.0081  libcrypto.so.0.9.8b      libcrypto.so.0.9.8b      (no 
symbols)
10        0.0081  libglib-2.0.so.0.1200.3  libglib-2.0.so.0.1200.3  (no 
symbols)
10        0.0081  vmlinux                  vmlinux                  
__find_get_block
9         0.0073  ehci_hcd                 ehci_hcd                 (no 
symbols)
9         0.0073  vmlinux                  vmlinux                  
do_lookup
9         0.0073  vmlinux                  vmlinux                  
error_exit
9         0.0073  vmlinux                  vmlinux                  
lock_timer_base
9         0.0073  vmlinux                  vmlinux                  rb_next
8         0.0065  gawk                     gawk                     (no 
symbols)
8         0.0065  libc-2.5.so              libc-2.5.so              
sigprocmask
8         0.0065  libpython2.4.so.1.0      libpython2.4.so.1.0      (no 
symbols)
8         0.0065  vmlinux                  vmlinux                  
__strncpy_from_user
8         0.0065  vmlinux                  vmlinux                  
__strnlen_user
8         0.0065  vmlinux                  vmlinux                  
do_mmap_pgoff
8         0.0065  vmlinux                  vmlinux                  dput
7         0.0057  libc-2.5.so              libc-2.5.so              strchr
7         0.0057  libc-2.5.so              libc-2.5.so              strncpy
7         0.0057  sshd                     sshd                     (no 
symbols)
7         0.0057  vmlinux                  vmlinux                  
call_softirq
7         0.0057  vmlinux                  vmlinux                  
filemap_nopage
7         0.0057  vmlinux                  vmlinux                  
rt_mutex_trylock
6         0.0049  ld-2.5.so                ld-2.5.so                
_dl_map_object_from_fd
6         0.0049  vmlinux                  vmlinux                  
IRQ0xb9_interrupt
6         0.0049  vmlinux                  vmlinux                  
find_vma_prepare
6         0.0049  vmlinux                  vmlinux                  
free_hot_cold_page
6         0.0049  vmlinux                  vmlinux                  
free_pgtables
6         0.0049  vmlinux                  vmlinux                  
lru_cache_add_active
6         0.0049  vmlinux                  vmlinux                  number
6         0.0049  vmlinux                  vmlinux                  
page_remove_rmap
6         0.0049  vmlinux                  vmlinux                  
retint_careful
6         0.0049  vmlinux                  vmlinux                  
rt_mutex_unlock
6         0.0049  vmlinux                  vmlinux                  
set_normalized_timespec
5         0.0041  grep                     grep                     (no 
symbols)
5         0.0041  ld-2.5.so                ld-2.5.so                dl_main
5         0.0041  libc-2.5.so              libc-2.5.so              memcpy
5         0.0041  libc-2.5.so              libc-2.5.so              strcmp
5         0.0041  libpthread-2.5.so        libpthread-2.5.so        
__lll_mutex_unlock_wake
5         0.0041  scsi_mod                 scsi_mod                 (no 
symbols)
5         0.0041  vmlinux                  vmlinux                  
__pagevec_lru_add_active
5         0.0041  vmlinux                  vmlinux                  
anon_vma_prepare
5         0.0041  vmlinux                  vmlinux                  
anon_vma_unlink
5         0.0041  vmlinux                  vmlinux                  
do_path_lookup
5         0.0041  vmlinux                  vmlinux                  
free_pages_and_swap_cache
5         0.0041  vmlinux                  vmlinux                  
page_add_file_rmap
4         0.0032  forcedeth.ko             forcedeth                
nv_get_hw_stats
4         0.0032  ld-2.5.so                ld-2.5.so                
_dl_load_cache_lookup
4         0.0032  ld-2.5.so                ld-2.5.so                
_dl_resolve_conflicts
4         0.0032  ld-2.5.so                ld-2.5.so                memset
4         0.0032  libc-2.5.so              libc-2.5.so              vfprintf
4         0.0032  libdbus-1.so.3.2.0       libdbus-1.so.3.2.0       (no 
symbols)
4         0.0032  libpthread-2.5.so        libpthread-2.5.so        
__pthread_mutex_unlock_usercnt
4         0.0032  vmlinux                  vmlinux                  
IRQ0x81_interrupt
4         0.0032  vmlinux                  vmlinux                  
__wake_up_bit
4         0.0032  vmlinux                  vmlinux                  
cpuset_update_task_memory_state
4         0.0032  vmlinux                  vmlinux                  dup_fd
4         0.0032  vmlinux                  vmlinux                  
file_kill
4         0.0032  vmlinux                  vmlinux                  
generic_permission
4         0.0032  vmlinux                  vmlinux                  
hash_futex
4         0.0032  vmlinux                  vmlinux                  
mod_timer
4         0.0032  vmlinux                  vmlinux                  put_page
4         0.0032  vmlinux                  vmlinux                  
run_local_timers
4         0.0032  vmlinux                  vmlinux                  
unlock_page
4         0.0032  vmlinux                  vmlinux                  
vma_adjust
4         0.0032  vmlinux                  vmlinux                  
wake_up_bit
3         0.0024  automount                automount                (no 
symbols)
3         0.0024  ld-2.5.so                ld-2.5.so                _dl_fini
3         0.0024  ld-2.5.so                ld-2.5.so                
_dl_map_object_deps
3         0.0024  ld-2.5.so                ld-2.5.so                strcmp
3         0.0024  libc-2.5.so              libc-2.5.so              
__ctype_b_loc
3         0.0024  libc-2.5.so              libc-2.5.so              fork
3         0.0024  libc-2.5.so              libc-2.5.so              
setlocale
3         0.0024  libusb-0.1.so.4.4.4      libusb-0.1.so.4.4.4      (no 
symbols)
3         0.0024  vmlinux                  vmlinux                  
__clear_user
3         0.0024  vmlinux                  vmlinux                  
__find_get_block_slow
3         0.0024  vmlinux                  vmlinux                  __getblk
3         0.0024  vmlinux                  vmlinux                  
__pte_alloc
3         0.0024  vmlinux                  vmlinux                  
__remove_shared_vm_struct
3         0.0024  vmlinux                  vmlinux                  
__set_page_dirty_nobuffers
3         0.0024  vmlinux                  vmlinux                  
add_to_page_cache
3         0.0024  vmlinux                  vmlinux                  
alloc_page_vma
3         0.0024  vmlinux                  vmlinux                  
copy_to_user
3         0.0024  vmlinux                  vmlinux                  
current_fs_time
3         0.0024  vmlinux                  vmlinux                  d_alloc
3         0.0024  vmlinux                  vmlinux                  
error_sti
3         0.0024  vmlinux                  vmlinux                  
flush_old_exec
3         0.0024  vmlinux                  vmlinux                  
get_unmapped_area
3         0.0024  vmlinux                  vmlinux                  
get_unused_fd
3         0.0024  vmlinux                  vmlinux                  
getnstimeofday
3         0.0024  vmlinux                  vmlinux                  
ip_route_input
3         0.0024  vmlinux                  vmlinux                  
lru_add_drain
3         0.0024  vmlinux                  vmlinux                  
mark_page_accessed
3         0.0024  vmlinux                  vmlinux                  mmput
3         0.0024  vmlinux                  vmlinux                  
open_namei
3         0.0024  vmlinux                  vmlinux                  
prio_tree_insert
3         0.0024  vmlinux                  vmlinux                  
remove_wait_queue
3         0.0024  vmlinux                  vmlinux                  tty_poll
3         0.0024  vmlinux                  vmlinux                  vma_link
3         0.0024  vmlinux                  vmlinux                  
vsnprintf
2         0.0016  cat                      cat                      (no 
symbols)
2         0.0016  expr                     expr                     (no 
symbols)
2         0.0016  forcedeth.ko             forcedeth                
reg_delay
2         0.0016  ld-2.5.so                ld-2.5.so                
_dl_check_map_versions
2         0.0016  ld-2.5.so                ld-2.5.so                
_dl_new_object
2         0.0016  ld-2.5.so                ld-2.5.so                
_dl_sort_fini
2         0.0016  ld-2.5.so                ld-2.5.so                
_dl_start
2         0.0016  ld-2.5.so                ld-2.5.so                
_dl_sysdep_start
2         0.0016  ld-2.5.so                ld-2.5.so                
open_verify
2         0.0016  libc-2.5.so              libc-2.5.so              
_IO_doallocbuf
2         0.0016  libc-2.5.so              libc-2.5.so              
_IO_file_fopen@@GLIBC_2.2.5
2         0.0016  libc-2.5.so              libc-2.5.so              
_IO_list_unlock
2         0.0016  libc-2.5.so              libc-2.5.so              
_IO_un_link
2         0.0016  libc-2.5.so              libc-2.5.so              
__close_nocancel
2         0.0016  libc-2.5.so              libc-2.5.so              
__ctype_get_mb_cur_max
2         0.0016  libc-2.5.so              libc-2.5.so              
__init_misc
2         0.0016  libc-2.5.so              libc-2.5.so              
_nl_intern_locale_data
2         0.0016  libc-2.5.so              libc-2.5.so              
_nl_load_locale_from_archive
2         0.0016  libc-2.5.so              libc-2.5.so              
_nl_postload_ctype
2         0.0016  libc-2.5.so              libc-2.5.so              close
2         0.0016  libc-2.5.so              libc-2.5.so              
fclose@@GLIBC_2.2.5
2         0.0016  libc-2.5.so              libc-2.5.so              getenv
2         0.0016  libc-2.5.so              libc-2.5.so              
malloc_consolidate
2         0.0016  libc-2.5.so              libc-2.5.so              memchr
2         0.0016  libc-2.5.so              libc-2.5.so              mempcpy
2         0.0016  libc-2.5.so              libc-2.5.so              memset
2         0.0016  libc-2.5.so              libc-2.5.so              
sigaction
2         0.0016  libc-2.5.so              libc-2.5.so              
strcoll_l
2         0.0016  libckyapplet.so.1.0.0    libckyapplet.so.1.0.0    (no 
symbols)
2         0.0016  libpthread-2.5.so        libpthread-2.5.so        
pthread_mutex_lock
2         0.0016  usb_storage              usb_storage              (no 
symbols)
2         0.0016  vmlinux                  vmlinux                  
__do_softirq
2         0.0016  vmlinux                  vmlinux                  __fput
2         0.0016  vmlinux                  vmlinux                  
__mark_inode_dirty
2         0.0016  vmlinux                  vmlinux                  
__pagevec_free
2         0.0016  vmlinux                  vmlinux                  
alloc_pages_current
2         0.0016  vmlinux                  vmlinux                  
bit_waitqueue
2         0.0016  vmlinux                  vmlinux                  
blk_recount_segments
2         0.0016  vmlinux                  vmlinux                  
copy_semundo
2         0.0016  vmlinux                  vmlinux                  
dnotify_parent
2         0.0016  vmlinux                  vmlinux                  
do_filp_open
2         0.0016  vmlinux                  vmlinux                  
dummy_file_permission
2         0.0016  vmlinux                  vmlinux                  
filp_close
2         0.0016  vmlinux                  vmlinux                  
generic_file_mmap
2         0.0016  vmlinux                  vmlinux                  
inotify_inode_queue_event
2         0.0016  vmlinux                  vmlinux                  ip_rcv
2         0.0016  vmlinux                  vmlinux                  kref_put
2         0.0016  vmlinux                  vmlinux                  
load_elf_binary
2         0.0016  vmlinux                  vmlinux                  may_open
2         0.0016  vmlinux                  vmlinux                  
mempool_alloc
2         0.0016  vmlinux                  vmlinux                  
mntput_no_expire
2         0.0016  vmlinux                  vmlinux                  
page_cache_readahead
2         0.0016  vmlinux                  vmlinux                  
path_release
2         0.0016  vmlinux                  vmlinux                  
percpu_counter_mod
2         0.0016  vmlinux                  vmlinux                  
permission
2         0.0016  vmlinux                  vmlinux                  
proc_lookup
2         0.0016  vmlinux                  vmlinux                  
retint_check
2         0.0016  vmlinux                  vmlinux                  
rw_verify_area
2         0.0016  vmlinux                  vmlinux                  
skb_clone
2         0.0016  vmlinux                  vmlinux                  strchr
2         0.0016  vmlinux                  vmlinux                  sys_mmap
2         0.0016  vmlinux                  vmlinux                  
unlock_buffer
2         0.0016  vmlinux                  vmlinux                  
unmap_region
2         0.0016  vmlinux                  vmlinux                  
vfs_write
2         0.0016  vmlinux                  vmlinux                  
vm_acct_memory
2         0.0016  vmlinux                  vmlinux                  
vma_merge
2         0.0016  vmlinux                  vmlinux                  
vma_prio_tree_remove
2         0.0016  vmlinux                  vmlinux                  
zonelist_policy
1        8.1e-04  dirname                  dirname                  (no 
symbols)
1        8.1e-04  forcedeth.ko             forcedeth                
nv_alloc_rx_optimized
1        8.1e-04  forcedeth.ko             forcedeth                
nv_update_linkspeed
1        8.1e-04  id                       id                       (no 
symbols)
1        8.1e-04  ld-2.5.so                ld-2.5.so                .text
1        8.1e-04  ld-2.5.so                ld-2.5.so                
__GI___fxstat
1
>
> thanks,
> Nivedita
>
>> The mother board is a Supermicro H8DME-2 with one dual core Opteron 
>> installed. The networking is provided by the on board nVidia MCP55Pro 
>> chip.
>>
>> The RT test is done using netperf 2.4.3 with the server on an IBM 
>> LS20 blade running RHEL4U2 and the Supermicro running netperf under 
>> RHEL5 with 2.6.21-rc5-rt5.
>> The Non-RT test was done on the exact same setup except 
>> 2.6.21-rc5-rt5 was loaded on the SuperMicro board.
>>
>> Cyclesoak was used to measure CPU utilization in all cases.
>>
>>
>>
>> Here are the RT results
>> ########################################################3
>> ## 2.6.21-rc5-rt5
>> #######################################################
>> $ !netper
>> netperf -l 100 -H 192.168.70.11 -t UDP_STREAM -- -m 1025
>> UDP UNIDIRECTIONAL SEND TEST from 0.0.0.0 (0.0.0.0) port 0 AF_INET to 
>> 192.168.70.11 (192.168.70.11) port 0 AF_INET
>> Socket  Message  Elapsed      Messages
>> Size    Size     Time         Okay Errors   Throughput
>> bytes   bytes    secs            #      #   10^6bits/sec
>>
>> 126976    1025   100.00    8676376      0     711.46
>> 135168           100.00    8676376            711.46
>>
>> ########## cyclesoak during test
>> $ ./cyclesoak
>> using 2 CPUs
>> System load: -0.1%
>> System load: 40.5%
>> System load: 51.6%
>> System load: 51.5%
>> System load: 50.9%
>> System load: 50.7%
>> System load: 50.8%
>> System load: 50.7%
>> System load: 50.6%
>>
>> ######## top during test
>> top - 13:26:48 up 8 min,  4 users,  load average: 1.74, 0.46, 0.15
>> Tasks: 149 total,   4 running, 145 sleeping,   0 stopped,   0 zombie
>> Cpu(s):  0.7%us, 16.8%sy, 50.6%ni,  0.0%id,  0.0%wa, 25.6%hi,  
>> 6.3%si,  0.0%st
>> Mem:   2035444k total,   465888k used,  1569556k free,    28840k buffers
>> Swap:  3068372k total,        0k used,  3068372k free,   318668k cached
>>
>>  PID USER      PR  NI  VIRT  RES  SHR S %CPU %MEM    TIME+  COMMAND
>> 3865 eadi      39  19  6804 1164  108 R  100  0.1   0:38.25 cyclesoak
>> 2715 root     -51  -5     0    0    0 S   51  0.0   0:09.52 IRQ-8406
>> 3867 eadi      25   0  6440  632  480 R   34  0.0   0:06.03 
>> netperf         19 root     -51   0     0    0    0 S   13  0.0   
>> 0:02.33 softirq-net-tx/
>> 3866 eadi      39  19  6804 1164  108 R    1  0.1   0:20.47 cyclesoak
>> 3167 root      25   0 29888 1180  888 S    0  0.1   0:00.93 automount
>> 3861 eadi      15   0 12712 1076  788 R    0  0.1   0:00.19 top
>>    1 root      18   0 10308  668  552 S    0  0.0   0:00.67 
>> init         2 root      RT   0     0    0    0 S    0  0.0   0:00.00 
>> migration/0      3 root      RT   0     0    0    0 S    0  0.0   
>> 0:00.00 posix_cpu_timer
>>    4 root     -51   0     0    0    0 S    0  0.0   0:00.00 
>> softirq-high/0
>>    5 root     -51   0     0    0    0 S    0  0.0   0:00.00 
>> softirq-timer/0
>>    6 root     -51   0     0    0    0 S    0  0.0   0:00.00 
>> softirq-net-tx/
>>    7 root     -51   0     0    0    0 S    0  0.0   0:00.00 
>> softirq-net-rx/
>>    8 root     -51   0     0    0    0 S    0  0.0   0:00.00 
>> softirq-block/0
>>
>> ########################
>> The baseline results:
>> RHEL5 with 2.6.21-rc5 kernel
>> ##############################
>>
>> $  netperf -l 100 -H 192.168.70.11 -t UDP_STREAM -- -m 1025
>>
>> UDP UNIDIRECTIONAL SEND TEST from 0.0.0.0 (0.0.0.0) port 0 AF_INET to 
>> 192.168.70.11 (192.168.70.11) port 0 AF_INET
>> Socket  Message  Elapsed      Messages
>> Size    Size     Time         Okay Errors   Throughput
>> bytes   bytes    secs            #      #   10^6bits/sec
>>
>> 126976    1025   100.00    11405485      0     935.24
>> 135168           100.00    11405485            935.24
>>
>> #######################################
>> $ ./cyclesoak
>> using 2 CPUs
>> System load:  7.6%
>> System load: 29.6%
>> System load: 29.6%
>> System load: 28.9%
>> System load: 24.9%
>> System load: 25.0%
>> System load: 24.8%
>> System load: 24.9%
>>
>> #######################################
>> top:top - 13:52:22 up 10 min,  6 users,  load average: 1.46, 0.43, 0.17
>> Tasks: 118 total,   4 running, 114 sleeping,   0 stopped,   0 zombie
>> Cpu(s):  0.5%us,  9.8%sy, 75.7%ni,  0.0%id,  0.0%wa,  5.8%hi,  
>> 8.1%si,  0.0%st
>> Mem:   2057200k total,   459128k used,  1598072k free,    29020k buffers
>> Swap:  3068372k total,        0k used,  3068372k free,   318968k cached
>>
>>  PID USER      PR  NI  VIRT  RES  SHR S %CPU %MEM    TIME+  COMMAND
>> 3882 eadi      39  19  6804 1164  108 R  100  0.1   0:52.11 cyclesoak
>> 3881 eadi      39  19  6804 1164  108 R   65  0.1   0:38.47 cyclesoak
>> 3883 eadi      15   0  6436  632  480 R   35  0.0   0:18.26 netperf
>> 3879 eadi      15   0 12580 1052  788 R    0  0.1   0:00.15 top
>>    1 root      18   0 10308  664  552 S    0  0.0   0:00.48 
>> init         2 root      RT   0     0    0    0 S    0  0.0   0:00.00 
>> migration/0
>>    3 root      34  19     0    0    0 S    0  0.0   0:00.01 ksoftirqd/0
>>    4 root      RT   0     0    0    0 S    0  0.0   0:00.00 watchdog/0
>>    5 root      RT   0     0    0    0 S    0  0.0   0:00.00 migration/1
>>    6 root      34  19     0    0    0 S    0  0.0   0:00.00 ksoftirqd/1
>>
>> Any thoughts on how to fix this?
>>
>> Thanks,
>> -Dave
>>
>>
>>
>>
>>
>>
>>
>>
>>
>>
>>
>> -
>> To unsubscribe from this list: send the line "unsubscribe 
>> linux-rt-users" in
>> the body of a message to majordomo@vger.kernel.org
>> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>
>
