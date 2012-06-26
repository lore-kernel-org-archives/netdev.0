From: Jason Wang <jasowang@redhat.com>
Subject: [rfc] virtio-spec: introduce VIRTIO_NET_F_MULTIQUEUE
Date: Tue, 26 Jun 2012 15:15:39 +0800
Message-ID: <1340694939-14724-1-git-send-email-jasowang@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, virtualization@lists.linux-foundation.org
To: jasowang@redhat.com, mst@redhat.com, rusty@rustcorp.com.au
Return-path: <virtualization-bounces@lists.linux-foundation.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/virtualization>,
	<mailto:virtualization-request@lists.linux-foundation.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/virtualization/>
List-Post: <mailto:virtualization@lists.linux-foundation.org>
List-Help: <mailto:virtualization-request@lists.linux-foundation.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/virtualization>,
	<mailto:virtualization-request@lists.linux-foundation.org?subject=subscribe>
Sender: virtualization-bounces@lists.linux-foundation.org
Errors-To: virtualization-bounces@lists.linux-foundation.org
List-Id: netdev.vger.kernel.org

This patch introduces the multiqueue capabilities to virtio net devices. The
number of tx/rx queue pairs available in the device were exposed through config
space, and driver could negotiate the number of pairs it wish to use through
ctrl vq.

Signed-off-by: Jason Wang <jasowang@redhat.com>
---
 virtio-0.9.5.lyx |  180 ++++++++++++++++++++++++++++++++++++++++++++++++++++--
 1 file changed, 176 insertions(+), 4 deletions(-)

diff --git a/virtio-0.9.5.lyx b/virtio-0.9.5.lyx
index 3c80ecf..480e9c7 100644
--- a/virtio-0.9.5.lyx
+++ b/virtio-0.9.5.lyx
@@ -56,6 +56,7 @@
 \html_math_output 0
 \html_css_as_file 0
 \html_be_strict false
+\author 2090695081 "Jason Wang" 
 \end_header
 
 \begin_body
@@ -3854,11 +3855,22 @@ ID 1
 \end_layout
 
 \begin_layout Description
-Virtqueues 0:receiveq.
+Virtqueues 
+\change_inserted 2090695081 1340693104
+
+\end_layout
+
+\begin_deeper
+\begin_layout Description
+
+\change_inserted 2090695081 1340693118
+When VIRTIO_NET_F_MULTIQUEUE is not set: 
+\change_unchanged
+0:receiveq.
  1:transmitq.
  2:controlq
 \begin_inset Foot
-status open
+status collapsed
 
 \begin_layout Plain Layout
 Only if VIRTIO_NET_F_CTRL_VQ set
@@ -3867,9 +3879,60 @@ Only if VIRTIO_NET_F_CTRL_VQ set
 \end_inset
 
 
+\change_inserted 2090695081 1340693122
+
 \end_layout
 
 \begin_layout Description
+
+\change_inserted 2090695081 1340693866
+When VIRTIO_NET_F_MULTIQUEUE is set and there's N tx/rx queue pairs: 0:receiveq1.
+ 1:transmitq1.
+ 2:controlq
+\begin_inset Foot
+status collapsed
+
+\begin_layout Plain Layout
+
+\change_inserted 2090695081 1340693141
+Only if VIRTIO_NET_F_CTRL_VQ set
+\end_layout
+
+\end_inset
+
+ ...
+ 2N-1
+\begin_inset Foot
+status collapsed
+
+\begin_layout Plain Layout
+
+\change_inserted 2090695081 1340693284
+2N-2 If VIRTIO_NET_F_CTRL_VQ not set
+\end_layout
+
+\end_inset
+
+:receiveqN.
+ 2N
+\begin_inset Foot
+status collapsed
+
+\begin_layout Plain Layout
+
+\change_inserted 2090695081 1340693302
+2N-1 If VIRTIO_NET_F_CTRL_VQ is not set
+\end_layout
+
+\end_inset
+
+: transmitqN
+\change_unchanged
+
+\end_layout
+
+\end_deeper
+\begin_layout Description
 Feature
 \begin_inset space ~
 \end_inset
@@ -4027,6 +4090,16 @@ VIRTIO_NET_F_CTRL_VLAN
 
 \begin_layout Description
 VIRTIO_NET_F_GUEST_ANNOUNCE(21) Guest can send gratuitous packets.
