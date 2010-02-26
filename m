From: Paul Gortmaker <paul.gortmaker@windriver.com>
Subject: Re: Gianfar driver failing on MPC8641D based board
Date: Fri, 26 Feb 2010 11:27:42 -0500
Message-ID: <4B87F67E.5070601@windriver.com>
References: <4B86A97E.6050509@ge.com> <20100225165141.GA9686@oksana.dev.rtsoft.ru> <20100225174935.GA32370@oksana.dev.rtsoft.ru> <7d1d9c251002251653n6473f01ex2d43933ec6aa010b@mail.gmail.com> <20100226031452.GA11319@oksana.dev.rtsoft.ru> <4B87B937.6010204@ge.com> <20100226143532.GA31622@oksana.dev.rtsoft.ru> <4B87E01E.4070704@windriver.com> <4B87E662.3080106@ge.com> <4B87E9EF.3010604@ge.com> <20100226161058.GA22954@oksana.dev.rtsoft.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: Martyn Welch <martyn.welch@ge.com>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org,
	linuxppc-dev list <linuxppc-dev@ozlabs.org>,
	Sandeep Gopalpet <Sandeep.Kumar@freescale.com>,
	davem@davemloft.net
To: avorontsov@ru.mvista.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20100226161058.GA22954@oksana.dev.rtsoft.ru>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 10-02-26 11:10 AM, Anton Vorontsov wrote:
> On Fri, Feb 26, 2010 at 03:34:07PM +0000, Martyn Welch wrote:
> [...]
>> Out of 10 boot attempts, 7 failed.
> 
> OK, I see why. With ip=on (dhcp boot) it's much harder to trigger
> it. With static ip config can I see the same.

I'd kind of expected to see us stuck in gianfar on that lock, but
the SysRQ-T doesn't show us hung up anywhere in gianfar itself.
[This was on a base 2.6.33, with just a small sysrq fix patch]

Paul.

----------

SysRq : Changing Loglevel                                            
Loglevel set to 9                                                               
nfs: server not responding, still trying                          
SysRq : Show State                                                              
  task                PC stack   pid father                                     
init          D 0ff1c380     0     1      0 0x00000000                          
Call Trace:                                                                     
[df841a30] [c0009fc4] __switch_to+0x8c/0xf8                                     
[df841a50] [c0350160] schedule+0x354/0x92c                                      
[df841ae0] [c0331394] rpc_wait_bit_killable+0x2c/0x54                           
[df841af0] [c0350eb0] __wait_on_bit+0x9c/0x108                                  
[df841b10] [c0350fc0] out_of_line_wait_on_bit+0xa4/0xb4                         
[df841b40] [c0331cf0] __rpc_execute+0x16c/0x398                                 
[df841b90] [c0329abc] rpc_run_task+0x48/0x9c                                    
[df841ba0] [c0329c40] rpc_call_sync+0x54/0x88                                   
[df841bd0] [c015e780] nfs_proc_lookup+0x94/0xe8                                 
[df841c20] [c014eb60] nfs_lookup+0x12c/0x230                                    
[df841d50] [c00b9680] do_lookup+0x118/0x288                                     
[df841d80] [c00bb904] link_path_walk+0x194/0x1118                               
[df841df0] [c00bcb08] path_walk+0x8c/0x168                                      
[df841e20] [c00bcd6c] do_path_lookup+0x74/0x7c                                  
[df841e40] [c00be148] do_filp_open+0x5d4/0xba4                                  
[df841f10] [c00abe94] do_sys_open+0xac/0x190                                    
[df841f40] [c001437c] ret_from_syscall+0x0/0x38                                 
--- Exception: c01 at 0xff1c380                                                 
    LR = 0xfec6d98                                                              
