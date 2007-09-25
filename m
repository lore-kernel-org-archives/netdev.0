From: Randy Dunlap <randy.dunlap@oracle.com>
Subject: [ofa-general] Re: [DOC] Net batching driver howto
Date: Tue, 25 Sep 2007 13:16:20 -0700
Message-ID: <20070925131620.617794ae.randy.dunlap@oracle.com>
References: <20070914090058.17589.80352.sendpatchset@K50wks273871wss.in.ibm.com>
	<20070916.161748.48388692.davem@davemloft.net>
	<1189988958.4230.55.camel@localhost>
	<1190569987.4256.52.camel@localhost> <46F6AE18.7080708@garzik.org>
	<1190574713.5030.4.camel@localhost>
	<1190674459.4264.28.camel@localhost>
Mime-Version: 1.0
Content-Type: multipart/mixed;
	boundary="Multipart=_Tue__25_Sep_2007_13_16_20_-0700_Z/41.J6VoVRmOm6D"
Cc: johnpol@2ka.mipt.ru, peter.p.waskiewicz.jr@intel.com, kumarkr@linux.ibm.com,
	herbert@gondor.apana.org.au, Jeff Garzik <jeff@garzik.org>,
	Robert.Olsson@data.slu.se, netdev@vger.kernel.org,
	rdreier@cisco.com, mcarlson@broadcom.com,
	David Miller <davem@davemloft.net>, gaagaan@gmail.com,
	jagana@us.ibm.com, general@lists.openfabrics.org,
	mchan@broadcom.com, tgraf@suug.ch, sri@us.ibm.com,
	shemminger@linux-foundation.org, kaber@trash.net
To: hadi@cyberus.ca
Return-path: <general-bounces@lists.openfabrics.org>
In-Reply-To: <1190674459.4264.28.camel@localhost>
List-Unsubscribe: <http://lists.openfabrics.org/cgi-bin/mailman/listinfo/general>,
	<mailto:general-request@lists.openfabrics.org?subject=unsubscribe>
List-Archive: <http://lists.openfabrics.org/pipermail/general>
List-Post: <mailto:general@lists.openfabrics.org>
List-Help: <mailto:general-request@lists.openfabrics.org?subject=help>
List-Subscribe: <http://lists.openfabrics.org/cgi-bin/mailman/listinfo/general>,
	<mailto:general-request@lists.openfabrics.org?subject=subscribe>
Sender: general-bounces@lists.openfabrics.org
Errors-To: general-bounces@lists.openfabrics.org
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.

--Multipart=_Tue__25_Sep_2007_13_16_20_-0700_Z/41.J6VoVRmOm6D
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit

On Mon, 24 Sep 2007 18:54:19 -0400 jamal wrote:

> I have updated the driver howto to match the patches i posted yesterday.
> attached. 

Thanks for sending this.

This is an early draft, right?

I'll fix some typos etc. in it (patch attached) and add some whitespace.
Please see RD: in the patch for more questions/comments.

IMO it needs some changes to eliminate words like "we", "you",
and "your" (words that personify code).  Those words are OK
when talking about yourself.


---
~Randy
Phaedrus says that Quality is about caring.

--Multipart=_Tue__25_Sep_2007_13_16_20_-0700_Z/41.J6VoVRmOm6D
Content-Type: text/x-patch;
 name="batch-howto.patch"
Content-Disposition: attachment;
 filename="batch-howto.patch"
Content-Transfer-Encoding: 7bit


 batch-driver-howto.txt |  116 +++++++++++++++++++++------------------
 1 file changed, 63 insertions(+), 53 deletions(-)

diff -Naurp tmp/batch-driver-howto.txt~fix1 tmp/batch-driver-howto.txt
--- tmp/batch-driver-howto.txt~fix1	2007-09-25 12:44:10.000000000 -0700
+++ tmp/batch-driver-howto.txt	2007-09-25 13:14:27.000000000 -0700
@@ -1,13 +1,13 @@
-Heres the begining of a howto for driver authors.
+Here's the beginning of a howto for driver authors.
 
 The intended audience for this howto is people already
 familiar with netdevices.
 
