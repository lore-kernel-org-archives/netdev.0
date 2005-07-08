From: Arnaldo Carvalho de Melo <arnaldo.melo@gmail.com>
Subject: Re: [PATCH] loop unrolling in net/sched/sch_generic.c
Date: Fri, 8 Jul 2005 08:08:54 -0300
Message-ID: <39e6f6c7050708040877702f6f@mail.gmail.com>
References: <20050706124206.GW16076@postel.suug.ch>
	 <20050707.141718.85410359.davem@davemloft.net>
	 <42CE22CE.7030902@cosmosbay.com>
	 <20050708.003014.125896217.davem@davemloft.net>
	 <42CE3722.3070208@cosmosbay.com>
Reply-To: Arnaldo Carvalho de Melo <arnaldo.melo@gmail.com>
Mime-Version: 1.0
Content-Type: multipart/alternative;
	boundary="----=_Part_1221_18469590.1120820934586"
Cc: "David S. Miller" <davem@davemloft.net>, tgraf@suug.ch, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Eric Dumazet <dada1@cosmosbay.com>
In-Reply-To: <42CE3722.3070208@cosmosbay.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

------=_Part_1221_18469590.1120820934586
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Content-Disposition: inline

On 7/8/05, Eric Dumazet <dada1@cosmosbay.com> wrote:
>=20
> David S. Miller a =E9crit :
> > From: Eric Dumazet <dada1@cosmosbay.com>
> > Date: Fri, 08 Jul 2005 08:53:02 +0200
> >
> >
> >>About making sk_buff smaller, I use this patch to declare 'struct
> >>sec_path *sp' only ifdef CONFIG_XFRM, what do you think ? I also
> >>use a patch to declare nfcache, nfctinfo and nfct only if
> >>CONFIG_NETFILTER_CONNTRACK or CONFIG_NETFILTER_CONNTRACK_MODULE are
> >>defined, but thats more intrusive. Also, tc_index is not used if
> >>CONFIG_NET_SCHED only is declared but none of CONFIG_NET_SCH_* In my
> >>case, I am using CONFIG_NET_SCHED only to be able to do : tc -s -d
> >>qdisc
> >
> >
> > Distributions enable all of the ifdefs, and that is thus the
> > size and resultant performance most users see.
>=20
> Well, I had this idea because I found another similar use in=20
> include/linux/ip.h
>=20
> struct inet_sock {
> /* sk and pinet6 has to be the first two members of inet_sock */
> struct sock sk;
> #if defined(CONFIG_IPV6) || defined(CONFIG_IPV6_MODULE)
> struct ipv6_pinfo *pinet6;
> #endif



/me pleads guilty, Dave, any problem with removing this #ifdef? Humm, I'll=
=20
think about using
the skb_alloc_extension() idea for struct sock, but this pinet6 sucker is a=
=20
bit more difficult I guess...

- Arnaldo

------=_Part_1221_18469590.1120820934586
Content-Type: text/html; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Content-Disposition: inline

<br><br><div><span class=3D"gmail_quote">On 7/8/05, <b class=3D"gmail_sende=
rname">Eric Dumazet</b> &lt;<a href=3D"mailto:dada1@cosmosbay.com">dada1@co=
smosbay.com</a>&gt; wrote:</span><blockquote class=3D"gmail_quote" style=3D=
"border-left: 1px solid rgb(204, 204, 204); margin: 0pt 0pt 0pt 0.8ex; padd=
ing-left: 1ex;">
David S. Miller a =E9crit :<br>&gt; From: Eric Dumazet &lt;<a href=3D"mailt=
o:dada1@cosmosbay.com">dada1@cosmosbay.com</a>&gt;<br>&gt; Date: Fri, 08 Ju=
l 2005 08:53:02 +0200<br>&gt;<br>&gt;<br>&gt;&gt;About making sk_buff small=
er, I use this patch to declare 'struct
<br>&gt;&gt;sec_path *sp' only ifdef CONFIG_XFRM, what do you think ?&nbsp;=
&nbsp;I also<br>&gt;&gt;use a patch to declare nfcache, nfctinfo and nfct o=
nly if<br>&gt;&gt;CONFIG_NETFILTER_CONNTRACK or CONFIG_NETFILTER_CONNTRACK_=
MODULE are
<br>&gt;&gt;defined, but thats more intrusive.&nbsp;&nbsp;Also, tc_index is=
 not used if<br>&gt;&gt;CONFIG_NET_SCHED only is declared but none of CONFI=
G_NET_SCH_* In my<br>&gt;&gt;case, I am using CONFIG_NET_SCHED only to be a=
ble to do : tc -s -d
<br>&gt;&gt;qdisc<br>&gt;<br>&gt;<br>&gt; Distributions enable all of the i=
fdefs, and that is thus the<br>&gt; size and resultant performance most use=
rs see.<br><br>Well, I had this idea because I found another similar use in=
 include/linux/ip.h
<br><br>struct inet_sock {<br>&nbsp;&nbsp;&nbsp;&nbsp; /* sk and pinet6 has=
 to be the first two members of inet_sock */<br>&nbsp;&nbsp;&nbsp;&nbsp; st=
ruct sock&nbsp;&nbsp;&nbsp;&nbsp; sk;<br>#if defined(CONFIG_IPV6) || define=
d(CONFIG_IPV6_MODULE)<br>&nbsp;&nbsp;&nbsp;&nbsp; struct ipv6_pinfo&nbsp;&n=
bsp; *pinet6;
<br>#endif</blockquote><div><br>
<br>
/me pleads guilty, Dave, any problem with removing this #ifdef? Humm, I'll =
think about using<br>
the skb_alloc_extension() idea for struct sock, but this pinet6 sucker is a=
 bit more difficult I guess...<br>
<br>
- Arnaldo<br>
</div><br></div>

------=_Part_1221_18469590.1120820934586--
