From: chas williams <chas@cmf.nrl.navy.mil>
Subject: [RFC] suggest changes cleanup to atm svc/pvc family
Date: Tue, 10 Jun 2003 11:55:37 -0400
Sender: netdev-bounce@oss.sgi.com
Message-ID: <200306101555.h5AFtbQ00899@relax.cmf.nrl.navy.mil>
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

i was hoping some people might take a look at the following changes
and let me know what they think.

ftp://galileo.cmf.nrl.navy.mil/pub/chas/linux-atm/2_5_70_vcc_sklist_diffs

a quick summary (since the diff is rather lengthy):

- vcc are now in a global list protected by a rw lock (much like other
  protocol families).  this means the atm devices dont hold a list of
  vcc's.  this make some things much easier to write.
- a few things where renamed to vcc_XXX from atm_XXX.  eventually routines
  deal with vcc's will be vcc_, svc_, or pvc_.  atm devices functions
  should be called atm_dev_XXX.  this makes things a bit easier to read.
- vcc are now reference counted properly (or so i think)  (this doenst
  mean all the atm drivers understand this yet. the he driver should do
  the right thing though, holding a read on vcc sklist lock during recv
  operations to keep vcc's from prematurely disappearing.
- SOCKOPS_WRAP was removed and lock_sock's introduced in the appropriate 
  locations.  i might have a missed some.
- atm_ioctl was split into vcc_ioctl and atm_dev_ioctl
- recvmsg was rewritten to take advantage of some the existing kernel 
  routines that make datagram manipulation so much easier.
- sendmsg needs rewritten but the ip components will need to skb_clone
  so they can skb_set_owner_w on skb's that might already be owned by
  another socket.  right?
- changed add_wait_queue to prepare_to_wait and finish_wait.  is this
  the accepted interface?