kthreadd      S 00000000     0     2      0 0x00000000                          
Call Trace:                                                                     
[df843e50] [c002e788] wake_up_new_task+0x128/0x16c (unreliable)                 
[df843f10] [c0009fc4] __switch_to+0x8c/0xf8                                     
[df843f30] [c0350160] schedule+0x354/0x92c                                      
[df843fc0] [c004d154] kthreadd+0x130/0x134                                      
[df843ff0] [c00141a0] kernel_thread+0x4c/0x68                                   
migration/0   S 00000000     0     3      2 0x00000000                          
Call Trace:                                                                     
[df847de0] [ffffffff] 0xffffffff (unreliable)                                   
[df847ea0] [c0009fc4] __switch_to+0x8c/0xf8                                     
[df847ec0] [c0350160] schedule+0x354/0x92c                                      
[df847f50] [c002d074] migration_thread+0x29c/0x448                              
[df847fb0] [c004d020] kthread+0x80/0x84                                         
[df847ff0] [c00141a0] kernel_thread+0x4c/0x68                                   
ksoftirqd/0   S 00000000     0     4      2 0x00000000                          
Call Trace:                                                                     
[df84be10] [00000800] 0x800 (unreliable)                                        
[df84bed0] [c0009fc4] __switch_to+0x8c/0xf8                                     
[df84bef0] [c0350160] schedule+0x354/0x92c                                      
[df84bf80] [c0038454] run_ksoftirqd+0x14c/0x1e0                                 
[df84bfb0] [c004d020] kthread+0x80/0x84                                         
[df84bff0] [c00141a0] kernel_thread+0x4c/0x68                                   
watchdog/0    S 00000000     0     5      2 0x00000000                          
Call Trace:                                                                     
[df84dee0] [c0009fc4] __switch_to+0x8c/0xf8                                     
[df84df00] [c0350160] schedule+0x354/0x92c                                      
[df84df90] [c006b8e8] watchdog+0x48/0x88                                        
[df84dfb0] [c004d020] kthread+0x80/0x84                                         
[df84dff0] [c00141a0] kernel_thread+0x4c/0x68                                   
migration/1   S 00000000     0     6      2 0x00000000                          
Call Trace:                                                                     
[df84fea0] [c0009fc4] __switch_to+0x8c/0xf8                                     
[df84fec0] [c0350160] schedule+0x354/0x92c                                      
[df84ff50] [c002d074] migration_thread+0x29c/0x448                              
[df84ffb0] [c004d020] kthread+0x80/0x84                                         
[df84fff0] [c00141a0] kernel_thread+0x4c/0x68                                   
ksoftirqd/1   S 00000000     0     7      2 0x00000000                          
Call Trace:                                                                     
[df853ed0] [c0009fc4] __switch_to+0x8c/0xf8                                     
[df853ef0] [c0350160] schedule+0x354/0x92c                                      
[df853f80] [c0038454] run_ksoftirqd+0x14c/0x1e0                                 
[df853fb0] [c004d020] kthread+0x80/0x84                                         
[df853ff0] [c00141a0] kernel_thread+0x4c/0x68                                   
watchdog/1    S 00000000     0     8      2 0x00000000                          
Call Trace:                                                                     
[df857ee0] [c0009fc4] __switch_to+0x8c/0xf8                                     
[df857f00] [c0350160] schedule+0x354/0x92c                                      
[df857f90] [c006b8e8] watchdog+0x48/0x88                                        
[df857fb0] [c004d020] kthread+0x80/0x84                                         
[df857ff0] [c00141a0] kernel_thread+0x4c/0x68                                   
events/0      S 00000000     0     9      2 0x00000000                          
Call Trace:                                                                     
[df859ea0] [c0009fc4] __switch_to+0x8c/0xf8                                     
[df859ec0] [c0350160] schedule+0x354/0x92c                                      
[df859f50] [c0048718] worker_thread+0x1fc/0x200                                 
[df859fb0] [c004d020] kthread+0x80/0x84                                         
[df859ff0] [c00141a0] kernel_thread+0x4c/0x68                                   
events/1      S 00000000     0    10      2 0x00000000                          
Call Trace:                                                                     
[df85bea0] [c0009fc4] __switch_to+0x8c/0xf8                                     
[df85bec0] [c0350160] schedule+0x354/0x92c                                      
[df85bf50] [c0048718] worker_thread+0x1fc/0x200                                 
[df85bfb0] [c004d020] kthread+0x80/0x84                                         
[df85bff0] [c00141a0] kernel_thread+0x4c/0x68                                   
khelper       S 00000000     0    11      2 0x00000000                          
Call Trace:                                                                     
[df85dde0] [c0030564] do_fork+0x1b0/0x344 (unreliable)                          
[df85dea0] [c0009fc4] __switch_to+0x8c/0xf8                                     
[df85dec0] [c0350160] schedule+0x354/0x92c                                      
[df85df50] [c0048718] worker_thread+0x1fc/0x200                                 
[df85dfb0] [c004d020] kthread+0x80/0x84                                         
[df85dff0] [c00141a0] kernel_thread+0x4c/0x68                                   
async/mgr     S 00000000     0    15      2 0x00000000                          
Call Trace:                                                                     
[df8a7df0] [000000fc] 0xfc (unreliable)                                         
[df8a7eb0] [c0009fc4] __switch_to+0x8c/0xf8                                     
[df8a7ed0] [c0350160] schedule+0x354/0x92c                                      
[df8a7f60] [c00565c0] async_manager_thread+0x120/0x174                          
[df8a7fb0] [c004d020] kthread+0x80/0x84                                         
[df8a7ff0] [c00141a0] kernel_thread+0x4c/0x68                                   
sync_supers   S 00000000     0    85      2 0x00000000                          
Call Trace:                                                                     
[df951e30] [00000400] 0x400 (unreliable)                                        
[df951ef0] [c0009fc4] __switch_to+0x8c/0xf8                                     
[df951f10] [c0350160] schedule+0x354/0x92c                                      
[df951fa0] [c008d714] bdi_sync_supers+0x30/0x5c                                 
[df951fb0] [c004d020] kthread+0x80/0x84                                         
[df951ff0] [c00141a0] kernel_thread+0x4c/0x68                                   
bdi-default   S 00000000     0    87      2 0x00000000                          
Call Trace:                                                                     
[df957e30] [c0009fc4] __switch_to+0x8c/0xf8                                     
[df957e50] [c0350160] schedule+0x354/0x92c                                      
[df957ee0] [c0350b14] schedule_timeout+0x15c/0x23c                              
[df957f30] [c008e510] bdi_forker_task+0x2f8/0x30c                               
[df957fb0] [c004d020] kthread+0x80/0x84                                         
[df957ff0] [c00141a0] kernel_thread+0x4c/0x68                                   
kblockd/0     S 00000000     0    88      2 0x00000000                          
Call Trace:                                                                     
[df8bdde0] [00000800] 0x800 (unreliable)                                        
[df8bdea0] [c0009fc4] __switch_to+0x8c/0xf8                                     
[df8bdec0] [c0350160] schedule+0x354/0x92c                                      
[df8bdf50] [c0048718] worker_thread+0x1fc/0x200                                 
[df8bdfb0] [c004d020] kthread+0x80/0x84                                         
[df8bdff0] [c00141a0] kernel_thread+0x4c/0x68                                   
kblockd/1     S 00000000     0    89      2 0x00000000                          
Call Trace:                                                                     
[df959de0] [00000800] 0x800 (unreliable)                                        
[df959ea0] [c0009fc4] __switch_to+0x8c/0xf8                                     
[df959ec0] [c0350160] schedule+0x354/0x92c                                      
[df959f50] [c0048718] worker_thread+0x1fc/0x200                                 
[df959fb0] [c004d020] kthread+0x80/0x84                                         
[df959ff0] [c00141a0] kernel_thread+0x4c/0x68                                   
rpciod/0      S 00000000     0   111      2 0x00000000                          
Call Trace:                                                                     
[df93fea0] [c0009fc4] __switch_to+0x8c/0xf8                                     
[df93fec0] [c0350160] schedule+0x354/0x92c                                      
[df93ff50] [c0048718] worker_thread+0x1fc/0x200                                 
[df93ffb0] [c004d020] kthread+0x80/0x84                                         
[df93fff0] [c00141a0] kernel_thread+0x4c/0x68                                   
rpciod/1      S 00000000     0   112      2 0x00000000                          
Call Trace:                                                                     
[df931de0] [00000001] 0x1 (unreliable)                                          
[df931ea0] [c0009fc4] __switch_to+0x8c/0xf8                                     
[df931ec0] [c0350160] schedule+0x354/0x92c                                      
[df931f50] [c0048718] worker_thread+0x1fc/0x200                                 
[df931fb0] [c004d020] kthread+0x80/0x84                                         
[df931ff0] [c00141a0] kernel_thread+0x4c/0x68                                   
khungtaskd    S 00000000     0   141      2 0x00000000                          
Call Trace:                                                                     
[df979db0] [00000800] 0x800 (unreliable)                                        
[df979e70] [c0009fc4] __switch_to+0x8c/0xf8                                     
[df979e90] [c0350160] schedule+0x354/0x92c                                      
[df979f20] [c0350b14] schedule_timeout+0x15c/0x23c                              
[df979f70] [c006bd38] watchdog+0x98/0x294                                       
[df979fb0] [c004d020] kthread+0x80/0x84                                         
[df979ff0] [c00141a0] kernel_thread+0x4c/0x68                                   
kswapd0       S 00000000     0   142      2 0x00000000                          
Call Trace:                                                                     
[df97bd60] [c04383a0] 0xc04383a0 (unreliable)                                   
[df97be20] [c0009fc4] __switch_to+0x8c/0xf8                                     
[df97be40] [c0350160] schedule+0x354/0x92c                                      
[df97bed0] [c00868a8] kswapd+0x81c/0x858                                        
[df97bfb0] [c004d020] kthread+0x80/0x84                                         
[df97bff0] [c00141a0] kernel_thread+0x4c/0x68                                   
aio/0         S 00000000     0   143      2 0x00000000                          
Call Trace:                                                                     
[df97dde0] [ffffffff] 0xffffffff (unreliable)                                   
[df97dea0] [c0009fc4] __switch_to+0x8c/0xf8                                     
[df97dec0] [c0350160] schedule+0x354/0x92c                                      
[df97df50] [c0048718] worker_thread+0x1fc/0x200                                 
[df97dfb0] [c004d020] kthread+0x80/0x84                                         
[df97dff0] [c00141a0] kernel_thread+0x4c/0x68                                   
aio/1         S 00000000     0   144      2 0x00000000                          
Call Trace:                                                                     
[df97fde0] [ffffffff] 0xffffffff (unreliable)                                   
[df97fea0] [c0009fc4] __switch_to+0x8c/0xf8                                     
[df97fec0] [c0350160] schedule+0x354/0x92c                                      
[df97ff50] [c0048718] worker_thread+0x1fc/0x200                                 
[df97ffb0] [c004d020] kthread+0x80/0x84                                         
[df97fff0] [c00141a0] kernel_thread+0x4c/0x68                                   
nfsiod        S 00000000     0   145      2 0x00000000                          
Call Trace:                                                                     
[df9a5de0] [00000003] 0x3 (unreliable)                                          
[df9a5ea0] [c0009fc4] __switch_to+0x8c/0xf8                                     
[df9a5ec0] [c0350160] schedule+0x354/0x92c                                      
[df9a5f50] [c0048718] worker_thread+0x1fc/0x200                                 
[df9a5fb0] [c004d020] kthread+0x80/0x84                                         
[df9a5ff0] [c00141a0] kernel_thread+0x4c/0x68                                   
crypto/0      S 00000000     0   146      2 0x00000000                          
Call Trace:                                                                     
[df9a7de0] [00000800] 0x800 (unreliable)                                        
[df9a7ea0] [c0009fc4] __switch_to+0x8c/0xf8                                     
[df9a7ec0] [c0350160] schedule+0x354/0x92c                                      
[df9a7f50] [c0048718] worker_thread+0x1fc/0x200                                 
[df9a7fb0] [c004d020] kthread+0x80/0x84                                         
[df9a7ff0] [c00141a0] kernel_thread+0x4c/0x68                                   
crypto/1      S 00000000     0   147      2 0x00000000                          
Call Trace:                                                                     
[df9a9ea0] [c0009fc4] __switch_to+0x8c/0xf8                                     
[df9a9ec0] [c0350160] schedule+0x354/0x92c                                      
[df9a9f50] [c0048718] worker_thread+0x1fc/0x200                                 
[df9a9fb0] [c004d020] kthread+0x80/0x84                                         
[df9a9ff0] [c00141a0] kernel_thread+0x4c/0x68                                   
mtdblockd     S 00000000     0   779      2 0x00000000                          
Call Trace:                                                                     
[dfae1e00] [00000800] 0x800 (unreliable)                                        
[dfae1ec0] [c0009fc4] __switch_to+0x8c/0xf8                                     
[dfae1ee0] [c0350160] schedule+0x354/0x92c                                      
[dfae1f70] [c02232dc] mtd_blktrans_thread+0x1c4/0x394                           
[dfae1fb0] [c004d020] kthread+0x80/0x84                                         
[dfae1ff0] [c00141a0] kernel_thread+0x4c/0x68                                   
kstriped      S 00000000     0   826      2 0x00000000                          
Call Trace:                                                                     
[df935de0] [00000800] 0x800 (unreliable)                                        
[df935ea0] [c0009fc4] __switch_to+0x8c/0xf8                                     
[df935ec0] [c0350160] schedule+0x354/0x92c                                      
[df935f50] [c0048718] worker_thread+0x1fc/0x200                                 
[df935fb0] [c004d020] kthread+0x80/0x84                                         
[df935ff0] [c00141a0] kernel_thread+0x4c/0x68                                   
ksnapd        S 00000000     0   828      2 0x00000000                          
Call Trace:                                                                     
[dfae9de0] [00000800] 0x800 (unreliable)                                        
[dfae9ea0] [c0009fc4] __switch_to+0x8c/0xf8                                     
[dfae9ec0] [c0350160] schedule+0x354/0x92c                                      
[dfae9f50] [c0048718] worker_thread+0x1fc/0x200                                 
[dfae9fb0] [c004d020] kthread+0x80/0x84                                         
[dfae9ff0] [c00141a0] kernel_thread+0x4c/0x68                                   
Sched Debug Version: v0.09, 2.6.33-00001-g8c31d07 #1                            
now at 35747.705693 msecs                                                       
  .jiffies                                 : 4294901234                         
  .sysctl_sched_latency                    : 10.000000                          
  .sysctl_sched_min_granularity            : 2.000000                           
  .sysctl_sched_wakeup_granularity         : 2.000000                           
  .sysctl_sched_child_runs_first           : 0.000000                           
  .sysctl_sched_features                   : 7917179                            
  .sysctl_sched_tunable_scaling            : 1 (logaritmic)                     
                                                                                
