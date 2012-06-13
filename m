From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: Re: =?utf-8?Q?net=2Fnetfilter=2Fnf=5Fconnt?=
	=?utf-8?B?cmFja19wcm90b190Y3AuYzoxNjA2Ojk6IGVycm9yOiDigJhzdHJ1Y3QgbmZf?=
	=?utf-8?B?cHJvdG9fbmV04oCZIGhhcyBubyBtZW1iZXIgbmFtZWQg4oCYdXNlcuKAmQ==?=
Date: Wed, 13 Jun 2012 13:38:34 +0200
Message-ID: <20120613113834.GB4293@1984>
References: <4fd664de.oQN9NTKjdledtla0%wfg@linux.intel.com>
 <20120611221521.GA27239@1984>
 <20120611.152344.1072167705198124284.davem@davemloft.net>
 <20120612002655.GA28155@1984>
 <4FD69F5E.3060900@cn.fujitsu.com>
 <20120612092940.GB30080@1984>
 <4FD72203.9090005@cn.fujitsu.com>
 <20120612160304.GA31427@1984>
 <4FD85477.4050206@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, wfg@linux.intel.com,
	netdev@vger.kernel.org
To: Gao feng <gaofeng@cn.fujitsu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:51525 "EHLO mail.us.es"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753436Ab2FMLim (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 13 Jun 2012 07:38:42 -0400
Content-Disposition: inline
In-Reply-To: <4FD85477.4050206@cn.fujitsu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jun 13, 2012 at 04:51:03PM +0800, Gao feng wrote:
> =E4=BA=8E 2012=E5=B9=B406=E6=9C=8813=E6=97=A5 00:03, Pablo Neira Ayus=
o =E5=86=99=E9=81=93:
> > Still, we have that pn->users thing:
> >=20
> >         if (!pn->users++) {
> >                 for (i =3D 0; i < TCP_CONNTRACK_TIMEOUT_MAX; i++)
> >                         tn->timeouts[i] =3D tcp_timeouts[i];
> >=20
> >                 tn->tcp_loose =3D nf_ct_tcp_loose;
> >                 tn->tcp_be_liberal =3D nf_ct_tcp_be_liberal;
> >                 tn->tcp_max_retrans =3D nf_ct_tcp_max_retrans;
> >         }
> >=20
> > Define some pn->initialized boolean. Set it to true at the end of
> > the new tcp_init_net.
>=20
> It should not be boolean,because We don't know what's the right time =
to set it false.
> Just like nf_conntrack_l4proto_tcp(4,6), they both use nf_tcp_net,we =
can set it false
> only when tcp4 and tcp6 are unregistered, so we need a referenct coun=
t here to point
> out if one proto has initialied the nf_tcp_net, or if there are no pr=
otos use nf_tcp_net.
>
> Though it maybe confusing,we can regard it as the reference count of =
nf_proto_net(how
> many protos are using nf_proto_net), and this reference count is incr=
eased when
> l4proto being registered success(no matter sysctl is enabled or disab=
led).

Yes, it makes sense indeed to regard pn->users as the refcount for the
per-net nf_proto_net. But in that case, I think we have to clean up
the code to increment pn->users everytime nf_conntrack_l[3|4]proto_regi=
ster
is called, and decrement it for nf_conntrack_l[3|4]_unregister case.
Currently, by looking at the code, it seems that pn->users is some
sysctl specific refcount.
