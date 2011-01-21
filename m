From: Christoph Paasch <christoph.paasch@uclouvain.be>
Subject: Re: MultiPath TCP in the Linux Kernel
Date: Fri, 21 Jan 2011 14:19:55 +0100
Message-ID: <201101211419.55476.christoph.paasch@uclouvain.be>
References: <201101201509.34536.christoph.paasch@uclouvain.be> <201101201611.23219.christoph.paasch@uclouvain.be> <AANLkTi=v7jJzfRoeQLGzwU29p2dVqJqd=Eap_8ntfxKP@mail.gmail.com>
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
Received: from smtp.sgsi.ucl.ac.be ([130.104.5.67]:39711 "EHLO
	smtp4.sgsi.ucl.ac.be" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752651Ab1AUNVI convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 21 Jan 2011 08:21:08 -0500
In-Reply-To: <AANLkTi=v7jJzfRoeQLGzwU29p2dVqJqd=Eap_8ntfxKP@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Peter,

On Thursday, January 20, 2011 wrote Peter Chacko:
> Is there any document that shows the difference of SCTP multi-streami=
ng and
> MPTCP ? SCTP team has done lot of great workin in load-balanced
> multi-streaming work across multi-hopped hosts. I am curious to learn=
 more
> on your work in the context of this.
MPTCP can be compared to SCTP-CMT. Regular SCTP just uses one path for =
a=20
stream and thus does not increase the throughput.
At http://inl.info.ucl.ac.be/mptcp/ is a master  thesis from a student,=
 where=20
he compared plenty of different multi-path transport solutions. Have a =
look at=20
the document "multi-path congestion control" from Arnaud Ongenae on thi=
s=20
website.

> Does MP-TCP make use of CM ? (Congestion Manager, created out of MIT)=
 for
> sharing congestion states across TCP ensembles ?
No, MPTCP uses the coupled congestion control. However, this congestion=
-
manager might be an interesting extension to mptcp.

> How does it work with a firewall that will allow only a session that =
is the
> reply of a SYN packet from inside firewall ? (Because other parallel
> streams of TCP doesn't send SYN to the same destination, and how will=
 the
> firewall will allow the replies of this other session go through ? )
You mean the case, where a server has 2 interfaces, and a client (behin=
d the=20
firewall) establishes a MPTCP-session to the server?
The server will tell the client about it's available addresses.
Additionally, the server will try by itself the establishment of the=20
additional subflow. This attempt will get blocked by the firewall.
As the server sended its set of addresses to the client, the client wil=
l also=20
attempt to establish a new subflow. This attempt will pass the firewall=
 as it=20
comes from the inside.

> Is there any commerical use  of this work ?
Our implementation is still in alpha-state. There are still missing fea=
tures,=20
and it's not yet 100% stable. It's a major modification of the TCP/IP-s=
tack=20
because packets from the subflows need to get pushed up to the 'meta-
connection' and reordered there.

> Will this also support message level TCP packet exchange ? (So that  =
main
> strengths of SCTP are "in" to the TCP stack ).
What do you mean with "message level TCP packet exchange" ?

Best regards,
Christoph


> 2011/1/20 Christoph Paasch <christoph.paasch@uclouvain.be>
>=20
> > Hi,
> >=20
> > MultiPath TCP is not a port of SCTP. It is based on regular TCP and
> > presents a
> > regular socket-api to the application. Thus applications do not hav=
e to
> > be modified.
> >=20
> > MPTCP opens several TCP-subflows across it's different IP-addresses=
, and
> > lets
> > the data go over these different TCP sessions. To synchronize the d=
ata-
> > transfer MPTCP uses TCP-options. Thus, on the wire it looks like re=
gular
> > TCP,
> > with the only difference being that there are additional TCP-option=
s.
> >=20
> > MPTCP increases the throughput, because it uses the TCP-subflows
> > simultaneously. With our implementation we got 2Gbps throughput for=
 a
> > single
> > iperf-session on a machine having two 1Gb-interfaces (using
> > jumbo-frames), whereas regular TCP could only go up to 1Gbps, as it=
 only
> > uses one interface.
> >=20
> > To maintain bottleneck-fairness the Coupled Congestion Control cont=
rols
> > the congestion window of the individual subflows (included in the
> > implementation
> > since the latest release).
> > http://datatracker.ietf.org/doc/draft-ietf-mptcp-congestion/
> >=20
> >=20
> > Cheers,
> > Christoph
> >=20
> > P.S.: We have a public webserver running MPTCP at
> > http://mptcp.info.ucl.ac.be
> > So you can directly try out the power of MPTCP... ;-)
> >=20
> > On Thursday, January 20, 2011 wrote Peter Chacko:
> > > SCTP already provides that , and is TCP Multi-Path is going to be=
 a
