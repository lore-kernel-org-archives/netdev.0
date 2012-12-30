From: Pau Koning <paukoning-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: batman-adv: Unable to add interface in LXC
Date: Sun, 30 Dec 2012 20:34:38 +0100
Message-ID: <CANiGF9-dq-HrvWrgu9EMC94rP=1YdrmaFbCF2g1SZ9ocu77ysw@mail.gmail.com>
Reply-To: The list for a Better Approach To Mobile Ad-hoc Networking
 <b.a.t.m.a.n-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: b.a.t.m.a.n-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org
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

I am running LXC (SID) under Debian SID and the current git version of
batman-adv (v3.7-rc7-1325-gaf5d4f7) +batctl (v2012.4.0-30-ga395164).
But it fails to add any of my interfaces and non-batman-adv interfaces
can be created without problems

# ip link
13: eth0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc pfifo_fast
state UP mode DEFAULT qlen 1000
    link/ether 00:ff:aa:00:00:01 brd ff:ff:ff:ff:ff:ff
15: lo: <LOOPBACK,UP,LOWER_UP> mtu 16436 qdisc noqueue state UNKNOWN
mode DEFAULT
    link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00
# batctl if add eth0
Error - can't open file '/sys/class/net/eth0/batman_adv/mesh_iface':
Read-only file system
# ls -l /sys/class/net/eth0/batman_adv/mesh_iface
-rw-r--r-- 1 root root 4096 Dec 30 18:26
/sys/class/net/eth0/batman_adv/mesh_iface
# id
uid=0(root) gid=0(root) groups=0(root)
# ip link add dev br0 type bridge
# ip link set dev eth0 master br0
# ip link
18: eth0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc pfifo_fast
master br0 state UP mode DEFAULT qlen 1000
    link/ether 00:ff:aa:00:00:01 brd ff:ff:ff:ff:ff:ff
20: lo: <LOOPBACK,UP,LOWER_UP> mtu 16436 qdisc noqueue state UNKNOWN
mode DEFAULT
    link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00
21: br0: <BROADCAST,MULTICAST> mtu 1500 qdisc noop state DOWN mode DEFAULT
    link/ether 00:ff:aa:00:00:01 brd ff:ff:ff:ff:ff:ff