cpu#0                                                                           
  .nr_running                    : 0                                            
  .load                          : 0                                            
  .nr_switches                   : 2809                                         
  .nr_load_updates               : 8950                                         
  .nr_uninterruptible            : 1                                            
  .next_balance                  : 4294.901248                                  
  .curr->pid                     : 0                                            
  .clock                         : 35832.063536                                 
  .cpu_load[0]                   : 0                                            
  .cpu_load[1]                   : 0                                            
  .cpu_load[2]                   : 0                                            
  .cpu_load[3]                   : 0                                            
  .cpu_load[4]                   : 0                                            
                                                                                
cfs_rq[0] for UID: 0                                                            
  .exec_clock                    : 0.000000                                     
  .MIN_vruntime                  : 0.000001                                     
  .min_vruntime                  : 4129.195888                                  
  .max_vruntime                  : 0.000001                                     
  .spread                        : 0.000000                                     
  .spread0                       : 4048.261385                                  
  .nr_running                    : 0                                            
  .load                          : 0                                            
  .nr_spread_over                : 0                                            
  .shares                        : 0                                            
  .se->exec_start                : 35836.116992                                 
  .se->vruntime                  : 80.934503                                    
  .se->sum_exec_runtime          : 123.815984                                   
  .se->load.weight               : 1024                                         
                                                                                