-1.0  Netdevice Pre-requisites
+1.0  Netdevice Prerequisites
 ------------------------------
 
-For hardware based netdevices, you must have at least hardware that 
-is capable of doing DMA with many descriptors; i.e having hardware 
+For hardware-based netdevices, you must have at least hardware that 
+is capable of doing DMA with many descriptors; i.e., having hardware 
 with a queue length of 3 (as in some fscked ethernet hardware) is 
 not very useful in this case.
 
@@ -15,33 +15,36 @@ not very useful in this case.
 -----------------------------------
 
 There are 3 new methods and one new variable introduced. These are:
-1)dev->hard_prep_xmit()
-2)dev->hard_end_xmit()
-3)dev->hard_batch_xmit()
-4)dev->xmit_win
+1) dev->hard_prep_xmit()
+2) dev->hard_end_xmit()
+3) dev->hard_batch_xmit()
+4) dev->xmit_win
 
 2.1 Using Core driver changes
 -----------------------------
 
-To provide context, lets look at a typical driver abstraction
+To provide context, let's look at a typical driver abstraction
 for dev->hard_start_xmit(). It has 4 parts:
-a) packet formating (example vlan, mss, descriptor counting etc)
-b) chip specific formatting
+a) packet formatting (example: vlan, mss, descriptor counting, etc.)
+b) chip-specific formatting
 c) enqueueing the packet on a DMA ring
 d) IO operations to complete packet transmit, tell DMA engine to chew 
-on, tx completion interupts etc
+on, tx completion interrupts, etc.
 
 [For code cleanliness/readability sake, regardless of this work,
 one should break the dev->hard_start_xmit() into those 4 functions
 anyways].
+
 A driver which has all 4 parts and needing to support batching is 
 advised to split its dev->hard_start_xmit() in the following manner:
-1)use its dev->hard_prep_xmit() method to achieve #a
-2)use its dev->hard_end_xmit() method to achieve #d
-3)#b and #c can stay in ->hard_start_xmit() (or whichever way you 
+
+1) use its dev->hard_prep_xmit() method to achieve #a
+2) use its dev->hard_end_xmit() method to achieve #d
+3) #b and #c can stay in ->hard_start_xmit() (or whichever way you 
 want to do this)
+
 Note: There are drivers which may need not support any of the two
-methods (example the tun driver i patched) so the two methods are
+methods (for example, the tun driver I patched), so the two methods are
 essentially optional.
 
 2.1.1 Theory of operation
@@ -49,7 +52,7 @@ essentially optional.
 
 The core will first do the packet formatting by invoking your 
 supplied dev->hard_prep_xmit() method. It will then pass you the packet 
-via your dev->hard_start_xmit() method for as many as packets you
+via your dev->hard_start_xmit() method for as many packets as you
 have advertised (via dev->xmit_win) you can consume. Lastly it will 
 invoke your dev->hard_end_xmit() when it completes passing you all the 
 packets queued for you. 
@@ -58,16 +61,16 @@ packets queued for you. 
 2.1.1.1 Locking rules
 ---------------------
 
-dev->hard_prep_xmit() is invoked without holding any
-tx lock but the rest are under TX_LOCK(). So you have to ensure that
-whatever you put it dev->hard_prep_xmit() doesnt require locking.
+dev->hard_prep_xmit() is invoked without holding any tx lock
+but the rest are under TX_LOCK(). So you have to ensure that
+whatever you put it dev->hard_prep_xmit() doesn't require locking.
 
 2.1.1.2 The slippery LLTX
 -------------------------
 
 LLTX drivers present a challenge in that we have to introduce a deviation
 from the norm and require the ->hard_batch_xmit() method. An LLTX
