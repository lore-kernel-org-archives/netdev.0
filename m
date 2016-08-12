From: Simon Wunderlich <sw-2YrNx6rUIHYiY0qSoAWiAoQuADTiUCJX@public.gmane.org>
Subject: [PATCH 04/19] batman-adv: Use rtnl link in device
	creation example
Date: Fri, 12 Aug 2016 10:56:40 +0200
Message-ID: <1470992215-11009-5-git-send-email-sw@simonwunderlich.de>
References: <1470992215-11009-1-git-send-email-sw@simonwunderlich.de>
Reply-To: The list for a Better Approach To Mobile Ad-hoc Networking
 <b.a.t.m.a.n-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org>
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, b.a.t.m.a.n-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org,
 Marek Lindner <mareklindner-rVWd3aGhH2z5bpWLKbzFeg@public.gmane.org>
To: davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org
Return-path: <b.a.t.m.a.n-bounces-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org>
In-Reply-To: <1470992215-11009-1-git-send-email-sw-2YrNx6rUIHYiY0qSoAWiAoQuADTiUCJX@public.gmane.org>
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

From: Sven Eckelmann <sven-KaDOiPu9UxWEi8DpZVb4nw@public.gmane.org>

The standard kernel API to add new virtual interfaces and attach other
interfaces to it is rtnl-link. batman-adv supports it since v3.10. This
functionality should be used instead of the legacy batman-adv-only sysfs
interface.

Signed-off-by: Sven Eckelmann <sven-KaDOiPu9UxWEi8DpZVb4nw@public.gmane.org>
Signed-off-by: Marek Lindner <mareklindner-rVWd3aGhH2z5bpWLKbzFeg@public.gmane.org>
Signed-off-by: Simon Wunderlich <sw-2YrNx6rUIHYiY0qSoAWiAoQuADTiUCJX@public.gmane.org>
---
 Documentation/networking/batman-adv.txt | 17 +++++++++++------
 1 file changed, 11 insertions(+), 6 deletions(-)

diff --git a/Documentation/networking/batman-adv.txt b/Documentation/networking/batman-adv.txt
index 1b5e7a7..8a8d3d9 100644
--- a/Documentation/networking/batman-adv.txt
+++ b/Documentation/networking/batman-adv.txt
@@ -43,10 +43,15 @@ new interfaces to verify the compatibility. There is no  need  to
 reload the module if you plug your USB wifi adapter into your ma-
 chine after batman advanced was initially loaded.
 
-To activate a  given  interface  simply  write  "bat0"  into  its
-"mesh_iface" file inside the batman_adv subfolder:
+The batman-adv soft-interface can be created using  the  iproute2
+tool "ip"
 
-# echo bat0 > /sys/class/net/eth0/batman_adv/mesh_iface
+# ip link add name bat0 type batadv
+
+To  activate a  given  interface  simply  attach it to the "bat0"
+interface
+
+# ip link set dev eth0 master bat0
 
 Repeat  this step for all interfaces you wish to add.  Now batman
 starts using/broadcasting on this/these interface(s).
@@ -56,10 +61,10 @@ By reading the "iface_status" file you can check its status:
 # cat /sys/class/net/eth0/batman_adv/iface_status
 # active
 
-To deactivate an interface you have  to  write  "none"  into  its
-"mesh_iface" file:
+To  deactivate  an  interface  you  have   to  detach it from the
+"bat0" interface:
 
-# echo none > /sys/class/net/eth0/batman_adv/mesh_iface
+# ip link set dev eth0 nomaster
 
 
 All  mesh  wide  settings  can be found in batman's own interface
-- 
2.8.1
