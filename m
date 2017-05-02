From: Paul Wouters <paul@nohats.ca>
Subject: Re: IPsec PFP support on linux
Date: Tue, 2 May 2017 09:58:28 -0400
Message-ID: <B4EE88ED-B403-42C3-A6D8-1A2526F1DA67@nohats.ca>
References: <20170502123238.GE5843@oracle.com>
Mime-Version: 1.0 (1.0)
Content-Type: multipart/mixed; boundary="===============0112520765574940320=="
Cc: steffen.klassert@secunet.com, borisp@mellanox.com, swan@lists.libreswan.org,
 netdev@vger.kernel.org, ilant@mellanox.com, linux-crypto@vger.kernel.org,
 herbert@gondor.apana.org.au
To: Sowmini Varadhan <sowmini.varadhan@oracle.com>
Return-path: <swan-bounces@lists.libreswan.org>
In-Reply-To: <20170502123238.GE5843@oracle.com>
List-Unsubscribe: <https://lists.libreswan.org/mailman/options/swan>,
 <mailto:swan-request@lists.libreswan.org?subject=unsubscribe>
List-Archive: <https://lists.libreswan.org/pipermail/swan/>
List-Post: <mailto:swan@lists.libreswan.org>
List-Help: <mailto:swan-request@lists.libreswan.org?subject=help>
List-Subscribe: <https://lists.libreswan.org/mailman/listinfo/swan>,
 <mailto:swan-request@lists.libreswan.org?subject=subscribe>
Errors-To: swan-bounces@lists.libreswan.org
Sender: "Swan" <swan-bounces@lists.libreswan.org>
List-Id: netdev.vger.kernel.org


--===============0112520765574940320==
Content-Type: multipart/alternative;
	boundary=Apple-Mail-6FB7842E-2DA8-4EAD-9068-F24DDFFC3E40
Content-Transfer-Encoding: 7bit


--Apple-Mail-6FB7842E-2DA8-4EAD-9068-F24DDFFC3E40
Content-Type: text/plain;
	charset=us-ascii
Content-Transfer-Encoding: quoted-printable

I think you want to use Opportunistic IPsec, eg see=20

https://libreswan.org/wiki/HOWTO:_Opportunistic_IPsec

Note that IKEv2 also allows you to define one connection and instantiate  a c=
onnection based on the trigger packet whose src/dst proto/port are included i=
n the IKEv2 packet as traffic selectors. See RFC7296 and "narrowing".

Paul


Sent from my iPhone