-driver presents us with ->hard_batch_xmit() to which we pass it a list
+driver presents us with ->hard_batch_xmit() to which we pass in a list
 of packets in a dev->blist skb queue. It is then the responsibility
 of the ->hard_batch_xmit() to exercise steps #b and #c for all packets
 passed in the dev->blist.
@@ -80,11 +83,14 @@ dev->hard_prep_xmit() and dev->hard_end_
 dev->xmit_win variable is set by the driver to tell us how
 much space it has in its rings/queues. dev->xmit_win is introduced to 
 ensure that when we pass the driver a list of packets it will swallow 
-all of them - which is useful because we dont requeue to the qdisc (and 
-avoids burning unnecessary cpu cycles or introducing any strange 
+all of them -- which is useful because we don't requeue to the qdisc (and 
+avoids burning unnecessary CPU cycles or introducing any strange 
 re-ordering). The driver tells us, whenever it invokes netif_wake_queue,
 how much space it has for descriptors by setting this variable.
 
+RD:  so xmit_win is not total queue size, it's the available queue size
+when calling netif_wake_queue(), right?  I guess that's explained below.
+
 3.0 Driver Essentials
 ---------------------
 
@@ -104,18 +110,18 @@ The typical driver tx state machine is:
 -1-> +Cycle repeats and core sends more packets (step 1).
 ----
 
-3.1  Driver pre-requisite
+3.1  Driver prerequisite
 --------------------------
 
 This is _a very important_ requirement in making batching useful.
-The pre-requisite for batching changes is that the driver should 
+The prerequisite for batching changes is that the driver should 
 provide a low threshold to open up the tx path.
 Drivers such as tg3 and e1000 already do this.
 Before you invoke netif_wake_queue(dev) you check if there is a
 threshold of space reached to insert new packets.
 
-Heres an example of how i added it to tun driver. Observe the
-setting of dev->xmit_win
+Here's an example of how I added it to tun driver. Observe the
+setting of dev->xmit_win.
 
 ---
 +#define NETDEV_LTT 4 /* the low threshold to open up the tx path */
@@ -153,14 +159,14 @@ in tg3 code (with no batching changes) l
 -----------------
 
 a) On initialization (before netdev registration)
- i) set NETIF_F_BTX in dev->features 
-  i.e dev->features |= NETIF_F_BTX
+ 1) set NETIF_F_BTX in dev->features 
+  i.e., dev->features |= NETIF_F_BTX
   This makes the core do proper initialization.
 
-ii) set dev->xmit_win to something reasonable like
+ 2) set dev->xmit_win to something reasonable like
   maybe half the tx DMA ring size etc.
 
-b) create proper pointer to the new methods desribed above if
+b) create proper pointer to the new methods described above if
 you need them.
 
 3.3 Annotation on the different methods 
@@ -171,27 +177,30 @@ methods and variable could be used.
 3.3.1 The dev->hard_prep_xmit() method
 ---------------------------------------
 
-Use this method to only do pre-processing of the skb passed.
-If in the current dev->hard_start_xmit() you are pre-processing
-packets before holding any locks (eg formating them to be put in
-any descriptor etc).
+Use this method only to do preprocessing of the skb passed.
+If in the current dev->hard_start_xmit() you are preprocessing
+packets before holding any locks (e.g., formatting them to be put in
+any descriptor etc.).
+RD: incomplete sentence above.
 Look at e1000_prep_queue_frame() for an example.
 You may use the skb->cb to store any state that you need to know
-of later when batching.
-PS: I have found when discussing with Michael Chan and Matt Carlson
-that skb->cb[0] (8bytes of it) is used by the VLAN code to pass VLAN 
+later when batching.
+
+NOTE: I have found when discussing with Michael Chan and Matt Carlson
+that skb->cb[0] (8 bytes of it) is used by the VLAN code to pass VLAN 
 info to the driver.
 I think this is a violation of the usage of the cb scratch pad. 
 To work around this, you could use skb->cb[8] or do what the broadcom
