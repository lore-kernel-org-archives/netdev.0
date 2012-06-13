From: Gao feng <gaofeng@cn.fujitsu.com>
Subject: =?UTF-8?B?UmU6IG5ldC9uZXRmaWx0ZXIvbmZfY29ubnRyYWNrX3Byb3RvX3RjcC4=?=
 =?UTF-8?B?YzoxNjA2Ojk6IGVycm9yOiDigJhzdHJ1Y3QgbmZfcHJvdG9fbmV04oCZIGhhcyA=?=
 =?UTF-8?B?bm8gbWVtYmVyIG5hbWVkIOKAmHVzZXLigJk=?=
Date: Wed, 13 Jun 2012 16:51:03 +0800
Message-ID: <4FD85477.4050206@cn.fujitsu.com>
References: <4fd664de.oQN9NTKjdledtla0%wfg@linux.intel.com> <20120611221521.GA27239@1984> <20120611.152344.1072167705198124284.davem@davemloft.net> <20120612002655.GA28155@1984> <4FD69F5E.3060900@cn.fujitsu.com> <20120612092940.GB30080@1984> <4FD72203.9090005@cn.fujitsu.com> <20120612160304.GA31427@1984>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, wfg@linux.intel.com,
	netdev@vger.kernel.org
To: Pablo Neira Ayuso <pablo@netfilter.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:57066 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1751132Ab2FMIuh convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 13 Jun 2012 04:50:37 -0400
In-Reply-To: <20120612160304.GA31427@1984>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=E4=BA=8E 2012=E5=B9=B406=E6=9C=8813=E6=97=A5 00:03, Pablo Neira Ayuso =
=E5=86=99=E9=81=93:
> Still, we have that pn->users thing:
>=20
>         if (!pn->users++) {
>                 for (i =3D 0; i < TCP_CONNTRACK_TIMEOUT_MAX; i++)
>                         tn->timeouts[i] =3D tcp_timeouts[i];
>=20
>                 tn->tcp_loose =3D nf_ct_tcp_loose;
>                 tn->tcp_be_liberal =3D nf_ct_tcp_be_liberal;
>                 tn->tcp_max_retrans =3D nf_ct_tcp_max_retrans;
>         }
>=20
> Define some pn->initialized boolean. Set it to true at the end of
> the new tcp_init_net.

It should not be boolean,because We don't know what's the right time to=
 set it false.
Just like nf_conntrack_l4proto_tcp(4,6), they both use nf_tcp_net,we ca=
n set it false
only when tcp4 and tcp6 are unregistered, so we need a referenct count =
here to point
out if one proto has initialied the nf_tcp_net, or if there are no prot=
os use nf_tcp_net.

Though it maybe confusing,we can regard it as the reference count of nf=
_proto_net(how
many protos are using nf_proto_net), and this reference count is increa=
sed when
l4proto being registered success(no matter sysctl is enabled or disable=
d).
