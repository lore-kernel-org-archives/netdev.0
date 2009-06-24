From: Andy Fleming <afleming@freescale.com>
Subject: Re: [PATCH] gianfar: Fix half-duplex operation for non-MII/RMII
	interfaces
Date: Wed, 24 Jun 2009 16:25:06 -0500
Message-ID: <FFCBF074-5F39-4D0C-A0C3-F488A619C821@freescale.com>
References: <20090624182734.GA14306@oksana.dev.rtsoft.ru>
	<ED58F994-6BDC-4496-8445-EA1D984F1379@freescale.com>
	<20090624211038.GA29555@oksana.dev.rtsoft.ru>
Mime-Version: 1.0 (Apple Message framework v935.3)
Content-Type: multipart/mixed; boundary="===============2002839707152223404=="
Cc: linuxppc-dev@ozlabs.org, netdev@vger.kernel.org,
	Li Yang <leoli@freescale.com>, David Miller <davem@davemloft.net>
To: avorontsov@ru.mvista.com
Return-path: <linuxppc-dev-bounces+glppd-linuxppc64-dev=m.gmane.org@lists.ozlabs.org>
In-Reply-To: <20090624211038.GA29555@oksana.dev.rtsoft.ru>
List-Unsubscribe: <https://lists.ozlabs.org/options/linuxppc-dev>,
	<mailto:linuxppc-dev-request@lists.ozlabs.org?subject=unsubscribe>
List-Archive: <http://lists.ozlabs.org/pipermail/linuxppc-dev>
List-Post: <mailto:linuxppc-dev@lists.ozlabs.org>
List-Help: <mailto:linuxppc-dev-request@lists.ozlabs.org?subject=help>
List-Subscribe: <https://lists.ozlabs.org/listinfo/linuxppc-dev>,
	<mailto:linuxppc-dev-request@lists.ozlabs.org?subject=subscribe>
Mime-version: 1.0
Sender: linuxppc-dev-bounces+glppd-linuxppc64-dev=m.gmane.org@lists.ozlabs.org
Errors-To: linuxppc-dev-bounces+glppd-linuxppc64-dev=m.gmane.org@lists.ozlabs.org
List-Id: netdev.vger.kernel.org


--===============2002839707152223404==
Content-Type: multipart/alternative; boundary=Apple-Mail-6--863949227


--Apple-Mail-6--863949227
Content-Type: text/plain;
	charset=US-ASCII;
	format=flowed;
	delsp=yes
Content-Transfer-Encoding: 7bit

>
>> *Technically*, full
>> duplex is required for GMII, as GMII is used only for gigabit.   
>> However,
>> we've been treating the GMII interface type as an indicator that  
>> the PHY
>> *has* a GMII connection to the NIC.  When gianfar detects the speed  
>> is
>> 10/100 it switches to the compatible MII interface via this code,  
>> just
>> below:
>>
>>                        case 100:
>>                        case 10:
>>                                tempval =
>>                                    ((tempval & ~(MACCFG2_IF)) |
>> MACCFG2_MII);
>>
>>
>> My concern is that you will be detecting the GMII interface, and
>> disallowing half-duplex, despite the fact that the interface is  
>> actually
>> running at 10 or 100 Mbit.
>
> Very interesting, though I'm not sure I'm completely following. :-)
>
> Are you saying that I should do this instead:
>
> 	if (!phydev->duplex &&
> 			(phyi == PHY_INTERFACE_MODE_MII ||
> 			 phyi == PHY_INTERFACE_MODE_RMII ||
> 			 (phyi == PHY_INTERFACE_MODE_GMII &&
> 			  phydev->speed < 1000)))
> 		tempval &= ~MACCFG2_FULL_DUPLEX;
> 	else
> 		tempval |= MACCFG2_FULL_DUPLEX;
>
> i.e. we detected GMII interface initially, but it downgraded
> to MII since speed is < 1000, thus we can set half-duplex in MAC?

Yeah, I think that works out more correctly.  And I suspect that the  
same is true for UCC

Andy
--Apple-Mail-6--863949227
Content-Type: text/html;
	charset=US-ASCII
Content-Transfer-Encoding: quoted-printable