+\change_inserted 2090695081 1340692965
+
+\end_layout
+
+\begin_layout Description
+
+\change_inserted 2090695081 1340693017
+VIRTIO_NET_F_MULTIQUEUE (22) Device has multiple tx/rx queues.
+\change_unchanged
+
 \end_layout
 
 \end_deeper
@@ -4039,11 +4112,22 @@ configuration
 \begin_inset space ~
 \end_inset
 
-layout Two configuration fields are currently defined.
+layout T
+\change_inserted 2090695081 1340693345
+hree
+\change_deleted 2090695081 1340693344
+wo
+\change_unchanged
+ configuration fields are currently defined.
  The mac address field always exists (though is only valid if VIRTIO_NET_F_MAC
  is set), and the status field only exists if VIRTIO_NET_F_STATUS is set.
  Two read-only bits are currently defined for the status field: VIRTIO_NET_S_LIN
 K_UP and VIRTIO_NET_S_ANNOUNCE.
+
+\change_inserted 2090695081 1340693398
+ The num queue pairs fields only exist if VIRTIO_NET_F_MULTIQUEUE is set.
+
+\change_unchanged
  
 \begin_inset listings
 inline false
@@ -4076,6 +4160,17 @@ struct virtio_net_config {
 \begin_layout Plain Layout
 
     u16 status;
+\change_inserted 2090695081 1340692955
+
+\end_layout
+
+\begin_layout Plain Layout
+
+\change_inserted 2090695081 1340692962
+
+	u16 num_queue_pairs;
+\change_unchanged
+
 \end_layout
 
 \begin_layout Plain Layout
@@ -4527,7 +4622,7 @@ O features are used, the Guest will need to accept packets of up to 65550
  So unless VIRTIO_NET_F_MRG_RXBUF is negotiated, every buffer in the receive
  queue needs to be at least this length 
 \begin_inset Foot
-status open
+status collapsed
 
 \begin_layout Plain Layout
 Obviously each one can be split across multiple descriptor elements.
@@ -4980,6 +5075,83 @@ Sending VIRTIO_NET_CTRL_ANNOUNCE_ACK command through control vq.
 \begin_layout Enumerate
 .
  
+\change_inserted 2090695081 1340693446
+
+\end_layout
+
+\begin_layout Subsection*
+
+\change_inserted 2090695081 1340693500
+Negotiating the number of queue pairs
+\end_layout
+
+\begin_layout Standard
+
+\change_inserted 2090695081 1340693733
+If the driver negotiates the VIRTIO_NET_F_MULTIQUEUE (depends on VIRTIO_NET_F_CT
+RL_VQ), it can then negotiate the number of queue pairs it wish to use by
+ placing the number in num_queue_pairs field of virtio_net_ctrl_multiqueue
+ through VIRTIO_NET_CTRL_MULTIQUEUE_NUM command.
+\end_layout
+
+\begin_layout Standard
+
+\change_inserted 2090695081 1340693782
+If the driver doesn't negotiate the number, all tx/rx queues were enabled
+ by default.
+\end_layout
+
+\begin_layout Standard
+
+\change_inserted 2090695081 1340693616
+\begin_inset listings
+inline false
+status open
+
+\begin_layout Plain Layout
+
+\change_inserted 2090695081 1340693620
+
+struct virtio_net_ctrl_multiqueue {
+\end_layout
+
+\begin_layout Plain Layout
+
+\change_inserted 2090695081 1340693627
+
+	u16 num_queue_pairs;
+\end_layout
+
+\begin_layout Plain Layout
+
+\change_inserted 2090695081 1340693616
+
+};
+\end_layout
+
+\begin_layout Plain Layout
+
+\change_inserted 2090695081 1340693616
+
+\end_layout
+
+\begin_layout Plain Layout
+
+\change_inserted 2090695081 1340693639
+
+#define VIRTIO_NET_CTRL_MULTIQUEUE    4
+\end_layout
+
+\begin_layout Plain Layout
+
+\change_inserted 2090695081 1340693646
+
+ #define VIRTIO_NET_CTRL_MULTIQUEUE_NUM        0 
+\end_layout
+
+\end_inset
+
+
 \end_layout
 
 \begin_layout Chapter*
-- 
1.7.9.5
