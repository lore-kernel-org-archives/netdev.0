From: Dave Hansen <haveblue@us.ibm.com>
Subject: impressive throughput on 2.5.73
Date: 02 Jul 2003 17:56:07 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <1057193766.31286.843.camel@nighthawk>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Scott Feldman <scott.feldman@intel.com>, Nivedita Singhvi <niv@us.ibm.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

I run a little script to load up a gigabit ethernet link between two of
my machines: an 8-way PIII web server, and a 4-way PIII client.  Both
client and server have e1000s.  The script fetches a bunch of fairly big
files via http from the server, using apache.  I'm impressed that it can
fill just about the entire gigabit pipe, while using less than 1 of the
server's CPUs.  

176 requests/sec - 110.0 MB/second - 0.6 MB/request

Server CPU breakdown.
 2% system
 7% user
91% idle

I'm not using any interrupt mitigation, so I'm still at ~9k
interrupts/sec.  I'll try NAPI next.

server profile:
197212 total                                      0.1159
175783 poll_idle                                2441.4306
  1474 alloc_skb                                  6.8241
  1281 skb_release_data                           8.6554
  1202 skb_clone                                  3.7563
  1038 do_tcp_sendpages                           0.3655
   998 e1000_clean_tx_irq                         2.1886
   974 e1000_xmit_frame                           0.5148
   841 tcp_transmit_skb                           0.5729
   827 Letext                                     2.0675
   791 __kmalloc                                  6.3790
   739 ip_queue_xmit                              0.6415
   629 ip_finish_output                           1.4976
   583 tcp_write_xmit                             0.7836
   571 tcp_v4_rcv                                 0.2896
   422 schedule                                   0.2733
   417 e1000_intr                                 3.7232
   403 tcp_clean_rtx_queue                        0.5140
   399 __kfree_skb                                2.1685
   353 kfree                                      3.6771
   337 kmem_cache_free                            4.4342
   309 e1000_clean_rx_irq                         0.3053
   291 find_get_page                              6.0625
   284 do_softirq                                 1.4200
   246 eth_type_trans                             1.4643
   233 dev_queue_xmit                             0.4380
   226 __wake_up                                  5.1364
   216 ip_rcv                                     0.2093
   202 sock_wfree                                 3.3667
   202 memcpy                                     5.0500

client profile:
 33363 total                                      0.0196
  9575 poll_idle                                132.9861
  5099 __copy_user_intel                         32.6859
  3307 schedule                                   2.1418
  1753 __wake_up                                 39.8409
   667 tcp_v4_rcv                                 0.3382
   577 pipe_write                                 0.7970
   510 __down_wq                                  1.7708
   488 alloc_skb                                  2.2593
   476 tcp_recvmsg                                0.2216
   457 tcp_rcv_established                        0.2746
   457 __kfree_skb                                2.4837
   405 dnotify_parent                             4.5000
   382 pipe_read                                  0.7290
   368 system_call                                8.3636
   350 kill_fasync                                7.0000
   341 current_kernel_time                        5.0147
   299 __kmalloc                                  2.4113
   280 ip_rcv                                     0.2713
   252 eth_type_trans                             1.5000
   245 skb_release_data                           1.6554
   233 ip_queue_xmit                              0.2023
   232 kfree                                      2.4167
   228 e1000_clean_rx_irq                         0.2253
   210 pipe_wait                                  1.3816
   205 e1000_clean_tx_irq                         0.4496
   200 tcp_transmit_skb                           0.1362
   199 e1000_xmit_frame                           0.1052

-- 
Dave Hansen
haveblue@us.ibm.com
