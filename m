From: Ding Tianhong <dingtianhong@huawei.com>
Subject: [RFC] Is it a bug for nfs on udp6 mode or kernel?
Date: Wed, 13 Apr 2016 19:28:41 +0800
Message-ID: <570E2D69.7080102@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: <linux-nfs-approval@vger.kernel.org>, <tom@herbertland.com>,
	Netdev <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	<dhowells@redhat.com>, <viro@zeniv.linux.org.u>,
	<chuck.lever@oracle.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi everyone:

I have met this problem when I try to test udp6 for nfs connection, my =
environment is:

Server:
kernel: 4.1.15
IP:xxxx::36/64
MTU:1500
Setting: /etc/exports:/home/nfs *(rw,sync,no_subtree_check,no_root_squa=
sh)

Client:
kernel: 4.1.18
IP:xxxx::90/64
MTU:1500
command: mount -t nfs -o vers=3D3,proto=3Dudp6,rsize=3D4096,wsize=3D409=
6 [xxxx::36]:/home/nfs /home/tmp

I check the nfs parameter configuration, it looks fine and could work w=
ell for proto=3Dtcp6.

Then I have mount correctly and try to run the command "ls", it hang.

When I use the rsize=3D1024 and wsize=3D1024 to mount, the problem disa=
ppeared, so I guess it is the problem for GSO or GRO for UDP=E3=80=82

Then I try to debug the problem, first I tcpdump the package from cline=
 to server, and found that
the client have send readdirplus message to server correctly, and then =
the Server send a 4k package
to client(the big package will frag to 4 package by GSO), till now it l=
ooks fine, and the Client Nic could
receive the 4 skb then send to upper stack to ipv6 and udp, I found the=
 incoming 4 package has been merged
to one and send to upper stack just like sunrpc, but I try to open the =
rpc_debug, it looks that the rpc could
not receive message.


I built a simple demo to test the udp stack, use the client socket to s=
end big package to server socket, it work well,
so I think the udp is fine, maybe the bug is in sunrpc.

The test is very simple, does any body met the same problem like me, th=
anks for any suggestion.

Ding=20