-tg3 bacthing driver does which is to glean the vlan info first then
-re-use the skb->cb.
+tg3 batching driver does which is to glean the vlan info first then
+reuse the skb->cb.
 
 3.3.2 dev->hard_start_xmit()
 ----------------------------
   
-Heres an example of tx routine that is similar to the one i added 
+Here's an example of tx routine that is similar to the one I added 
 to the current tun driver. bxmit suffix is kept so that you can turn
 off batching if needed via and call already existing interface.
+RD: off batching via ethtool if needed ??
 
 ----
   static int xxx_net_bxmit(struct net_device *dev)
@@ -211,14 +220,14 @@ off batching if needed via and call alre
   }
 ------
 
-All return codes like NETDEV_TX_OK etc still apply.
+All return codes like NETDEV_TX_OK etc. still apply.
 
 3.3.3 The LLTX batching method, dev->batch_xmit()
 -------------------------------------------------
   
-Heres an example of a batch tx routine that is similar
-to the one i added to the older tun driver. Essentially
-this is what youd do if you wanted to support LLTX.
+Here's an example of a batch tx routine that is similar
+to the one I added to the older tun driver. Essentially
+this is what you would do if you wanted to support LLTX.
 
 ----
   static int xxx_net_bxmit(struct net_device *dev)
@@ -228,7 +237,7 @@ this is what youd do if you wanted to su
         while (skb_queue_len(dev->blist)) {
 	        dequeue from dev->blist
 		enqueue onto hardware ring
-		if hardware ring full break
+		if hardware ring full, break
         }
 				           
 	if (hardware ring full) {
@@ -242,34 +251,35 @@ this is what youd do if you wanted to su
   }
 ------
 
-All return codes like NETDEV_TX_OK etc still apply.
+All return codes like NETDEV_TX_OK etc. still apply.
 
 3.3.4 The tx complete, dev->hard_end_xmit()
 -------------------------------------------------
   
 In this method, if there are any IO operations that apply to a 
-set of packets such as kicking DMA, setting of interupt thresholds etc,
+set of packets such as kicking DMA, setting of interrupt thresholds etc.,
 leave them to the end and apply them once if you have successfully enqueued. 
-This provides a mechanism for saving a lot of cpu cycles since IO
+This provides a mechanism for saving a lot of CPU cycles since IO
 is cycle expensive.
-For an example of this look e1000 driver e1000_kick_DMA() function.
+For an example of this look at the e1000 driver e1000_kick_DMA() function.
 
 3.3.5 setting the dev->xmit_win 
 -----------------------------
 
 As mentioned earlier this variable provides hints on how much
 data to send from the core to the driver. Here are the obvious ways:
-a)on doing a netif_stop, set it to 1. By default all drivers have 
+
+a) on doing a netif_stop, set it to 1. By default all drivers have 
 this value set to 1 to emulate old behavior where a driver only
 receives one packet at a time.
-b)on netif_wake_queue set it to the max available space. You have
+b) on netif_wake_queue set it to the max available space. You have
 to be careful if your hardware does scatter-gather since the core
 will pass you scatter-gatherable skbs and so you want to at least
 leave enough space for the maximum allowed. Look at the tg3 and
 e1000 to see how this is implemented.
 
 The variable is important because it avoids the core sending
-any more than what the driver can handle therefore avoiding 
+any more than what the driver can handle, therefore avoiding 
 any need to muck with packet scheduling mechanisms.
 
 Appendix 1: History

--Multipart=_Tue__25_Sep_2007_13_16_20_-0700_Z/41.J6VoVRmOm6D
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline


--Multipart=_Tue__25_Sep_2007_13_16_20_-0700_Z/41.J6VoVRmOm6D--