> On May 2, 2017, at 08:32, Sowmini Varadhan <sowmini.varadhan@oracle.com> w=
rote:
>=20
> I have a question about linux support for IPsec PFP (as defined in
> rfc 4301). I am assuming this exists, and is accessible from uspace,
> in which case I need some hints on how to set it up.
>=20
> Assuming I have a server listening at port 5001 that I want to
> secure via ipsec. Suppose I want to make sure that each TCP/UDP 5-tuple
> sending packets to port 5001 gets its own SA.
>=20
> RFC4301 has this:
>=20
>       - SPD-S: For traffic that is to be protected using IPsec, the
>         entry consists of the values of the selectors that apply to the
>         traffic to be protected via AH or ESP, controls on how to
>         create SAs based on these selectors, ...
>=20
> and further down
>      If IPsec processing is specified for
>      an entry, a "populate from packet" (PFP) flag may be asserted for
>      one or more of the selectors in the SPD entry (Local IP address;
>      Remote IP address; Next Layer Protocol; and, depending on Next
>      Layer Protocol, Local port and Remote port, or ICMP type/code, or
>      Mobility Header type).  If asserted for a given selector X, the
>      flag indicates that the SA to be created should take its value for
>      X from the value in the packet.  Otherwise, the SA should take its
>      value(s) for X from the value(s) in the SPD entry.
>=20
> A google search produces a discarded patch
>  http://marc.info/?l=3Dlinux-netdev&m=3D119746758904140
> but its not clear to me how to set this up (if PFP works fine,
> as suggested by Herbert's response above)
>=20
> I tried experimenting with IP_XFRM_POLICY from a simple udp client but
> (a) that seems to require a SPI and reqid to set up the SPD=20
> (b) I see the SADB_ACQUIRE upcall being triggered after the local port
>    is bound (and SADB entry is set up for the lport).  But ike phase2
>    does not converge for the lport specific sadb added
>    by the bind (even in quick mode)
>=20
> My understanding is that pluto shoud be generating spi's to make sure
> they are sufficiently unique/random etc. so (a) makes me think I'm
> either not setting this up or not using this correctly.
>=20
> Any hints/sample code/RTFMs would be helpful (documentation for
> IP_XFRM_POLICY seems scant, afaict). I'd be happy to share my=20
> udp client program, if it can provide more context to my question.
>=20
> --Sowmini
>=20
> _______________________________________________
> Swan mailing list
> Swan@lists.libreswan.org
> https://lists.libreswan.org/mailman/listinfo/swan

--Apple-Mail-6FB7842E-2DA8-4EAD-9068-F24DDFFC3E40
Content-Type: text/html;
	charset=utf-8
Content-Transfer-Encoding: quoted-printable

<html><head><meta http-equiv=3D"content-type" content=3D"text/html; charset=3D=
utf-8"></head><body dir=3D"auto"><div>I think you want to use Opportunistic I=
Psec, eg see&nbsp;</div><div><br></div><div><a href=3D"https://libreswan.org=
/wiki/HOWTO:_Opportunistic_IPsec">https://libreswan.org/wiki/HOWTO:_Opportun=
istic_IPsec</a></div><div><br></div><div>Note that IKEv2 also allows you to d=
efine one connection and instantiate &nbsp;a connection based on the trigger=
 packet whose src/dst proto/port are included in the IKEv2 packet as traffic=
 selectors. See RFC7296 and "narrowing".</div><div><br></div><div>Paul</div>=
<div><br></div><div><br><div>Sent from my iPhone</div></div><div><br>On May 2=
, 2017, at 08:32, Sowmini Varadhan &lt;<a href=3D"mailto:sowmini.varadhan@or=
acle.com">sowmini.varadhan@oracle.com</a>&gt; wrote:<br><br></div><blockquot=
e type=3D"cite"><div><span>I have a question about linux support for IPsec P=
FP (as defined in</span><br><span>rfc 4301). I am assuming this exists, and i=
s accessible from uspace,</span><br><span>in which case I need some hints on=
 how to set it up.</span><br><span></span><br><span>Assuming I have a server=
 listening at port 5001 that I want to</span><br><span>secure via ipsec. Sup=
pose I want to make sure that each TCP/UDP 5-tuple</span><br><span>sending p=
ackets to port 5001 gets its own SA.</span><br><span></span><br><span>RFC430=
1 has this:</span><br><span></span><br><span> &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;=
&nbsp;- SPD-S: For traffic that is to be protected using IPsec, the</span><b=
r><span> &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;entry consists of t=
he values of the selectors that apply to the</span><br><span> &nbsp;&nbsp;&n=
bsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;traffic to be protected via AH or ESP, con=
trols on how to</span><br><span> &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&=
nbsp;create SAs based on these selectors, ...</span><br><span></span><br><sp=
an>and further down</span><br><span> &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;If IPsec p=
rocessing is specified for</span><br><span> &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;an=
 entry, a "populate from packet" (PFP) flag may be asserted for</span><br><s=
pan> &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;one or more of the selectors in the SPD e=
ntry (Local IP address;</span><br><span> &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Remot=
e IP address; Next Layer Protocol; and, depending on Next</span><br><span> &=
nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Layer Protocol, Local port and Remote port, or I=
CMP type/code, or</span><br><span> &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Mobility He=
ader type). &nbsp;If asserted for a given selector X, the</span><br><span> &=
nbsp;&nbsp;&nbsp;&nbsp;&nbsp;flag indicates that the SA to be created should=
 take its value for</span><br><span> &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;X from th=
e value in the packet. &nbsp;Otherwise, the SA should take its</span><br><sp=
an> &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;value(s) for X from the value(s) in the SP=
D entry.</span><br><span></span><br><span>A google search produces a discard=
ed patch</span><br><span> &nbsp;<a href=3D"http://marc.info/?l=3Dlinux-netde=
v&amp;m=3D119746758904140">http://marc.info/?l=3Dlinux-netdev&amp;m=3D119746=
758904140</a></span><br><span>but its not clear to me how to set this up (if=
 PFP works fine,</span><br><span>as suggested by Herbert's response above)</=
span><br><span></span><br><span>I tried experimenting with IP_XFRM_POLICY fr=
om a simple udp client but</span><br><span>(a) that seems to require a SPI a=
nd reqid to set up the SPD </span><br><span>(b) I see the SADB_ACQUIRE upcal=
l being triggered after the local port</span><br><span> &nbsp;&nbsp;&nbsp;is=
 bound (and SADB entry is set up for the lport). &nbsp;But ike phase2</span>=
<br><span> &nbsp;&nbsp;&nbsp;does not converge for the lport specific sadb a=
dded</span><br><span> &nbsp;&nbsp;&nbsp;by the bind (even in quick mode)</sp=
an><br><span></span><br><span>My understanding is that pluto shoud be genera=
ting spi's to make sure</span><br><span>they are sufficiently unique/random e=
tc. so (a) makes me think I'm</span><br><span>either not setting this up or n=
ot using this correctly.</span><br><span></span><br><span>Any hints/sample c=
ode/RTFMs would be helpful (documentation for</span><br><span>IP_XFRM_POLICY=
 seems scant, afaict). I'd be happy to share my </span><br><span>udp client p=
rogram, if it can provide more context to my question.</span><br><span></spa=
n><br><span>--Sowmini</span><br><span></span><br><span>_____________________=
__________________________</span><br><span>Swan mailing list</span><br><span=
><a href=3D"mailto:Swan@lists.libreswan.org">Swan@lists.libreswan.org</a></s=
pan><br><span><a href=3D"https://lists.libreswan.org/mailman/listinfo/swan">=
https://lists.libreswan.org/mailman/listinfo/swan</a></span><br></div></bloc=
kquote></body></html>=

--Apple-Mail-6FB7842E-2DA8-4EAD-9068-F24DDFFC3E40--

--===============0112520765574940320==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline


--===============0112520765574940320==--
