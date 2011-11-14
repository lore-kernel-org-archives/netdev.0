From: "Fritz, Wolfgang" <Wolfgang.Fritz@keymile.com>
Subject: Re: [PATCH] net,
	bridge: print log message after state changed
Date: Mon, 14 Nov 2011 10:10:53 +0100
Message-ID: <1321261853.4072.75.camel@pc005091.de.keymile.net>
References: <1320941934-3534-1-git-send-email-holger.brunck@keymile.com>
	<20111114.003702.1097206603722725705.davem@davemloft.net>
	<1321254211.4072.29.camel@pc005091.de.keymile.net>
	<20111114.020749.1176229013272872343.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="===============2647726476093602713=="
Cc: netdev@vger.kernel.org, shemminger@linux-foundation.org,
	bridge@lists.linux-foundation.org, "Brunck,
	Holger" <holger.brunck@keymile.com>
To: "David Miller" <davem@davemloft.net>
Return-path: <bridge-bounces@lists.linux-foundation.org>
Content-class: urn:content-classes:message
In-Reply-To: <20111114.020749.1176229013272872343.davem@davemloft.net>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/bridge>,
	<mailto:bridge-request@lists.linux-foundation.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/bridge/>
List-Post: <mailto:bridge@lists.linux-foundation.org>
List-Help: <mailto:bridge-request@lists.linux-foundation.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/bridge>,
	<mailto:bridge-request@lists.linux-foundation.org?subject=subscribe>
Sender: bridge-bounces@lists.linux-foundation.org
Errors-To: bridge-bounces@lists.linux-foundation.org
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.

--===============2647726476093602713==
Content-Type: multipart/alternative;
	boundary="----_=_NextPart_001_01CCA2AD.4F9473E6"
Content-class: urn:content-classes:message

This is a multi-part message in MIME format.

------_=_NextPart_001_01CCA2AD.4F9473E6
Content-Type: text/plain;
	charset="ISO-8859-15"
Content-Transfer-Encoding: quoted-printable


Am Montag, den 14.11.2011, 02:07 -0500 schrieb David Miller:
> From: "Fritz, Wolfgang" <Wolfgang.Fritz@keymile.com>
> Date: Mon, 14 Nov 2011 08:03:31 +0100
>=20
> >=20
> > Am Montag, den 14.11.2011, 00:37 -0500 schrieb David Miller:
> >> From: Holger Brunck <holger.brunck@keymile.com>
> >> Date: Thu, 10 Nov 2011 17:18:54 +0100
> >>=20
> >> > From: Wolfgang Fritz <wolfgang.fritz@keymile.com>
> >> >=20
> >> > Function br_log_state writes log message "... entering XXXX =
state" so it
> >> > should be called after the state has changed and not before.
> >> >=20
> >> > Signed-off-by: Wolfgang Fritz <wolfgang.fritz@keymile.com>
> >> > Signed-off-by: Holger Brunck <holger.brunck@keymile.com>
> >>=20
> >> "entering" can roughly mean "about to enter"
> >>=20
> >=20
> > Exactly.
> >=20
> >> The message is therefore appropriately timed as far as I'm =
concerned.
> >>=20
> >=20
> > It's not.
> >=20
> > Please test: create a bridge with STP disabled, add an interface to =
the
> > bridge and set that interface down. You get the message "... =
entering
> > forwarding state". That's wrong because it's "about to enter" =
disabled
> > state some lines later.
> >=20
> > All other (4) calls to br_log_state are located after the state =
change,
> > see for example br_stp_enable_port() just some lines above the =
patch.
>=20
> I would never expect an "entering" message to print out after the =
event
> happens, and in fact I'd _always_ want to see it beforehand so that if
> the state change caused a crash or similar it'd be that much easier
> to pinpoint the proper location.
>=20

OK. I see what you mean.

Proposal 1 (simple):=20
- Modify log message to "Entered xxx state"
- Apply patch
- Do not touch other br_log_message calls.

Proposal 2 (more complicated):
Add parameter "newstate" to br_log_message and put br_log_message before
the state change. Print log message only if new state !=3D current =
state.