> > > port
> >=20
> > of
> >=20
> > > it or any other difference ?
> > >=20
> > > We are looking to use SCTP for this feature, but as we found it i=
t has
> >=20
> > not
> >=20
> > > kicked off , because of its firewall issues, we are trying add
> > > Multi-Pathing at application layer, sharing all the congestion
> >=20
> > states(like
> >=20
> > > CM idea) as we are building a WAN optimized storage replication m=
odule
> > > as part of our cloud storage gateway development.
> > >=20
> > > Curious to see more info on this.
> > >=20
> > > Thanks
> > >=20
> > > 2011/1/20 Christoph Paasch <christoph.paasch@uclouvain.be>
> > >=20
> > > > Hi all,
> > > >=20
> > > > The IETF is developing a new transport layer solution, MultiPat=
h TCP,
> > > > which allows to efficiently exploit several Internet paths betw=
een a
> > > > pair of hosts,
> > > > while presenting a single TCP connection to the application lay=
er.
> > > >=20
> > > > At the UCLouvain in Belgium we are developping the support for
> >=20
> > MultiPath
> >=20
> > > > TCP
> > > > in the Linux Kernel. The implementation is a major extension to=
 the
> >=20
> > Linux
> >=20
> > > > TCP-
> > > > stack.
> > > >=20
> > > > For general information, access:
> > > > http://inl.info.ucl.ac.be/mptcp
> > > > https://scm.info.ucl.ac.be/trac/mptcp/
> > > >=20
> > > > To access the git-repository:
> > > > git://scm.info.ucl.ac.be/mtcp.git
> > > >=20
> > > > branches:
> > > >        mptcp_2.6.36 - based on Linux Kernel 2.6.36
> > > >        mtcp_no_subrcvqueue - based on Linux Kernel 2.6.28
> > > >=20
> > > > For questions, feedback,... feel free to subscribe to the mptcp=
-dev
> > > > Mailing-
> > > > List:
> > > > https://listes-2.sipr.ucl.ac.be/sympa/info/mptcp-dev
> > > >=20
> > > >=20
> > > > Regards,
> > > > Christoph
> > > >=20
> > > > --
> > > > Christoph Paasch
> > > > PhD Student
> > > >=20
> > > > IP Networking Lab --- http://inl.info.ucl.ac.be
> > > > MultiPath TCP in the Linux Kernel --- http://inl.info.ucl.ac.be=
/mptcp
> > > > Universit=E9 Catholique de Louvain
> > > >=20
> > > > www.rollerbulls.be
> > > > --
> > > > --
> > > > To unsubscribe from this list: send the line "unsubscribe netde=
v" in
> > > > the body of a message to majordomo@vger.kernel.org
> > > > More majordomo info at  http://vger.kernel.org/majordomo-info.h=
tml
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

--
Christoph Paasch
PhD Student

IP Networking Lab --- http://inl.info.ucl.ac.be
MultiPath TCP in the Linux Kernel --- http://inl.info.ucl.ac.be/mptcp
Universit=E9 Catholique de Louvain

www.rollerbulls.be
--
