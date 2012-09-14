From: Antonio Quartulli <ordex-GaUfNO9RBHfsrOwW+9ziJQ@public.gmane.org>
Subject: [PATCH net] batman-adv: make batadv_test_bit()
	return 0 or 1 only
Date: Fri, 14 Sep 2012 12:40:54 +0200
Message-ID: <1347619254-22862-1-git-send-email-ordex@autistici.org>
Reply-To: The list for a Better Approach To Mobile Ad-hoc Networking
 <b.a.t.m.a.n-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, b.a.t.m.a.n-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org
To: davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org
Return-path: <b.a.t.m.a.n-bounces-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org>
List-Unsubscribe: <https://lists.open-mesh.org/mm/options/b.a.t.m.a.n>,
 <mailto:b.a.t.m.a.n-request-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.open-mesh.org/pipermail/b.a.t.m.a.n/>
List-Post: <mailto:b.a.t.m.a.n-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org>
List-Help: <mailto:b.a.t.m.a.n-request-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org?subject=help>
List-Subscribe: <https://lists.open-mesh.org/mm/listinfo/b.a.t.m.a.n>,
 <mailto:b.a.t.m.a.n-request-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org?subject=subscribe>
Errors-To: b.a.t.m.a.n-bounces-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org
Sender: "B.A.T.M.A.N" <b.a.t.m.a.n-bounces-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org>
List-Id: netdev.vger.kernel.org

From: Linus L=C3=BCssing <linus.luessing-S0/GAf8tV78@public.gmane.org>

On some architectures test_bit() can return other values than 0 or 1:

With a generic x86 OpenWrt image in a kvm setup (batadv_)test_bit()
frequently returns -1 for me, leading to batadv_iv_ogm_update_seqnos()
wrongly signaling a protected seqno window.

This patch tries to fix this issue by making batadv_test_bit() return 0
or 1 only.

Signed-off-by: Linus L=C3=BCssing <linus.luessing-S0/GAf8tV78@public.gmane.org>
Acked-by: Sven Eckelmann <sven-KaDOiPu9UxWEi8DpZVb4nw@public.gmane.org>
Signed-off-by: Antonio Quartulli <ordex-GaUfNO9RBHfsrOwW+9ziJQ@public.gmane.org>
---
 net/batman-adv/bitarray.h | 6 +++---
 1 file changed, 3 insertions(+), 3 deletions(-)

diff --git a/net/batman-adv/bitarray.h b/net/batman-adv/bitarray.h
index a081ce1..cebaae7 100644
--- a/net/batman-adv/bitarray.h
+++ b/net/batman-adv/bitarray.h
@@ -20,8 +20,8 @@
 #ifndef _NET_BATMAN_ADV_BITARRAY_H_
 #define _NET_BATMAN_ADV_BITARRAY_H_
=20
-/* returns true if the corresponding bit in the given seq_bits indicates=
 true
- * and curr_seqno is within range of last_seqno
+/* Returns 1 if the corresponding bit in the given seq_bits indicates tr=
ue
+ * and curr_seqno is within range of last_seqno. Otherwise returns 0.
  */
 static inline int batadv_test_bit(const unsigned long *seq_bits,
 				  uint32_t last_seqno, uint32_t curr_seqno)
@@ -32,7 +32,7 @@ static inline int batadv_test_bit(const unsigned long *=
seq_bits,
 	if (diff < 0 || diff >=3D BATADV_TQ_LOCAL_WINDOW_SIZE)
 		return 0;
 	else
-		return  test_bit(diff, seq_bits);
+		return test_bit(diff, seq_bits) !=3D 0;
 }
=20
 /* turn corresponding bit on, so we can remember that we got the packet =
*/
--=20
1.7.12
