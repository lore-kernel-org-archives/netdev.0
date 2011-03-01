From: Thomas Graf <tgraf@infradead.org>
Subject: Re: SO_REUSEPORT - can it be done in kernel?
Date: Tue, 1 Mar 2011 09:22:35 -0500
Message-ID: <20110301142235.GA10761@canuck.infradead.org>
References: <20110301101955.GI9763@canuck.infradead.org>
 <1298975602.3284.13.camel@edumazet-laptop>
 <20110301110708.GJ9763@canuck.infradead.org>
 <1298977984.3284.15.camel@edumazet-laptop>
 <20110301112759.GK9763@canuck.infradead.org>
 <1298979909.3284.28.camel@edumazet-laptop>
 <20110301121829.GM9763@canuck.infradead.org>
 <20110301121951.GA7267@gondor.apana.org.au>
 <20110301135053.GA6684@canuck.infradead.org>
 <1298988419.3284.107.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Herbert Xu <herbert@gondor.apana.org.au>,
	David Miller <davem@davemloft.net>, rick.jones2@hp.com,
	therbert@google.com, wsommerfeld@google.com,
	daniel.baluta@gmail.com, netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from bombadil.infradead.org ([18.85.46.34]:35643 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754006Ab1CAOWn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 1 Mar 2011 09:22:43 -0500
Content-Disposition: inline
In-Reply-To: <1298988419.3284.107.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Mar 01, 2011 at 03:06:59PM +0100, Eric Dumazet wrote:
> Would be nice to cpu affine named to _not_ run on CPU11, just to
> specialize it for TX completions and have softirq time percentage and
> "perf top -C 11 " results

----------------------------------------------------------------------------------------------------------------------
   PerfTop:     995 irqs/sec  kernel:97.7%  exact:  0.0% [1000Hz cpu-clock-msecs],  (all, CPU: 11)
----------------------------------------------------------------------------------------------------------------------

             samples  pcnt function                    DSO
             _______ _____ ___________________________ ___________________________________________________________

              335.00 23.3% intel_idle                  /lib/modules/2.6.38-rc5+/build/vmlinux                     
              253.00 17.6% be_tx_compl_process         /lib/modules/2.6.38-rc5+/kernel/drivers/net/benet/be2net.ko
              177.00 12.3% skb_release_data            /lib/modules/2.6.38-rc5+/build/vmlinux                     
              132.00  9.2% kfree                       /lib/modules/2.6.38-rc5+/build/vmlinux                     
              127.00  8.8% kfree_skb                   /lib/modules/2.6.38-rc5+/build/vmlinux                     
              105.00  7.3% be_poll_tx_mcc              /lib/modules/2.6.38-rc5+/kernel/drivers/net/benet/be2net.ko
               99.00  6.9% kmem_cache_free             /lib/modules/2.6.38-rc5+/build/vmlinux                     
               36.00  2.5% __do_softirq                /lib/modules/2.6.38-rc5+/build/vmlinux                     
               20.00  1.4% _raw_spin_unlock_irqrestore /lib/modules/2.6.38-rc5+/build/vmlinux                     
               19.00  1.3% skb_release_head_state      /lib/modules/2.6.38-rc5+/build/vmlinux                     
               13.00  0.9% unmap_tx_frag               /lib/modules/2.6.38-rc5+/kernel/drivers/net/benet/be2net.ko
               11.00  0.8% rb_next                     /usr/bin/perf                                              
               10.00  0.7% dso__find_symbol            /usr/bin/perf                                              
                9.00  0.6% is_swiotlb_buffer           /lib/modules/2.6.38-rc5+/build/vmlinux                     
                9.00  0.6% __strcmp_sse42              /lib64/libc-2.12.so                                        
                8.00  0.6% __kfree_skb                 /lib/modules/2.6.38-rc5+/build/vmlinux                     
                8.00  0.6% __strstr_sse42              /lib64/libc-2.12.so                                        
                6.00  0.4% _int_malloc                 /lib64/libc-2.12.so      