<html><body style=3D"word-wrap: break-word; -webkit-nbsp-mode: space; =
-webkit-line-break: after-white-space; "><div><blockquote =
type=3D"cite"><div><font class=3D"Apple-style-span" =
color=3D"#000000"><br></font><blockquote type=3D"cite"> *Technically*, =
full &nbsp;<br></blockquote><blockquote type=3D"cite">duplex is required =
for GMII, as GMII is used only for gigabit. &nbsp;However, =
<br></blockquote><blockquote type=3D"cite">we've been treating the GMII =
interface type as an indicator that the PHY <br></blockquote><blockquote =
type=3D"cite">*has* a GMII connection to the NIC. &nbsp;When gianfar =
detects the speed is <br></blockquote><blockquote type=3D"cite">10/100 =
it switches to the compatible MII interface via this code, just =
<br></blockquote><blockquote =
type=3D"cite">below:<br></blockquote><blockquote =
type=3D"cite"><br></blockquote><blockquote type=3D"cite"> =
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&n=
bsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;case =
100:<br></blockquote><blockquote type=3D"cite"> =
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&n=
bsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;case =
10:<br></blockquote><blockquote type=3D"cite"> =
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&n=
bsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbs=
p;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;tempval =
=3D<br></blockquote><blockquote type=3D"cite"> =
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&n=
bsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbs=
p;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;((tempval =
&amp; ~(MACCFG2_IF)) | &nbsp;<br></blockquote><blockquote =
type=3D"cite">MACCFG2_MII);<br></blockquote><blockquote =
type=3D"cite"><br></blockquote><blockquote =
type=3D"cite"><br></blockquote><blockquote type=3D"cite">My concern is =
that you will be detecting the GMII interface, and =
&nbsp;<br></blockquote><blockquote type=3D"cite">disallowing =
half-duplex, despite the fact that the interface is actually =
<br></blockquote><blockquote type=3D"cite">running at 10 or 100 =
Mbit.<br></blockquote><br>Very interesting, though I'm not sure I'm =
completely following. :-)<br><br>Are you saying that I should do this =
instead:<br><br><span class=3D"Apple-tab-span" style=3D"white-space:pre">	=
</span>if (!phydev-&gt;duplex &amp;&amp;<br><span class=3D"Apple-tab-span"=
 style=3D"white-space:pre">	</span><span class=3D"Apple-tab-span" =
style=3D"white-space:pre">	</span><span class=3D"Apple-tab-span" =
style=3D"white-space:pre">	</span>(phyi =3D=3D =
PHY_INTERFACE_MODE_MII ||<br><span class=3D"Apple-tab-span" =
style=3D"white-space:pre">	</span><span class=3D"Apple-tab-span" =
style=3D"white-space:pre">	</span><span class=3D"Apple-tab-span" =
style=3D"white-space:pre">	</span> phyi =3D=3D =
PHY_INTERFACE_MODE_RMII ||<br><span class=3D"Apple-tab-span" =
style=3D"white-space:pre">	</span><span class=3D"Apple-tab-span" =
style=3D"white-space:pre">	</span><span class=3D"Apple-tab-span" =
style=3D"white-space:pre">	</span> (phyi =3D=3D =
PHY_INTERFACE_MODE_GMII &amp;&amp;<br><span class=3D"Apple-tab-span" =
style=3D"white-space:pre">	</span><span class=3D"Apple-tab-span" =
style=3D"white-space:pre">	</span><span class=3D"Apple-tab-span" =
style=3D"white-space:pre">	</span> &nbsp;phydev-&gt;speed &lt; =
1000)))<br><span class=3D"Apple-tab-span" style=3D"white-space:pre">	=
</span><span class=3D"Apple-tab-span" style=3D"white-space:pre">	=
</span>tempval &amp;=3D ~MACCFG2_FULL_DUPLEX;<br><span =
class=3D"Apple-tab-span" style=3D"white-space:pre">	=
</span>else<br><span class=3D"Apple-tab-span" style=3D"white-space:pre">	=
</span><span class=3D"Apple-tab-span" style=3D"white-space:pre">	=
</span>tempval |=3D MACCFG2_FULL_DUPLEX;<br><br>i.e. we detected GMII =
interface initially, but it downgraded<br>to MII since speed is &lt; =
1000, thus we can set half-duplex in =
MAC?<br></div></blockquote></div><br><div>Yeah, I think that works out =
more correctly. &nbsp;And I suspect that the same is true for =
UCC</div><div><br></div><div>Andy</div></body></html>=

--Apple-Mail-6--863949227--

--===============2002839707152223404==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
Linuxppc-dev mailing list
Linuxppc-dev@lists.ozlabs.org
https://lists.ozlabs.org/listinfo/linuxppc-dev
--===============2002839707152223404==--
