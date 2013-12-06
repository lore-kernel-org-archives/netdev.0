From: Joe Perches <joe-6d6DIl74uiNBDgjK7y7TUQ@public.gmane.org>
Subject: [PATCH -next] etherdevice: Add
	ether_addr_equal_unaligned
Date: Fri, 06 Dec 2013 14:21:01 -0800
Message-ID: <1386368461.31845.38.camel@joe-AO722>
References: <1386317890.31845.26.camel@joe-AO722>
 <20131206.153944.1382127535160341376.davem@davemloft.net>
 <1386364621.31845.32.camel@joe-AO722>
 <20131206.163806.1555069105347405484.davem@davemloft.net>
Reply-To: The list for a Better Approach To Mobile Ad-hoc Networking
 <b.a.t.m.a.n-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: mareklindner-rVWd3aGhH2z5bpWLKbzFeg@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
 b.a.t.m.a.n-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
 antonio-x4xJYDvStAgysxA8WJXlww@public.gmane.org
To: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Return-path: <b.a.t.m.a.n-bounces-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org>
In-Reply-To: <20131206.163806.1555069105347405484.davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
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

Add a generic routine to test if possibly unaligned
to u16 Ethernet addresses are equal.

If CONFIG_HAVE_EFFICIENT_UNALIGNED_ACCESS is set,
this uses the slightly faster generic routine
ether_addr_equal, otherwise this uses memcmp.

Signed-off-by: Joe Perches <joe-6d6DIl74uiNBDgjK7y7TUQ@public.gmane.org>
---
 include/linux/etherdevice.h | 18 ++++++++++++++++++
 1 file changed, 18 insertions(+)

diff --git a/include/linux/etherdevice.h b/include/linux/etherdevice.h
index 3526e81..eb36845 100644
--- a/include/linux/etherdevice.h
+++ b/include/linux/etherdevice.h
@@ -266,6 +266,24 @@ static inline bool ether_addr_equal_64bits(const u8 addr1[6+2],
 }
 
 /**
+ * ether_addr_equal_unaligned - Compare two not u16 aligned Ethernet addresses
+ * @addr1: Pointer to a six-byte array containing the Ethernet address
+ * @addr2: Pointer other six-byte array containing the Ethernet address
+ *
+ * Compare two Ethernet addresses, returns true if equal
+ *
+ * Please note: Use only when any Ethernet address may not be u16 aligned.
+ */
+static inline bool ether_addr_equal_unaligned(const u8 *addr1, const u8 *addr2)
+{
+#if defined(CONFIG_HAVE_EFFICIENT_UNALIGNED_ACCESS)
+	return ether_addr_equal(addr1, addr2);
+#else
+	return memcmp(addr1, addr2, ETH_ALEN) == 0;
+#endif
+}
+
+/**
  * is_etherdev_addr - Tell if given Ethernet address belongs to the device.
  * @dev: Pointer to a device structure
  * @addr: Pointer to a six-byte array containing the Ethernet address
