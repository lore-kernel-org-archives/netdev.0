From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [RFC] Is it a bug for nfs on udp6 mode or kernel?
Date: Wed, 13 Apr 2016 09:17:06 -0700
Message-ID: <1460564226.10638.28.camel@edumazet-glaptop3.roam.corp.google.com>
References: <570E2D69.7080102@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-nfs-approval@vger.kernel.org, tom@herbertland.com,
	Netdev <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	dhowells@redhat.com, viro@zeniv.linux.org.u, chuck.lever@oracle.com
To: Ding Tianhong <dingtianhong@huawei.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f41.google.com ([209.85.220.41]:34956 "EHLO
	mail-pa0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750848AbcDMQRJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 13 Apr 2016 12:17:09 -0400
In-Reply-To: <570E2D69.7080102@huawei.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2016-04-13 at 19:28 +0800, Ding Tianhong wrote:
> Hi everyone:
>=20
> I have met this problem when I try to test udp6 for nfs connection, m=
y environment is:
>=20
> Server:
> kernel: 4.1.15
> IP:xxxx::36/64
> MTU:1500
> Setting: /etc/exports:/home/nfs *(rw,sync,no_subtree_check,no_root_sq=
uash)
>=20
> Client:
> kernel: 4.1.18
> IP:xxxx::90/64
> MTU:1500
> command: mount -t nfs -o vers=3D3,proto=3Dudp6,rsize=3D4096,wsize=3D4=
096 [xxxx::36]:/home/nfs /home/tmp
>=20
> I check the nfs parameter configuration, it looks fine and could work=
 well for proto=3Dtcp6.
>=20
> Then I have mount correctly and try to run the command "ls", it hang.
>=20
> When I use the rsize=3D1024 and wsize=3D1024 to mount, the problem di=
sappeared, so I guess it is the problem for GSO or GRO for UDP=E3=80=82
>=20
> Then I try to debug the problem, first I tcpdump the package from cli=
ne to server, and found that
> the client have send readdirplus message to server correctly, and the=
n the Server send a 4k package
> to client(the big package will frag to 4 package by GSO), till now it=
 looks fine, and the Client Nic could
> receive the 4 skb then send to upper stack to ipv6 and udp, I found t=
he incoming 4 package has been merged
> to one and send to upper stack just like sunrpc, but I try to open th=
e rpc_debug, it looks that the rpc could
> not receive message.
>=20
>=20
> I built a simple demo to test the udp stack, use the client socket to=
 send big package to server socket, it work well,
> so I think the udp is fine, maybe the bug is in sunrpc.
>=20
> The test is very simple, does any body met the same problem like me, =
thanks for any suggestion.
>=20
> Ding=20

Have you tried to disable UFO ?

ethtool -K eth... ufo off
