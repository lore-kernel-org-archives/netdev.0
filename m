From: chas williams <chas@cmf.nrl.navy.mil>
Subject: [RFC] assorted changes to atm protocol stack
Date: Tue, 10 Jun 2003 13:23:30 -0400
Sender: netdev-bounce@oss.sgi.com
Message-ID: <200306101723.h5AHNT9x017552@locutus.cmf.nrl.navy.mil>
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

i would appreciate it some people could review the following proposed
changes for the atm protocol families:

ftp://ftp.cmf.nrl.navy.mil/pub/chas/linux-atm/2_5_70_vcc_sklist_diffs

- vcc's are keep in a global list (vcc_sklist) much like the
  other protocol stacks.  
- rename's various functions to vcc_XXX instead of calling everything 
  atm_XXX.  hopefully this will make things clearer at some point.
- the he driver tries to do locking proper locking during the
  recv operation by holding a read_lock on the vcc sklist. 
  other drivers will need to do this as well.  (or otherwise
  hold reference counts)
- got rid of SOCKOPS_WRAPPED and would like someone to
  tell me if i have enough lock_sock()'s in place.
- rewrote recvmsg to use the existing skb network functions
- rewriting sendmsg will need to wait since i believe skb from the
  network stack will need to be cloned so that they can be properly
  skb_set_ownwer_w()
- split atm_ioctl into vcc_ioctl and atm_dev_ioctl.
- changed to prepare_to_wait() and finish_wait() in svc.c.  i assume
  that this is more correct, than directly using add_wait_queue
  and remove_wait_queue?

other comments are welcome of course.
