From: Gao feng <gaofeng@cn.fujitsu.com>
Subject: =?UTF-8?B?UmU6IG5ldC9uZXRmaWx0ZXIvbmZfY29ubnRyYWNrX3Byb3RvX3RjcC4=?=
 =?UTF-8?B?YzoxNjA2Ojk6IGVycm9yOiDigJhzdHJ1Y3QgbmZfcHJvdG9fbmV04oCZIGhhcyA=?=
 =?UTF-8?B?bm8gbWVtYmVyIG5hbWVkIOKAmHVzZXLigJk=?=
Date: Tue, 12 Jun 2012 09:46:06 +0800
Message-ID: <4FD69F5E.3060900@cn.fujitsu.com>
References: <4fd664de.oQN9NTKjdledtla0%wfg@linux.intel.com> <20120611221521.GA27239@1984> <20120611.152344.1072167705198124284.davem@davemloft.net> <20120612002655.GA28155@1984>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, wfg@linux.intel.com,
	netdev@vger.kernel.org
To: Pablo Neira Ayuso <pablo@netfilter.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:51228 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1753153Ab2FLBpi convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 11 Jun 2012 21:45:38 -0400
In-Reply-To: <20120612002655.GA28155@1984>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=E4=BA=8E 2012=E5=B9=B406=E6=9C=8812=E6=97=A5 08:26, Pablo Neira Ayuso =
=E5=86=99=E9=81=93:
> Hi again David,
>=20
> On Mon, Jun 11, 2012 at 03:23:44PM -0700, David Miller wrote:
>> From: Pablo Neira Ayuso <pablo@netfilter.org>
>> Date: Tue, 12 Jun 2012 00:15:21 +0200
>>
>>> Could you please apply the following patch to net-next to resolve
>>> this? Thanks.
>>
>> Applied, but you have to be kidding me with those ifdefs.
>>
>> This is exactly the same kind of thing Gao suggested for
>> the inetpeer code recently and which I flat out rejected.
>>
>> You can't pepper foo.c files with ifdefs all over the place.
>=20
> Would you be OK if I send you patches to move all sysctl part of
> nf_conntrack_proto_*.c to nf_conntrack_proto_*_sysctl.c
>=20
> I can also do the same for nf_conntrack_proto.c.
>=20
> This means more files under the net/netfilter directory, but less
> ifdef kludges in the code.
>=20
> Please, have a look at the patch enclosed to this email in case you
> want to see how it would look like in the end with my proposal.

I am sorry for all the trouble aroused by my negligence.

>  static int tcpv4_init_net(struct net *net)
>  {
>  	int i;
> @@ -1600,11 +1373,7 @@ static int tcpv4_init_net(struct net *net)
>  	struct nf_tcp_net *tn =3D tcp_pernet(net);
>  	struct nf_proto_net *pn =3D (struct nf_proto_net *)tn;
> =20
> -#ifdef CONFIG_SYSCTL
> -	if (!pn->ctl_table) {
> -#else
>  	if (!pn->users++) {

nf_proto_net.users has different meaning when SYSCTL enabled or disable=
d.

when SYSCTL enabled,it means if both tcpv4 and tcpv6 register the sysct=
l,
it is increased when register sysctl success and decreased when unregis=
ter sysctl.
we can regard it as the refcnt of ctl_table.

when SYSCTL disabled,it just used to identify if the proto's pernet dat=
a
has been initialized.
