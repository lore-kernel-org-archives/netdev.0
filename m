From: =?ISO-8859-2?Q?Pawe=B3_Staszewski?= <pstaszewski@itcare.pl>
Subject: affinity with ixgbe and e1000 performance problem
Date: Thu, 29 Jan 2009 20:49:45 +0100
Message-ID: <49820859.5070304@itcare.pl>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-2; format=flowed
Content-Transfer-Encoding: 7bit
To: Linux Network Development list <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.iq.pl ([86.111.241.19]:59868 "EHLO smtp.iq.pl"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753023AbZA2Ttu (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 29 Jan 2009 14:49:50 -0500
Received: from unknown (HELO [192.168.1.10]) (itcare_pstaszewski@[83.7.238.38])
          (envelope-sender <pstaszewski@itcare.pl>)
          by smtp.iq.pl with AES256-SHA encrypted SMTP
          for <netdev@vger.kernel.org>; 29 Jan 2009 19:49:46 -0000
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

My configuration is:

Packets per sec stats for eth2:             eth2:        98180.64 
P/s         92751.50 P/s        190932.14 P/s

5k users (600TX/600RX Mbit/s traffic) -> ixbge (eth2) - (Routing with 
some TC rules binded on eth2) - e1000e (eth0) -> BGP internet connection


The best configuration for my config is to bind all TX queues provided 
by ixgbe to one CPU and all RX queues bind to the same cpu but different 
core:
#RX Queues
#CPU6
echo "00000040" > /proc/irq/760/smp_affinity
#CPU6
echo "00000040" > /proc/irq/759/smp_affinity
#CPU6
echo "00000040" > /proc/irq/758/smp_affinity
#CPU6
echo "00000040" > /proc/irq/757/smp_affinity
#CPU6
echo "00000040" > /proc/irq/756/smp_affinity
#CPU6
echo "00000040" > /proc/irq/755/smp_affinity
#CPU6
echo "00000040" > /proc/irq/754/smp_affinity
#CPU6
echo "00000040" > /proc/irq/753/smp_affinity

#TX Queues
#CPU7
echo "00000080" > /proc/irq/752/smp_affinity
#CPU7
echo "00000080" > /proc/irq/751/smp_affinity
#CPU7
echo "00000080" > /proc/irq/750/smp_affinity
#CPU7
echo "00000080" > /proc/irq/749/smp_affinity
#CPU7
echo "00000080" > /proc/irq/748/smp_affinity
#CPU7
echo "00000080" > /proc/irq/747/smp_affinity
#CPU7
echo "00000080" > /proc/irq/746/smp_affinity
#CPU7
echo "00000080" > /proc/irq/745/smp_affinity

 cat /proc/interrupts
           CPU0       CPU1       CPU2       CPU3       CPU4       
CPU5       CPU6       CPU7
  0:        591          0          1          1          1          
0          0          0   IO-APIC-edge      timer
  1:          0          0          0          1          1          
0          0          0   IO-APIC-edge      i8042
  2:          0          0          0          0          0          
0          0          0    XT-PIC-XT        cascade
 14:     298406      51463       7792      27548      29476      
12089      26505       6341   IO-APIC-edge      ata_piix
 15:     287429      51187       9248      30188      31580      
13463      29119       7235   IO-APIC-edge      ata_piix
 18:          0          0          0          0          0          
0          0          0   IO-APIC-fasteoi   ata_piix
743:          1          1          1          0          0          
1          1          0   PCI-MSI-edge      ioat-msi
744:          0          0          0          0          0          
0          0          0   PCI-MSI-edge      eth2:lsc
745:     318172     317655     317562     317142     316876     
316799     317974  739013828   PCI-MSI-edge      eth2:v15-Tx
746:     298137     298211     296740     296939     296282  
739759610     297614    7438163   PCI-MSI-edge      eth2:v14-Tx
747:    1559123  644402799   99789617     287701     288215     
287857     288616    7154951   PCI-MSI-edge      eth2:v13-Tx
748:     373710     374356     372706     372433     372002     375131  
733662933    8555427   PCI-MSI-edge      eth2:v12-Tx
749:     221412     219233     218593  705892020     219134     
218514     219799    6793416   PCI-MSI-edge      eth2:v11-Tx
750:     262658     263363  748062639     261498     261082     
261410     262243    7321505   PCI-MSI-edge      eth2:v10-Tx
751:     240273    1480823     236860     237611     237130     
237598     238502  728687718   PCI-MSI-edge      eth2:v9-Tx
752:     294598     295005     291885     292774     293686  
727173598    2115060    6725300   PCI-MSI-edge      eth2:v8-Tx
753:     258014     257817     742505     259197     259043    
1342576    6479474  856607531   PCI-MSI-edge      eth2:v7-Rx
754:     334267     335255     835205     336807     336132  
868562084    6543966    1158909   PCI-MSI-edge      eth2:v6-Rx
755:    3690754     390454  852176660     393161     392236     
391953    6662034    1213866   PCI-MSI-edge      eth2:v5-Rx
756:     379899     379343    1952782     381682     382621     
381935    6740919  851518995   PCI-MSI-edge      eth2:v4-Rx
757:     373727     821494     376012  872120928     376909    
2522737    5248042    1171367   PCI-MSI-edge      eth2:v3-Rx
758:     223936     664130  859120583     225014     225297    
2405058    5048689     992416   PCI-MSI-edge      eth2:v2-Rx
759:     266000  867871307     268377     268467     267702    
2436081    3993157    1036480   PCI-MSI-edge      eth2:v1-Rx
760:     223649    1674767     224738     223864     223143    2437023  
873857572    1004736   PCI-MSI-edge      eth2:v0-Rx
761:         44         38         29         42         31      
91396         33         34   PCI-MSI-edge      eth1
762:     648754     647796     648500     647914 1945303547     
647749     648492     711525   PCI-MSI-edge      eth0
NMI:   26666124  252632331  481690098  271053301 1186861381  286981764  
268209667  474805931   Non-maskable interrupts
LOC:   39356847   18286535   20866132    5677806 2611924653    3781095   
13778136    5061266   Local timer interrupts
RES:       2885       1810       1957       1444       1435        
713       1984       1927   Rescheduling interrupts
CAL:        399       1164       1136       1142       1179       
1179       1122       1149   Function call interrupts
TLB:       9175       2609      14009      11160       3887       
2385      11260      14634   TLB shootdowns
SPU:          0          0          0          0          0          
0          0          0   Spurious interrupts
ERR:          0
MIS:          0


On all different configurations i have problem with CPU load
because if i put all interrupts from ixgbe driver to one CPU i have 
60-70% of CPU load
But if i put Only TX on one cpu i have 1% to 2%  CPU load that TX make
And RX only on CPU6 make about 37% cpu load

mpstat -P ALL 1 30
Average:     CPU   %user   %nice    %sys %iowait    %irq   %soft  
%steal   %idle    intr/s
Average:     all    0.01    0.00    0.01    0.00    0.49    7.13    
0.00   92.36 193371.81
Average:       0    0.00    0.00    0.00    0.00    0.00    0.00    
0.00  100.00      0.00
Average:       1    0.00    0.00    0.00    0.00    0.00    0.00    
0.00  100.00      0.00
Average:       2    0.00    0.00    0.10    0.00    0.00    0.00    
0.00   99.90      0.00
Average:       3    0.00    0.00    0.00    0.00    0.00    0.00    
0.00  100.00      0.00
Average:       4    0.07    0.00    0.03    0.00    1.00   22.18    
0.00   76.72   9576.51
Average:       5    0.00    0.00    0.00    0.00    0.00    0.00    
0.00  100.00      0.53
Average:       6    0.00    0.00    0.00    0.00    2.64   37.04    
0.00   60.31  79676.44
Average:       7    0.00    0.00    0.00    0.00    0.41    0.14    
0.00   99.45  61901.23


And another thing is that my e1000e driver is make the same volume of 
traffic that ixgbe but e1000e make only 22% CPU load (is binded to cpu 4 
by affinity)
And why ixgbe driver is make x10 more interrupst per sec compared to 
e1000e driver

only difference is that on eth2 i have 200vlans and traffic is on this 
vlans with 5000 tc rules (with hashing filters)

opreport -l
CPU: Core 2, speed 3000 MHz (estimated)
Counted CPU_CLK_UNHALTED events (Clock cycles when not halted) with a 
unit mask of 0x00 (Unhalted core cycles) count 100000
samples  %        image name               app name                 
symbol name
76985     8.0647  vmlinux                  vmlinux                  
do_ipt_get_ctl
63374     6.6389  vmlinux                  vmlinux                  
u32_delete
34018     3.5636  vmlinux                  vmlinux                  
_raw_spin_trylock
24586     2.5755  vmlinux                  vmlinux                  
__ip_route_output_key
24534     2.5701  vmlinux                  vmlinux                  
update_persistent_clock
22736     2.3817  vmlinux                  vmlinux                  
e1000_get_eeprom
21037     2.2038  vmlinux                  vmlinux                  
irq_entries_start
19653     2.0588  vmlinux                  vmlinux                  
__pskb_pull_tail
19329     2.0248  vmlinux                  vmlinux                  
ixgbe_update_rx_dca
18826     1.9721  vmlinux                  vmlinux                  
devm_ioport_unmap
16959     1.7766  vmlinux                  vmlinux                  
ixgbe_alloc_rx_buffers
16188     1.6958  vmlinux                  vmlinux                  
e1000_open
15642     1.6386  vmlinux                  vmlinux                  
htb_dequeue
13627     1.4275  vmlinux                  vmlinux                  
ctrl_dumpfamily
13511     1.4154  vmlinux                  vmlinux                  
native_calibrate_tsc
11485     1.2031  vmlinux                  vmlinux                  
dev_ethtool
11449     1.1994  vmlinux                  vmlinux                  
mach_set_rtc_mmss
11405     1.1948  vmlinux                  vmlinux                  
update_wall_time
11221     1.1755  vmlinux                  vmlinux                  
dev_seq_show
10932     1.1452  vmlinux                  vmlinux                  
ip_route_input
10816     1.1330  vmlinux                  vmlinux                  
ixgbe_clean_rx_irq
10498     1.0997  vmlinux                  vmlinux                  
e1000_clean_rx_irq_ps
10439     1.0936  vmlinux                  vmlinux                  
skb_copy_and_csum_bits
10299     1.0789  vmlinux                  vmlinux                  
devm_ioport_map
10290     1.0779  vmlinux                  vmlinux                  
e1000_xmit_frame
10198     1.0683  vmlinux                  vmlinux                  
text_poke
10105     1.0586  vmlinux                  vmlinux                  
ixgbe_setup_dca
9967      1.0441  vmlinux                  vmlinux                  
ixgbe_vlan_rx_kill_vid
9755      1.0219  vmlinux                  vmlinux                  
xt_check_match
9379      0.9825  vmlinux                  vmlinux                  sfq_init
9159      0.9595  vmlinux                  vmlinux                  
ixgbe_clean_tx_irq
9091      0.9523  vmlinux                  vmlinux                  
hfsc_reset_qdisc
8879      0.9301  vmlinux                  vmlinux                  udp_mt
8874      0.9296  vmlinux                  vmlinux                  
devm_ioremap
8347      0.8744  vmlinux                  vmlinux                  
rwlock_bug
8181      0.8570  vmlinux                  vmlinux                  
ixgbe_xmit_frame
7502      0.7859  vmlinux                  vmlinux                  
htb_delete
7199      0.7541  vmlinux                  vmlinux                  
ip_defrag
6532      0.6843  vmlinux                  vmlinux                  htb_init
6279      0.6578  vmlinux                  vmlinux                  
dev_queue_xmit
6264      0.6562  vmlinux                  vmlinux                  
apply_alternatives
6252      0.6549  vmlinux                  vmlinux                  
ixgbe_configure
6190      0.6484  vmlinux                  vmlinux                  
posix_cpu_timer_del
6110      0.6401  vmlinux                  vmlinux                  
radix_tree_delete
5875      0.6154  vmlinux                  vmlinux                  s_stop
5496      0.5757  vmlinux                  vmlinux                  
ip_push_pending_frames
5398      0.5655  vmlinux                  vmlinux                  
fib_rules_register
5007      0.5245  vmlinux                  vmlinux                  
ixgbe_init_interrupt_scheme
4908      0.5141  vmlinux                  vmlinux                  
do_sysinfo
4821      0.5050  vmlinux                  vmlinux                  
e1000e_update_stats
4722      0.4947  vmlinux                  vmlinux                  
_format_mac_addr
4219      0.4420  vmlinux                  vmlinux                  
__local_trigger
4141      0.4338  vmlinux                  vmlinux                  
genl_register_mc_group
3805      0.3986  vmlinux                  vmlinux                  
cache_alloc_refill
3678      0.3853  vmlinux                  vmlinux                  
packet_rcv
3548      0.3717  vmlinux                  vmlinux                  
tc_ctl_action

