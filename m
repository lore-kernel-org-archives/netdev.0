From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH v3 net-next 4/4] syncookies: use SipHash in place of SHA1
Date: Thu, 12 Jan 2017 05:17:58 -0800
Message-ID: <1484227078.15816.29.camel@edumazet-glaptop3.roam.corp.google.com>
References: <20170108125403.16355-1-Jason@zx2c4.com>
         <20170108125403.16355-5-Jason@zx2c4.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, ebiggers3@gmail.com,
        jeanphilippe.aumasson@gmail.com, gregkh@linuxfoundation.org,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: "Jason A. Donenfeld" <Jason@zx2c4.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170108125403.16355-5-Jason@zx2c4.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sun, 2017-01-08 at 13:54 +0100, Jason A. Donenfeld wrote:
> SHA1 is slower and less secure than SipHash, and so replacing syncookie
> generation with SipHash makes natural sense. Some BSDs have been doing
> this for several years in fact.
> 
> The speedup should be similar -- and even more impressive -- to the
> speedup from the sequence number fix in this series.

I confirm a nice speedup under SYNFLOOD.

sha_transform() used to consume ~12 % of cpu cycles, while the
siphash_2u64() only uses ~1.9 %

Depending on the setup, gain is about 9 %

     4.48%  [kernel]  [k] ipt_do_table                   
     4.39%  [kernel]  [k] fib_table_lookup               
     3.90%  [kernel]  [k] __netif_receive_skb_core       
     3.76%  [kernel]  [k] fib_rules_lookup               
     3.15%  [kernel]  [k] __inet_lookup_established      
     3.11%  [kernel]  [k] tcp_conn_request               
     2.51%  [kernel]  [k] tcp_v4_rcv                     
     2.42%  [kernel]  [k] tcp_make_synack                
     2.22%  [kernel]  [k] nf_iterate                     
     2.16%  [kernel]  [k] ip_rcv                         
     1.92%  [kernel]  [k] siphash_2u64                   
     1.76%  [kernel]  [k] __ip_route_output_key          
     1.73%  [kernel]  [k] mlx4_en_process_rx_cq          
     1.68%  [kernel]  [k] memcpy_erms                    
     1.59%  [kernel]  [k] __alloc_skb                    
     1.49%  [kernel]  [k] __dev_queue_xmit               
     1.48%  [kernel]  [k] kmem_cache_alloc               
     1.38%  [kernel]  [k] __local_bh_enable_ip           
     1.36%  [kernel]  [k] kmem_cache_free                
     1.21%  [kernel]  [k] ___cache_free                  
     1.09%  [kernel]  [k] __build_skb                    
     1.07%  [kernel]  [k] inet_reqsk_alloc               
     1.04%  [kernel]  [k] kfree                          
     1.04%  [kernel]  [k] ip_build_and_send_pkt          
     1.04%  [kernel]  [k] inet_gro_receive               
     1.01%  [kernel]  [k] fib_validate_source            
     0.98%  [kernel]  [k] tcp_openreq_init_rwin          
     0.98%  [kernel]  [k] inet_csk_route_req             
     0.97%  [kernel]  [k] fib_get_table                  
     0.96%  [kernel]  [k] ip_finish_output2              
     0.94%  [kernel]  [k] tcp_v4_do_rcv                  
     0.91%  [kernel]  [k] ip_local_deliver_finish        
     0.91%  [kernel]  [k] netif_skb_features             
     0.91%  [kernel]  [k] dev_hard_start_xmit         
