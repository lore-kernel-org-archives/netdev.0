From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: Re: =?utf-8?Q?net=2Fnetfilter=2Fnf=5Fconnt?=
	=?utf-8?B?cmFja19wcm90b190Y3AuYzoxNjA2Ojk6IGVycm9yOiDigJhzdHJ1Y3QgbmZf?=
	=?utf-8?B?cHJvdG9fbmV04oCZIGhhcyBubyBtZW1iZXIgbmFtZWQg4oCYdXNlcuKAmQ==?=
Date: Tue, 12 Jun 2012 11:29:40 +0200
Message-ID: <20120612092940.GB30080@1984>
References: <4fd664de.oQN9NTKjdledtla0%wfg@linux.intel.com>
 <20120611221521.GA27239@1984>
 <20120611.152344.1072167705198124284.davem@davemloft.net>
 <20120612002655.GA28155@1984>
 <4FD69F5E.3060900@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, wfg@linux.intel.com,
	netdev@vger.kernel.org
To: Gao feng <gaofeng@cn.fujitsu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:51507 "EHLO mail.us.es"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751448Ab2FLJ3r (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 12 Jun 2012 05:29:47 -0400
Content-Disposition: inline
In-Reply-To: <4FD69F5E.3060900@cn.fujitsu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jun 12, 2012 at 09:46:06AM +0800, Gao feng wrote:
> =E4=BA=8E 2012=E5=B9=B406=E6=9C=8812=E6=97=A5 08:26, Pablo Neira Ayus=
o =E5=86=99=E9=81=93:
> > Hi again David,
> >=20
> > On Mon, Jun 11, 2012 at 03:23:44PM -0700, David Miller wrote:
> >> From: Pablo Neira Ayuso <pablo@netfilter.org>
> >> Date: Tue, 12 Jun 2012 00:15:21 +0200
> >>
> >>> Could you please apply the following patch to net-next to resolve
> >>> this? Thanks.
> >>
> >> Applied, but you have to be kidding me with those ifdefs.
> >>
> >> This is exactly the same kind of thing Gao suggested for
> >> the inetpeer code recently and which I flat out rejected.
> >>
> >> You can't pepper foo.c files with ifdefs all over the place.
> >=20
> > Would you be OK if I send you patches to move all sysctl part of
> > nf_conntrack_proto_*.c to nf_conntrack_proto_*_sysctl.c
> >=20
> > I can also do the same for nf_conntrack_proto.c.
> >=20
> > This means more files under the net/netfilter directory, but less
> > ifdef kludges in the code.
> >=20
> > Please, have a look at the patch enclosed to this email in case you
> > want to see how it would look like in the end with my proposal.
>=20
> I am sorry for all the trouble aroused by my negligence.
>=20
> >  static int tcpv4_init_net(struct net *net)
> >  {
> >  	int i;
> > @@ -1600,11 +1373,7 @@ static int tcpv4_init_net(struct net *net)
> >  	struct nf_tcp_net *tn =3D tcp_pernet(net);
> >  	struct nf_proto_net *pn =3D (struct nf_proto_net *)tn;
> > =20
> > -#ifdef CONFIG_SYSCTL
> > -	if (!pn->ctl_table) {
> > -#else
> >  	if (!pn->users++) {
>=20
> nf_proto_net.users has different meaning when SYSCTL enabled or disab=
led.
>=20
> when SYSCTL enabled,it means if both tcpv4 and tcpv6 register the sys=
ctl,
> it is increased when register sysctl success and decreased when unreg=
ister sysctl.
> we can regard it as the refcnt of ctl_table.
>=20
> when SYSCTL disabled,it just used to identify if the proto's pernet d=
ata
> has been initialized.

We have to use two different counters for this. The conditional
meaning of that variable is really confusing.
