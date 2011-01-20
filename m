From: Christoph Paasch <christoph.paasch@uclouvain.be>
Subject: Re: MultiPath TCP in the Linux Kernel
Date: Thu, 20 Jan 2011 16:11:22 +0100
Message-ID: <201101201611.23219.christoph.paasch@uclouvain.be>
References: <201101201509.34536.christoph.paasch@uclouvain.be> <AANLkTinkqCjQqRKDFnxTF4-uF27XyPzh0gY-vX3fnfSo@mail.gmail.com>
Reply-To: christoph.paasch@uclouvain.be
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-15
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, bonding-devel@lists.sourceforge.net,
	linux-sctp@vger.kernel.org, MS PRASAD <prasad_drdo@rediffmail.com>,
	Lal Samuel Varghese <lalsam@gmail.com>,
	"Gregory S. Tseytin" <tseyting@acm.org>
To: Peter Chacko <peterchacko35@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.sgsi.ucl.ac.be ([130.104.5.67]:51802 "EHLO
	smtp4.sgsi.ucl.ac.be" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755795Ab1ATPO0 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 20 Jan 2011 10:14:26 -0500
In-Reply-To: <AANLkTinkqCjQqRKDFnxTF4-uF27XyPzh0gY-vX3fnfSo@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

MultiPath TCP is not a port of SCTP. It is based on regular TCP and pre=
sents a=20
regular socket-api to the application. Thus applications do not have to=
 be=20
modified.

MPTCP opens several TCP-subflows across it's different IP-addresses, an=
d lets=20
the data go over these different TCP sessions. To synchronize the data-
transfer MPTCP uses TCP-options. Thus, on the wire it looks like regula=
r TCP,=20
with the only difference being that there are additional TCP-options.

MPTCP increases the throughput, because it uses the TCP-subflows=20
simultaneously. With our implementation we got 2Gbps throughput for a s=
ingle=20
iperf-session on a machine having two 1Gb-interfaces (using jumbo-frame=
s),=20
whereas regular TCP could only go up to 1Gbps, as it only uses one inte=
rface.

To maintain bottleneck-fairness the Coupled Congestion Control controls=
 the=20
congestion window of the individual subflows (included in the implement=
ation=20
since the latest release).
http://datatracker.ietf.org/doc/draft-ietf-mptcp-congestion/


Cheers,
Christoph

P.S.: We have a public webserver running MPTCP at http://mptcp.info.ucl=
=2Eac.be
So you can directly try out the power of MPTCP... ;-)

On Thursday, January 20, 2011 wrote Peter Chacko:
> SCTP already provides that , and is TCP Multi-Path is going to be a p=
ort of
> it or any other difference ?
>=20
> We are looking to use SCTP for this feature, but as we found it it ha=
s not
> kicked off , because of its firewall issues, we are trying add
> Multi-Pathing at application layer, sharing all the congestion states=
(like
> CM idea) as we are building a WAN optimized storage replication modul=
e as
> part of our cloud storage gateway development.
>=20
> Curious to see more info on this.
>=20
> Thanks
>=20
> 2011/1/20 Christoph Paasch <christoph.paasch@uclouvain.be>
>=20
> > Hi all,
> >=20
> > The IETF is developing a new transport layer solution, MultiPath TC=
P,
> > which allows to efficiently exploit several Internet paths between =
a
> > pair of hosts,
> > while presenting a single TCP connection to the application layer.
> >=20
> > At the UCLouvain in Belgium we are developping the support for Mult=
iPath
> > TCP
> > in the Linux Kernel. The implementation is a major extension to the=
 Linux
> > TCP-
> > stack.
> >=20
> > For general information, access:
> > http://inl.info.ucl.ac.be/mptcp
> > https://scm.info.ucl.ac.be/trac/mptcp/
> >=20
> > To access the git-repository:
> > git://scm.info.ucl.ac.be/mtcp.git
> >=20
> > branches:
> >        mptcp_2.6.36 - based on Linux Kernel 2.6.36
> >        mtcp_no_subrcvqueue - based on Linux Kernel 2.6.28
> >=20
> > For questions, feedback,... feel free to subscribe to the mptcp-dev
> > Mailing-
> > List:
> > https://listes-2.sipr.ucl.ac.be/sympa/info/mptcp-dev
> >=20
> >=20
> > Regards,
> > Christoph
> >=20
> > --
> > Christoph Paasch
> > PhD Student
> >=20
> > IP Networking Lab --- http://inl.info.ucl.ac.be
> > MultiPath TCP in the Linux Kernel --- http://inl.info.ucl.ac.be/mpt=
cp
> > Universit=E9 Catholique de Louvain
> >=20
> > www.rollerbulls.be
> > --
> > --
> > To unsubscribe from this list: send the line "unsubscribe netdev" i=
n
> > the body of a message to majordomo@vger.kernel.org
> > More majordomo info at  http://vger.kernel.org/majordomo-info.html

--
Christoph Paasch
PhD Student

IP Networking Lab --- http://inl.info.ucl.ac.be
MultiPath TCP in the Linux Kernel --- http://inl.info.ucl.ac.be/mptcp
Universit=E9 Catholique de Louvain

www.rollerbulls.be
--
