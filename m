From: Jan Killius <jkillius@arcor.de>
Subject: sk98lin: page allocation error too
Date: Sat, 16 Oct 2004 20:13:44 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <200410162013.44305.jkillius@arcor.de>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Content-Disposition: inline
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hello,
I'm getting the page allocation error on my other machine too. This is a 
x86_64 machine on 2.6.9-rc3. Here is one of the call traces:
kswapd0: page allocation failure. order:0, mode:0x20

Call Trace:<IRQ> <ffffffff80151933>{__alloc_pages+1011} 
<ffffffff8012bede>{__wake_up_common+62}
       <ffffffff80151aaf>{__get_free_pages+31} 
<ffffffff80154fcb>{kmem_getpages+27}
       <ffffffff80151933>{__alloc_pages+1011} 
<ffffffff801556b2>{cache_alloc_refill+674}
       <ffffffff80155333>{__kmalloc+83} <ffffffff80249bd1>{alloc_skb+81}
       <ffffffffa066cd99>{:sk98lin:FillRxRing+73} 
<ffffffffa066f73f>{:sk98lin:SkGeIsrOnePort+79}
       <ffffffff80110f2c>{handle_IRQ_event+44} <ffffffff801111f4>{do_IRQ+212}
       <ffffffff8010ea2d>{ret_from_intr+0} 
<ffffffff80150130>{mempool_free_slab+0}
       <ffffffff802222f0>{__end_that_request_first+304} 
<ffffffff802222fb>{__end_that_request_first+315}
       <ffffffff80237b90>{sd_rw_intr+0} 
<ffffffff8022d43c>{scsi_end_request+60}
       <ffffffff80150041>{mempool_free+1} 
<ffffffff8022d7ed>{scsi_io_completion+541}
       <ffffffff80228e6e>{scsi_softirq+238} 
<ffffffff80134d33>{__do_softirq+83}
       <ffffffff80134dc5>{do_softirq+53} <ffffffff8011129f>{do_IRQ+383}
       <ffffffff8010ea2d>{ret_from_intr+0}  <EOI> 
<ffffffff8012d3e9>{autoremove_wake_function+9}
       <ffffffff8012bede>{__wake_up_common+62} 
<ffffffff80150130>{mempool_free_slab+0}
       <ffffffff802209b9>{get_request+457} <ffffffff802209ab>{get_request+443}
       <ffffffff80220777>{get_io_context+167} 
<ffffffff80220b74>{get_request_wait+164}
       <ffffffff8012d3e0>{autoremove_wake_function+0} 
<ffffffff8012d3e0>{autoremove_wake_function+0}
       <ffffffff80221a5b>{__make_request+875} 
<ffffffff80221de3>{generic_make_request+339}
       <ffffffff8012d3e0>{autoremove_wake_function+0} 
<ffffffff80221ef8>{submit_bio+248}
       <ffffffff80171c07>{bio_alloc+359} <ffffffff8016f8da>{submit_bh+282}
       <ffffffff801708fa>{__block_write_full_page+442} 
<ffffffff801acda0>{ext3_get_block+0}
       <ffffffff801ab415>{ext3_ordered_writepage+261} 
<ffffffff8015927a>{shrink_zone+1594}
       <ffffffff80159bf5>{balance_pgdat+597} <ffffffff8012d354>{finish_wait+4}
       <ffffffff80159de1>{kswapd+257} 
<ffffffff8012d3e0>{autoremove_wake_function+0}
       <ffffffff8012bad5>{finish_task_switch+85} 
<ffffffff8012d3e0>{autoremove_wake_function+0}
       <ffffffff8012bb3e>{schedule_tail+14} <ffffffff8010eeef>{child_rip+8}
       <ffffffff80159ce0>{kswapd+0} <ffffffff8010eee7>{child_rip+0}

-- 
        Jan