Advantage: Reduces log spam when STP is disabled. After the last
modifications to the bridge code which force "forwarding" state if STP
is disabled, you get lots of bogus messages "entering forwarding state":

Event                    old message      new message
link up                  learning         forwarding
forwarding delay expired forwarding       forwarding
interface down           disabled         forwarding
link down                disabled         forwarding =20

If you accept one of the proposals, I'll prepare a patch. Otherwise, we
keep my original patch in our local tree.

> I'm still not applying this.  If the other log messages behave
> differently, they are broken, so go fix those instead.

Regards,
Wolfgang

--=20
"I love deadlines. I like the whooshing sound they make as they fly by"
(Douglas Adams)
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
KEYMILE GmbH       mailto:wolfgang.fritz@keymile.com
Wolfgang Fritz     Phone: +49 (0)511 6747-692
Wohlenbergstr. 3   Fax:   +49 (0)511 6747-777
D-30179 Hannover   http://www.keymile.com

Managing Directors: Bj=F6rn Claa=DFen, Dipl.-Kfm. Andreas Gebauer
Legal structure: GmbH, Registered office: Hanover, HRB 61069=20
Local court Hanover, VAT-Reg.-No.: DE 812282795,=20
WEEE-Reg.-No.: DE 59336750

------_=_NextPart_001_01CCA2AD.4F9473E6
Content-Type: text/html;
	charset="ISO-8859-15"
Content-Transfer-Encoding: quoted-printable

<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 3.2//EN">
<HTML>
<HEAD>
<META HTTP-EQUIV=3D"Content-Type" CONTENT=3D"text/html; =
charset=3Diso-8859-15">
<META NAME=3D"Generator" CONTENT=3D"MS Exchange Server version =
6.5.7651.59">
<TITLE>Re: [PATCH] net, bridge: print log message after state =
changed</TITLE>
</HEAD>
<BODY>
<!-- Converted from text/plain format -->
<BR>

