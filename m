From: Shan Wei <shanwei88@gmail.com>
Subject: Re: [Patch V2 ] net: doc: cleanup Documentation/networking/scaling.txt
Date: Thu, 08 Dec 2011 10:03:55 +0800
Message-ID: <4EE01B0B.2050900@gmail.com>
References: <4EDF77A9.4040808@gmail.com> <20111207.134055.2237590951177376531.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: rdunlap@xenotime.net, willemb@google.com,
	benjamin.poirier@gmail.com, therbert@google.com,
	linux-doc@vger.kernel.org, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <linux-doc-owner@vger.kernel.org>
In-Reply-To: <20111207.134055.2237590951177376531.davem@davemloft.net>
Sender: linux-doc-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

David Miller said, at 2011/12/8 2:40:

> I don't know if it's the encoding you use or something else but you
> must fix this before submitting any more patches.
=20

Indeed, used default encoding of GB2312, now change it to UTF-8
according to email-clients.txt and resubmit this patch.


[PATCH v3] net: doc: cleanup Documentation/networking/scaling.txt

1) Fix some typos.
2) Change mode of the punctuation from full to half, eg.=E2=80=99,=E2=80=
=9C .
   So that the punctuation can be read at console.

Signed-off-by: Shan Wei <shanwei88@gmail.com>
---
 Documentation/networking/scaling.txt |   26 +++++++++++++-------------
 1 files changed, 13 insertions(+), 13 deletions(-)

diff --git a/Documentation/networking/scaling.txt b/Documentation/netwo=
rking/scaling.txt
index a177de2..1215fcc 100644
--- a/Documentation/networking/scaling.txt
+++ b/Documentation/networking/scaling.txt
@@ -26,7 +26,7 @@ queues to distribute processing among CPUs. The NIC d=
istributes packets by
 applying a filter to each packet that assigns it to one of a small num=
ber
 of logical flows. Packets for each flow are steered to a separate rece=
ive
 queue, which in turn can be processed by separate CPUs. This mechanism=
 is
-generally known as =E2=80=9CReceive-side Scaling=E2=80=9D (RSS). The g=
oal of RSS and
+generally known as "Receive-side Scaling" (RSS). The goal of RSS and
 the other scaling techniques is to increase performance uniformly.
 Multi-queue distribution can also be used for traffic prioritization, =
but
 that is not the focus of these techniques.
@@ -42,7 +42,7 @@ indirection table and reading the corresponding value=
=2E
=20
 Some advanced NICs allow steering packets to queues based on
 programmable filters. For example, webserver bound TCP port 80 packets
-can be directed to their own receive queue. Such =E2=80=9Cn-tuple=E2=80=
=9D filters can
+can be directed to their own receive queue. Such "n-tuple" filters can
 be configured from ethtool (--config-ntuple).
=20
 =3D=3D=3D=3D RSS Configuration
@@ -104,7 +104,7 @@ RSS. Being in software, it is necessarily called la=
ter in the datapath.
 Whereas RSS selects the queue and hence CPU that will run the hardware
 interrupt handler, RPS selects the CPU to perform protocol processing
 above the interrupt handler. This is accomplished by placing the packe=