rt_rq[0]:                                                                       
  .rt_nr_running                 : 0                                            
  .rt_throttled                  : 0                                            
  .rt_time                       : 0.000000                                     
  .rt_runtime                    : 950.000000                                   
                                                                                
runnable tasks:                                                                 
            task   PID         tree-key  switches  prio     exec-runtime        
 sum-exec        sum-sleep                                                      
--------------------------------------------------------------------------------
--------------------------                                                      
                                                                                
cpu#1                                                                           
  .nr_running                    : 0                                            
  .load                          : 0                                            
  .nr_switches                   : 4069                                         
  .nr_load_updates               : 8689                                         
  .nr_uninterruptible            : 0                                            
  .next_balance                  : 4294.901019                                  
  .curr->pid                     : 0                                            
  .clock                         : 34909.104304                                 
  .cpu_load[0]                   : 0                                            
  .cpu_load[1]                   : 0                                            
  .cpu_load[2]                   : 0                                            
  .cpu_load[3]                   : 0                                            
  .cpu_load[4]                   : 0                                            
                                                                                
cfs_rq[1] for UID: 0                                                            
  .exec_clock                    : 0.000000                                     
  .MIN_vruntime                  : 0.000001                                     
  .min_vruntime                  : 509.424556                                   
  .max_vruntime                  : 0.000001                                     
  .spread                        : 0.000000                                     
  .spread0                       : 428.490053                                   
  .nr_running                    : 0                                            
  .load                          : 0                                            
  .nr_spread_over                : 0                                            
  .shares                        : 0                                            
  .se->exec_start                : 34909.104304                                 
  .se->vruntime                  : 273.153007                                   
  .se->sum_exec_runtime          : 503.971344                                   
  .se->load.weight               : 1024                                         
                                                                                
rt_rq[1]:                                                                       
  .rt_nr_running                 : 0                                            
  .rt_throttled                  : 0                                            
  .rt_time                       : 0.000000                                     
  .rt_runtime                    : 950.000000                                   
                                                                                
runnable tasks:                                                                 
            task   PID         tree-key  switches  prio     exec-runtime        
 sum-exec        sum-sleep                                                      
--------------------------------------------------------------------------------
--------------------------                                                      
                              
