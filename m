From: Eric Dumazet <dada1@cosmosbay.com>
Subject: Re: [PATCH] include listenq max backlog in /proc/net/tcp and
 include in tcp_info
Date: Tue, 11 Sep 2007 19:15:39 +0200
Message-ID: <20070911191539.ff60362b.dada1@cosmosbay.com>
References: <200709102313.QAA01722@tardy.cup.hp.com>
	<1189471180.11066.19.camel@w-sridhar2.beaverton.ibm.com>
	<46E63121.5090607@cosmosbay.com>
	<46E6C9A5.8000008@hp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Sridhar Samudrala <sri@us.ibm.com>, netdev@vger.kernel.org
To: Rick Jones <rick.jones2@hp.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from pfx2.jmh.fr ([194.153.89.55]:35758 "EHLO pfx2.jmh.fr"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756451AbXIKRPk convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 11 Sep 2007 13:15:40 -0400
In-Reply-To: <46E6C9A5.8000008@hp.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 11 Sep 2007 10:00:21 -0700
Rick Jones <rick.jones2@hp.com> wrote:

> Eric Dumazet wrote:
> > Sridhar Samudrala a =E9crit :
> >=20
> >> On Mon, 2007-09-10 at 16:13 -0700, Rick Jones wrote:
> >>
> >>> Return some useful information such as the maximum listen backlog=
 and
> >>> the current listen backlog in the tcp_info structure and have tha=
t=20
> >>> match what one can see in /proc/net/tcp and /proc/net/tcp6.
> >>
> >>
> >> If we are also exporting max listen backlog, another place to
> >> consider adding this is to tcp_diag_get_info() called via INET_DIA=
G_INFO.
> >> Current listen backlog is returned in inet_diag_msg->idiag_rqueue.
> >> max listen backlog can be returned in inet_diag_msg->idiag_wqueue.
> >>
> >=20
> > I agree, /proc/net/tcp is deprecated nowadays...
>=20
> What takes its place?

ss command from iproute2 package ( http://linux-net.osdl.org/index.php/=
Iproute2 )

Problem with /proc/net/tcp is its quadratic time O(N^2) to output N lin=
es...

On a loaded server :

# time ss|wc -l
 145695

real    0m9.383s
user    0m4.656s
sys     0m0.632s

# time netstat -an|wc -l
^C after some minutes .... no way...
real    3m23.825s
user    0m0.744s
sys     3m18.721s


>=20
> > Rick, could you add this part in your patch, and add my Sign-off-by=
 ?
>=20
> My pleasure.
>=20
> I have a small test program for the tcp_info bit - where do I go to f=
ind=20
> how the inet diag stuff works?

ss state listen

>=20
> BTW, what do people think about doing the same thing with the rxqueue=
=20
> and txqueue's of netstat output?
>

I dont understand this question, I thought your patch already handled t=
his=20
(for the txqueue, since rxqueue is already there),  as netstat uses=20
/proc/net/tcp (unfortunatly)