t
-on the desired CPU=E2=80=99s backlog queue and waking up the CPU for p=
rocessing.
+on the desired CPU's backlog queue and waking up the CPU for processin=
g.
 RPS has some advantages over RSS: 1) it can be used with any NIC,
 2) software filters can easily be added to hash over new protocols,
 3) it does not increase hardware device interrupt rate (although it do=
es
@@ -116,20 +116,20 @@ netif_receive_skb(). These call the get_rps_cpu()=
 function, which
 selects the queue that should process a packet.
=20
 The first step in determining the target CPU for RPS is to calculate a
-flow hash over the packet=E2=80=99s addresses or ports (2-tuple or 4-t=
uple hash
+flow hash over the packet's addresses or ports (2-tuple or 4-tuple has=
h
 depending on the protocol). This serves as a consistent hash of the
 associated flow of the packet. The hash is either provided by hardware
 or will be computed in the stack. Capable hardware can pass the hash i=
n
 the receive descriptor for the packet; this would usually be the same
 hash used for RSS (e.g. computed Toeplitz hash). The hash is saved in
 skb->rx_hash and can be used elsewhere in the stack as a hash of the
-packet=E2=80=99s flow.
+packet's flow.
=20
 Each receive hardware queue has an associated list of CPUs to which
 RPS may enqueue packets for processing. For each received packet,
 an index into the list is computed from the flow hash modulo the size
 of the list. The indexed CPU is the target for processing the packet,
-and the packet is queued to the tail of that CPU=E2=80=99s backlog que=
ue. At
+and the packet is queued to the tail of that CPU's backlog queue. At
 the end of the bottom half routine, IPIs are sent to any CPUs for whic=
h
 packets have been queued to their backlog queue. The IPI wakes backlog
 processing on the remote CPU, and any queued packets are then processe=
d
@@ -208,7 +208,7 @@ The counter in rps_dev_flow_table values records th=
e length of the current
 CPU's backlog when a packet in this flow was last enqueued. Each backl=
og
 queue has a head counter that is incremented on dequeue. A tail counte=
r
 is computed as head counter + queue length. In other words, the counte=
r
-in rps_dev_flow_table[i] records the last element in flow i that has
+in rps_dev_flow[i] records the last element in flow i that has
 been enqueued onto the currently designated CPU for flow i (of course,
 entry i is actually selected by hash and multiple flows may hash to th=
e
 same entry i).
@@ -218,13 +218,13 @@ CPU for packet processing (from get_rps_cpu()) th=
e rps_sock_flow table
 and the rps_dev_flow table of the queue that the packet was received o=
n
 are compared. If the desired CPU for the flow (found in the
 rps_sock_flow table) matches the current CPU (found in the rps_dev_flo=
w
-table), the packet is enqueued onto that CPU=E2=80=99s backlog. If the=
y differ,
+table), the packet is enqueued onto that CPU's backlog. If they differ=
,
 the current CPU is updated to match the desired CPU if one of the
 following is true:
=20
 - The current CPU's queue head counter >=3D the recorded tail counter
   value in rps_dev_flow[i]
-- The current CPU is unset (equal to NR_CPUS)
+- The current CPU is unset (equal to RPS_NO_CPU)
 - The current CPU is offline
=20
 After this check, the packet is sent to the (possibly updated) current
@@ -235,7 +235,7 @@ CPU.
=20
 =3D=3D=3D=3D RFS Configuration
=20
-RFS is only available if the kconfig symbol CONFIG_RFS is enabled (on
+RFS is only available if the kconfig symbol CONFIG_RPS is enabled (on
 by default for SMP). The functionality remains disabled until explicit=
ly
 configured. The number of entries in the global flow table is set thro=
ugh:
=20
@@ -258,7 +258,7 @@ For a single queue device, the rps_flow_cnt value f=
or the single queue
 would normally be configured to the same value as rps_sock_flow_entrie=
s.
 For a multi-queue device, the rps_flow_cnt for each queue might be
 configured as rps_sock_flow_entries / N, where N is the number of
-queues. So for instance, if rps_flow_entries is set to 32768 and there
+queues. So for instance, if rps_sock_flow_entries is set to 32768 and =
there
 are 16 configured receive queues, rps_flow_cnt for each queue might be
 configured as 2048.
=20
@@ -272,7 +272,7 @@ the application thread consuming the packets of eac=
h flow is running.
 Accelerated RFS should perform better than RFS since packets are sent
 directly to a CPU local to the thread consuming the data. The target C=
PU
 will either be the same CPU where the application runs, or at least a =
CPU
-which is local to the application thread=E2=80=99s CPU in the cache hi=
erarchy.
+which is local to the application thread's CPU in the cache hierarchy.
=20
 To enable accelerated RFS, the networking stack calls the
 ndo_rx_flow_steer driver function to communicate the desired hardware
@@ -285,7 +285,7 @@ The hardware queue for a flow is derived from the C=
PU recorded in
 rps_dev_flow_table. The stack consults a CPU to hardware queue map whi=
ch
 is maintained by the NIC driver. This is an auto-generated reverse map=
 of
 the IRQ affinity table shown by /proc/interrupts. Drivers can use
-functions in the cpu_rmap (=E2=80=9CCPU affinity reverse map=E2=80=9D)=
 kernel library
+functions in the cpu_rmap ("CPU affinity reverse map") kernel library
 to populate the map. For each CPU, the corresponding queue in the map =
is
 set to be one whose processing CPU is closest in cache locality.
=20
--=20
1.7.1


=20
