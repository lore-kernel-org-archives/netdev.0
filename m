From: Ding Tianhong <dingtianhong@huawei.com>
Subject: Re: [RFC] Is it a bug for nfs on udp6 mode or kernel?
Date: Thu, 14 Apr 2016 08:56:13 +0800
Message-ID: <570EEAAD.2070907@huawei.com>
References: <570E2D69.7080102@huawei.com>
 <alpine.OSX.2.19.9992.1604131003530.55780@planck>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: <linux-nfs-approval@vger.kernel.org>, <tom@herbertland.com>,
	Netdev <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	<dhowells@redhat.com>, <viro@zeniv.linux.org.u>,
	<chuck.lever@oracle.com>
To: Benjamin Coddington <bcodding@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from szxga02-in.huawei.com ([119.145.14.65]:3951 "EHLO
	szxga02-in.huawei.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752086AbcDNA4X (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 13 Apr 2016 20:56:23 -0400
In-Reply-To: <alpine.OSX.2.19.9992.1604131003530.55780@planck>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 2016/4/13 22:11, Benjamin Coddington wrote:
> On Wed, 13 Apr 2016, Ding Tianhong wrote:
>=20
>> Hi everyone:
>>
>> I have met this problem when I try to test udp6 for nfs connection, =
my environment is:
>>
>> Server:
>> kernel: 4.1.15
>> IP:xxxx::36/64
>> MTU:1500
>> Setting: /etc/exports:/home/nfs *(rw,sync,no_subtree_check,no_root_s=
quash)
>>
>> Client:
>> kernel: 4.1.18
>> IP:xxxx::90/64
>> MTU:1500
>> command: mount -t nfs -o vers=3D3,proto=3Dudp6,rsize=3D4096,wsize=3D=
4096 [xxxx::36]:/home/nfs /home/tmp
>>
>> I check the nfs parameter configuration, it looks fine and could wor=
k well for proto=3Dtcp6.
>>
>> Then I have mount correctly and try to run the command "ls", it hang=
=2E
>>
>> When I use the rsize=3D1024 and wsize=3D1024 to mount, the problem d=
isappeared, so I guess it is the problem for GSO or GRO for UDP=E3=80=82
>>
>> Then I try to debug the problem, first I tcpdump the package from cl=
ine to server, and found that
>> the client have send readdirplus message to server correctly, and th=
en the Server send a 4k package
>> to client(the big package will frag to 4 package by GSO), till now i=
t looks fine, and the Client Nic could
>> receive the 4 skb then send to upper stack to ipv6 and udp, I found =
the incoming 4 package has been merged
>> to one and send to upper stack just like sunrpc, but I try to open t=
he rpc_debug, it looks that the rpc could
>> not receive message.
>>
>>
>> I built a simple demo to test the udp stack, use the client socket t=
o send big package to server socket, it work well,
>> so I think the udp is fine, maybe the bug is in sunrpc.
>>
>> The test is very simple, does any body met the same problem like me,=
 thanks for any suggestion.
>>
>> Ding
>=20
> I had a similar problem. Do you have upstream
>=20
> 405c92f ("ipv6: add defensive check for CHECKSUM_PARTIAL skbs in ip_f=
ragment")
> 682b1a9 ("ipv6: no CHECKSUM_PARTIAL on MSG_MORE corked sockets")
>=20

Hi Ben:

Thanks for the feedback, my kernel is 4.1.15, not merged these two patc=
h, I will check and try, thanks a lot.


> Turning off GSO and GRO caused sunrpc to work properly before this.
>=20
> https://bugzilla.redhat.com/show_bug.cgi?id=3D1271759
>=20

Sorry, I don't have permission to read this, but thanks for this messag=
e.:)

Ding

> Ben
>=20
