From: Ralph Doncaster <ralph@istop.com>
Subject: route-cache performance
Date: Mon, 25 Aug 2003 23:41:11 -0400 (EDT)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <Pine.LNX.4.51.0308252328140.26713@ns.istop.com>
Reply-To: ralph+d@istop.com
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

So far things look really good with 2.4.22-rc2 with a 1G Celery and e1000.
This is just send-only with full (123K) routes and then a small routing
table.  Tomorrow I'll test forwarding (in one e1000, out the other).

Here's with a full table:
    34 e1000_irq_enable                           0.7083
    67 kmalloc                                    0.8375
   147 memcpy_fromiovecend                        0.9187
   115 kfree_skbmem                               1.0268
   103 pfifo_fast_dequeue                         1.2875
   511 raw_getrawfrag                             2.2812
   272 __generic_copy_from_user                   2.4286
   322 handle_IRQ_event                           2.8750
   203 kfree                                      3.1719
   198 system_call                                3.5357

And with < 10 routes:
    29 kmalloc                                    0.3625
    45 kfree_skbmem                               0.4018
    66 memcpy_fromiovecend                        0.4125
    23 e1000_irq_enable                           0.4792
    53 pfifo_fast_dequeue                         0.6625
   256 raw_getrawfrag                             1.1429
   149 __generic_copy_from_user                   1.3304
   170 handle_IRQ_event                           1.5179
   113 kfree                                      1.7656
   115 system_call                                2.0536

Juno was able to send ~330kpps, which is pretty decent.  From the profiles
it looks like every packet sent by juno leads to a kmalloc/kfree.  If
that interpretation is correct then a fixed skb pool should lead to a
significant performance improvement.

Ralph Doncaster, IStop.com president
6042147 Canada Inc.
