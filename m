From: Robert Olsson <Robert.Olsson@data.slu.se>
Subject: [PATCH] tg3 locking update (with NAPI overtones)
Date: Thu, 28 Nov 2002 11:12:52 +0100
Sender: netdev-bounce@oss.sgi.com
Message-ID: <15845.60452.201159.295984@robur.slu.se>
References: <3DE406AE.2000908@pobox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com, "David S. Miller" <davem@redhat.com>,
   Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>
Return-path: <netdev-bounce@oss.sgi.com>
To: Jeff Garzik <jgarzik@pobox.com>
In-Reply-To: <3DE406AE.2000908@pobox.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org



Jeff Garzik writes:

 > * When net drivers move TX completion from interrupt to dev->poll(), 
 > this allows the rethinking of some traditional locking, namely 
 > eliminating a lock in dev->start_xmit() that most drivers implement 
 > these days.

 Yes. 

 > 
 > tg3_tx_timeout: net stack already holds dev->xmit_lock.  tx_lock GC'd.
 
 For tx_timout and other timer/async work there may exist a scheduled poll 
 to which we have to sync. Something like this could be done. Ideas comes
 from dev->close.

 /*
  *  Synchronize and disable poll
  */

  while (test_and_set_bit(__LINK_STATE_RX_SCHED, &dev->state)) {

      	  current->state = TASK_INTERRUPTIBLE;
	  schedule_timeout(1);
  }

  .
  .

 /* Enable */
  clear_bit(__LINK_STATE_RX_SCHED, &dev->state);


 Cheers.
						--ro