<P><FONT SIZE=3D2>Am Montag, den 14.11.2011, 02:07 -0500 schrieb David =
Miller:<BR>
&gt; From: &quot;Fritz, Wolfgang&quot; =
&lt;Wolfgang.Fritz@keymile.com&gt;<BR>
&gt; Date: Mon, 14 Nov 2011 08:03:31 +0100<BR>
&gt;<BR>
&gt; &gt;<BR>
&gt; &gt; Am Montag, den 14.11.2011, 00:37 -0500 schrieb David =
Miller:<BR>
&gt; &gt;&gt; From: Holger Brunck &lt;holger.brunck@keymile.com&gt;<BR>
&gt; &gt;&gt; Date: Thu, 10 Nov 2011 17:18:54 +0100<BR>
&gt; &gt;&gt;<BR>
&gt; &gt;&gt; &gt; From: Wolfgang Fritz =
&lt;wolfgang.fritz@keymile.com&gt;<BR>
&gt; &gt;&gt; &gt;<BR>
&gt; &gt;&gt; &gt; Function br_log_state writes log message &quot;... =
entering XXXX state&quot; so it<BR>
&gt; &gt;&gt; &gt; should be called after the state has changed and not =
before.<BR>
&gt; &gt;&gt; &gt;<BR>
&gt; &gt;&gt; &gt; Signed-off-by: Wolfgang Fritz =
&lt;wolfgang.fritz@keymile.com&gt;<BR>
&gt; &gt;&gt; &gt; Signed-off-by: Holger Brunck =
&lt;holger.brunck@keymile.com&gt;<BR>
&gt; &gt;&gt;<BR>
&gt; &gt;&gt; &quot;entering&quot; can roughly mean &quot;about to =
enter&quot;<BR>
&gt; &gt;&gt;<BR>
&gt; &gt;<BR>
&gt; &gt; Exactly.<BR>
&gt; &gt;<BR>
&gt; &gt;&gt; The message is therefore appropriately timed as far as I'm =
concerned.<BR>
&gt; &gt;&gt;<BR>
&gt; &gt;<BR>
&gt; &gt; It's not.<BR>
&gt; &gt;<BR>
&gt; &gt; Please test: create a bridge with STP disabled, add an =
interface to the<BR>
&gt; &gt; bridge and set that interface down. You get the message =
&quot;... entering<BR>
&gt; &gt; forwarding state&quot;. That's wrong because it's &quot;about =
to enter&quot; disabled<BR>
&gt; &gt; state some lines later.<BR>
&gt; &gt;<BR>
&gt; &gt; All other (4) calls to br_log_state are located after the =
state change,<BR>
&gt; &gt; see for example br_stp_enable_port() just some lines above the =
patch.<BR>
&gt;<BR>
&gt; I would never expect an &quot;entering&quot; message to print out =
after the event<BR>
&gt; happens, and in fact I'd _always_ want to see it beforehand so that =
if<BR>
&gt; the state change caused a crash or similar it'd be that much =
easier<BR>
&gt; to pinpoint the proper location.<BR>
&gt;<BR>
<BR>
OK. I see what you mean.<BR>
<BR>
Proposal 1 (simple):<BR>
- Modify log message to &quot;Entered xxx state&quot;<BR>
- Apply patch<BR>
- Do not touch other br_log_message calls.<BR>
<BR>
Proposal 2 (more complicated):<BR>
Add parameter &quot;newstate&quot; to br_log_message and put =
br_log_message before<BR>
the state change. Print log message only if new state !=3D current =
state.<BR>
<BR>
Advantage: Reduces log spam when STP is disabled. After the last<BR>
modifications to the bridge code which force &quot;forwarding&quot; =
state if STP<BR>
is disabled, you get lots of bogus messages &quot;entering forwarding =
state&quot;:<BR>
<BR>
Event&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&n=
bsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; old =
message&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; new message<BR>
link =
up&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp=
;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; =
learning&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; forwarding<BR>
forwarding delay expired forwarding&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; =
forwarding<BR>
interface =
down&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; =
disabled&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; forwarding<BR>
link =
down&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nb=
sp;&nbsp;&nbsp;&nbsp; =
disabled&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; =
forwarding&nbsp;<BR>
<BR>
If you accept one of the proposals, I'll prepare a patch. Otherwise, =
we<BR>
keep my original patch in our local tree.<BR>
<BR>
&gt; I'm still not applying this.&nbsp; If the other log messages =
behave<BR>
&gt; differently, they are broken, so go fix those instead.<BR>
<BR>
Regards,<BR>
Wolfgang<BR>
<BR>
--<BR>
&quot;I love deadlines. I like the whooshing sound they make as they fly =
by&quot;<BR>
(Douglas Adams)<BR>
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D<BR>
KEYMILE GmbH&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; <A =
HREF=3D"mailto:wolfgang.fritz@keymile.com">mailto:wolfgang.fritz@keymile.=
com</A><BR>
Wolfgang Fritz&nbsp;&nbsp;&nbsp;&nbsp; Phone: +49 (0)511 6747-692<BR>
Wohlenbergstr. 3&nbsp;&nbsp; Fax:&nbsp;&nbsp; +49 (0)511 6747-777<BR>
D-30179 Hannover&nbsp;&nbsp; <A =
HREF=3D"http://www.keymile.com">http://www.keymile.com</A><BR>
<BR>
Managing Directors: Bj=F6rn Claa=DFen, Dipl.-Kfm. Andreas Gebauer<BR>
Legal structure: GmbH, Registered office: Hanover, HRB 61069<BR>
Local court Hanover, VAT-Reg.-No.: DE 812282795,<BR>
WEEE-Reg.-No.: DE 59336750<BR>
</FONT>
</P>

</BODY>
</HTML>
------_=_NextPart_001_01CCA2AD.4F9473E6--

--===============2647726476093602713==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
Bridge mailing list
Bridge@lists.linux-foundation.org
https://lists.linuxfoundation.org/mailman/listinfo/bridge
--===============2647726476093602713==--
