From: "Prashant Batra (prbatra)" <prbatra-FYB4Gu1CFyUAvxtiuMwx3w@public.gmane.org>
Subject: Re: ipsec tunnel with different inner and outer
	ip families
Date: Fri, 13 Jan 2012 14:10:02 +0530
Message-ID: <B97B134FACB2024DB45F524AB0A7B7F2058AF9A6@XMB-BGL-419.cisco.com>
References: <B97B134FACB2024DB45F524AB0A7B7F2058AF974@XMB-BGL-419.cisco.com>
	<4F0FDCF2.6030802@alzatex.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="===============5268569514250055301=="
Cc: ipsec-tools-devel-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: "Loren M. Lang" <lorenl-/TqMqfqZm+BBDgjK7y7TUQ@public.gmane.org>
Return-path: <ipsec-tools-devel-bounces-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org>
Content-class: urn:content-classes:message
In-Reply-To: <4F0FDCF2.6030802-/TqMqfqZm+BBDgjK7y7TUQ@public.gmane.org>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/ipsec-tools-devel>,
	<mailto:ipsec-tools-devel-request-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=ipsec-tools-devel>
List-Post: <mailto:ipsec-tools-devel-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org>
List-Help: <mailto:ipsec-tools-devel-request-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/ipsec-tools-devel>,
	<mailto:ipsec-tools-devel-request-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org?subject=subscribe>
Errors-To: ipsec-tools-devel-bounces-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.

--===============5268569514250055301==
Content-class: urn:content-classes:message
Content-Type: multipart/alternative;
	boundary="----_=_NextPart_001_01CCD1CE.F1B6A1DC"

This is a multi-part message in MIME format.

------_=_NextPart_001_01CCD1CE.F1B6A1DC
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: quoted-printable

Thanks,=20

=20

But  even v6 in v4 doesn't seem to work with NETLINK XFRM interface.

=20

Regards,

Prashant

=20

From: Loren M. Lang [mailto:lorenl-/TqMqfqZm+BBDgjK7y7TUQ@public.gmane.org]=20
Sent: Friday, January 13, 2012 12:58 PM
To: Prashant Batra (prbatra)
Cc: ipsec-tools-devel-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org; netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Subject: Re: [Ipsec-tools-devel] ipsec tunnel with different inner and
outer ip families

=20

On 1/12/2012 11:11 PM, Prashant Batra (prbatra) wrote:=20

Hello,

=20

Does linux 2.6.* support an IPSec tunnel with different family of inner
and outer addresses , like v4 in v6 or v6 in v4.

After trying ip xfrm * from user space, the utility doesn't seem to
accept two different families in a single command.


Yes, I've done this in the past, but I took a different approach.  If I
recall correctly, I use IPSec in tunnel mode to tunnel IPv6 inside ESP
running over IPv4.  I haven't used ip xfrm before, but I did it with
setkey and /etc/ipsec.conf with lines like the following:

spdadd 192.168.1.1 192.168.2.1 ipv6 -P in ipsec esp/transport//require;
spdadd 192.168.2.1 192.168.1.1 ipv6 -P out ipsec esp/transport//require;

Unfortunately, I'm not in a state to test this right now.



=20

#ip xfrm policy add dir out src 172.168.68.1/32 dst 172.168.68.2/32 tmpl
src 2001:db8:0:242::36/128 dst 2001:db8:0:242::37/128 proto esp  mode
tunnel

Error: an inet prefix is expected rather than "2001:db8:0:242::36/128".

=20

So, I tried sending a NETLINK SPD add message) from user space with,
selector as v4 addresses and tmpl as v6 address.

Policy got added but kernel doesn't seem to be interpreting the
addresses correctly.

=20

src 172.16.80.1/32 dst 0.0.0.0/0

        dir out priority 1024

        tmpl    src 32.1.13.184 dst 32.1.13.184   /* I gave ipv6
addresses here*/

                proto esp spi 0x00000000 reqid 0 mode tunnel

=20

Can someone help me with this?

=20

Regards,

Prashant.






------------------------------------------------------------------------
------
RSA(R) Conference 2012
Mar 27 - Feb 2
Save $400 by Jan. 27
Register now!
http://p.sf.net/sfu/rsa-sfdev2dev2






_______________________________________________
Ipsec-tools-devel mailing list
Ipsec-tools-devel-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org
https://lists.sourceforge.net/lists/listinfo/ipsec-tools-devel






--=20
Loren M. Lang
lorenl-/TqMqfqZm+BBDgjK7y7TUQ@public.gmane.org
http://www.alzatex.com/
=20
=20
Public Key: ftp://ftp.tallye.com/pub/lorenl_pubkey.asc
Fingerprint: 10A0 7AE2 DAF5 4780 888A  3FA4 DCEE BB39 7654 DE5B

------_=_NextPart_001_01CCD1CE.F1B6A1DC
Content-Type: text/html;
	charset="us-ascii"
Content-Transfer-Encoding: quoted-printable

<html xmlns:v=3D"urn:schemas-microsoft-com:vml" =
xmlns:o=3D"urn:schemas-microsoft-com:office:office" =
xmlns:w=3D"urn:schemas-microsoft-com:office:word" =
xmlns:m=3D"http://schemas.microsoft.com/office/2004/12/omml" =
xmlns=3D"http://www.w3.org/TR/REC-html40">

<head>
<meta http-equiv=3DContent-Type content=3D"text/html; =
charset=3Dus-ascii">
<meta name=3DGenerator content=3D"Microsoft Word 12 (filtered medium)">
<style>
<!--
 /* Font Definitions */
 @font-face
	{font-family:"Cambria Math";
	panose-1:2 4 5 3 5 4 6 3 2 4;}
@font-face
	{font-family:Calibri;
	panose-1:2 15 5 2 2 2 4 3 2 4;}
@font-face
	{font-family:Tahoma;
	panose-1:2 11 6 4 3 5 4 4 2 4;}
@font-face
	{font-family:Consolas;
	panose-1:2 11 6 9 2 2 4 3 2 4;}
 /* Style Definitions */
 p.MsoNormal, li.MsoNormal, div.MsoNormal
	{margin:0in;
	margin-bottom:.0001pt;
	font-size:11.0pt;
	font-family:"Calibri","sans-serif";
	color:black;}
a:link, span.MsoHyperlink
	{mso-style-priority:99;
	color:blue;
	text-decoration:underline;}
a:visited, span.MsoHyperlinkFollowed
	{mso-style-priority:99;
	color:purple;
	text-decoration:underline;}
pre
	{mso-style-priority:99;
	mso-style-link:"HTML Preformatted Char";
	margin:0in;
	margin-bottom:.0001pt;
	font-size:10.0pt;
	font-family:"Courier New";
	color:black;}
span.EmailStyle17
	{mso-style-type:personal;
	font-family:"Calibri","sans-serif";
	color:windowtext;}
span.HTMLPreformattedChar
	{mso-style-name:"HTML Preformatted Char";
	mso-style-priority:99;
	mso-style-link:"HTML Preformatted";
	font-family:Consolas;
	color:black;}
span.EmailStyle20
	{mso-style-type:personal-reply;
	font-family:"Calibri","sans-serif";
	color:#1F497D;}
.MsoChpDefault
	{mso-style-type:export-only;
	font-size:10.0pt;}
@page Section1
	{size:8.5in 11.0in;
	margin:1.0in 1.0in 1.0in 1.0in;}
div.Section1
	{page:Section1;}
-->
</style>
<!--[if gte mso 9]><xml>
 <o:shapedefaults v:ext=3D"edit" spidmax=3D"1026" />
</xml><![endif]--><!--[if gte mso 9]><xml>
 <o:shapelayout v:ext=3D"edit">
  <o:idmap v:ext=3D"edit" data=3D"1" />
 </o:shapelayout></xml><![endif]-->
</head>

<body bgcolor=3Dwhite lang=3DEN-US link=3Dblue vlink=3Dpurple>

<div class=3DSection1>

<p class=3DMsoNormal><span style=3D'color:#1F497D'>Thanks, =
<o:p></o:p></span></p>

<p class=3DMsoNormal><span =
style=3D'color:#1F497D'><o:p>&nbsp;</o:p></span></p>

<p class=3DMsoNormal><span style=3D'color:#1F497D'>But&nbsp; even v6 in =
v4 doesn&#8217;t
seem to work with NETLINK XFRM interface.<o:p></o:p></span></p>

<p class=3DMsoNormal><span =
style=3D'color:#1F497D'><o:p>&nbsp;</o:p></span></p>

<p class=3DMsoNormal><span =
style=3D'color:#1F497D'>Regards,<o:p></o:p></span></p>

<p class=3DMsoNormal><span =
style=3D'color:#1F497D'>Prashant<o:p></o:p></span></p>

<p class=3DMsoNormal><span =
style=3D'color:#1F497D'><o:p>&nbsp;</o:p></span></p>

<div>

<div style=3D'border:none;border-top:solid #B5C4DF 1.0pt;padding:3.0pt =
0in 0in 0in'>

<p class=3DMsoNormal><b><span =
style=3D'font-size:10.0pt;font-family:"Tahoma","sans-serif";
color:windowtext'>From:</span></b><span =
style=3D'font-size:10.0pt;font-family:
"Tahoma","sans-serif";color:windowtext'> Loren M. Lang
[mailto:lorenl-/TqMqfqZm+BBDgjK7y7TUQ@public.gmane.org] <br>
<b>Sent:</b> Friday, January 13, 2012 12:58 PM<br>
<b>To:</b> Prashant Batra (prbatra)<br>
<b>Cc:</b> ipsec-tools-devel-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org; =
netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org<br>
<b>Subject:</b> Re: [Ipsec-tools-devel] ipsec tunnel with different =
inner and
outer ip families<o:p></o:p></span></p>

</div>

</div>

<p class=3DMsoNormal><o:p>&nbsp;</o:p></p>

<p class=3DMsoNormal>On 1/12/2012 11:11 PM, Prashant Batra (prbatra) =
wrote: <o:p></o:p></p>

<p class=3DMsoNormal>Hello,<o:p></o:p></p>

<p class=3DMsoNormal>&nbsp;<o:p></o:p></p>

<p class=3DMsoNormal>Does linux 2.6.* support an IPSec tunnel with =
different
family of inner and outer addresses , like v4 in v6 or v6 in =
v4.<o:p></o:p></p>

<p class=3DMsoNormal>After trying ip xfrm * from user space, the utility
doesn&#8217;t seem to accept two different families in a single =
command.<o:p></o:p></p>

<p class=3DMsoNormal><span style=3D'font-size:12.0pt;font-family:"Times =
New Roman","serif"'><br>
Yes, I've done this in the past, but I took a different approach.&nbsp; =
If I
recall correctly, I use IPSec in tunnel mode to tunnel IPv6 inside ESP =
running
over IPv4.&nbsp; I haven't used ip xfrm before, but I did it with setkey =
and
/etc/ipsec.conf with lines like the following:<br>
<br>
spdadd 192.168.1.1 192.168.2.1 ipv6 -P in ipsec =
esp/transport//require;<br>
spdadd 192.168.2.1 192.168.1.1 ipv6 -P out ipsec =
esp/transport//require;<br>
<br>
Unfortunately, I'm not in a state to test this right now.<br>
<br>
<o:p></o:p></span></p>

<p class=3DMsoNormal>&nbsp;<o:p></o:p></p>

<p class=3DMsoNormal>#ip xfrm policy add dir out src 172.168.68.1/32 dst
172.168.68.2/32 tmpl src 2001:db8:0:242::36/128 dst =
2001:db8:0:242::37/128
proto esp&nbsp; mode tunnel<o:p></o:p></p>

<p class=3DMsoNormal>Error: an inet prefix is expected rather than
&quot;2001:db8:0:242::36/128&quot;.<o:p></o:p></p>

<p class=3DMsoNormal>&nbsp;<o:p></o:p></p>

<p class=3DMsoNormal>So, I tried sending a NETLINK SPD add message) from =
user
space with, selector as v4 addresses and tmpl as v6 =
address.<o:p></o:p></p>

<p class=3DMsoNormal>Policy got added but kernel doesn&#8217;t seem to =
be
interpreting the addresses correctly.<o:p></o:p></p>

<p class=3DMsoNormal>&nbsp;<o:p></o:p></p>

<p class=3DMsoNormal>src 172.16.80.1/32 dst 0.0.0.0/0<o:p></o:p></p>

<p class=3DMsoNormal>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; dir out =
priority
1024<o:p></o:p></p>

<p class=3DMsoNormal>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
tmpl&nbsp;&nbsp;&nbsp; src 32.1.13.184 dst 32.1.13.184&nbsp;&nbsp; /* I =
gave
ipv6 addresses here*/<o:p></o:p></p>

<p =
class=3DMsoNormal>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&=
nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
proto esp spi 0x00000000 reqid 0 mode tunnel<o:p></o:p></p>

<p class=3DMsoNormal>&nbsp;<o:p></o:p></p>

<p class=3DMsoNormal>Can someone help me with this?<o:p></o:p></p>

<p class=3DMsoNormal>&nbsp;<o:p></o:p></p>

<p class=3DMsoNormal>Regards,<o:p></o:p></p>

<p class=3DMsoNormal>Prashant.<o:p></o:p></p>

<p class=3DMsoNormal><span style=3D'font-size:12.0pt;font-family:"Times =
New Roman","serif"'><br>
<br>
<br>
<o:p></o:p></span></p>

<pre>--------------------------------------------------------------------=
----------<o:p></o:p></pre><pre>RSA(R) Conference =
2012<o:p></o:p></pre><pre>Mar 27 - Feb 2<o:p></o:p></pre><pre>Save $400 =
by Jan. 27<o:p></o:p></pre><pre>Register now!<o:p></o:p></pre><pre><a
href=3D"http://p.sf.net/sfu/rsa-sfdev2dev2">http://p.sf.net/sfu/rsa-sfdev=
2dev2</a><o:p></o:p></pre>

<p class=3DMsoNormal><span style=3D'font-size:12.0pt;font-family:"Times =
New Roman","serif"'><br>
<br>
<br>
<o:p></o:p></span></p>

<pre>_______________________________________________<o:p></o:p></pre><pre=
>Ipsec-tools-devel mailing list<o:p></o:p></pre><pre><a
href=3D"mailto:Ipsec-tools-devel-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org">Ipsec-tools-devel=
@lists.sourceforge.net</a><o:p></o:p></pre><pre><a
href=3D"https://lists.sourceforge.net/lists/listinfo/ipsec-tools-devel">h=
ttps://lists.sourceforge.net/lists/listinfo/ipsec-tools-devel</a><o:p></o=
:p></pre>

<p class=3DMsoNormal><span style=3D'font-size:12.0pt;font-family:"Times =
New Roman","serif"'><br>
<br>
<br>
<o:p></o:p></span></p>

<pre>-- <o:p></o:p></pre><pre>Loren M. Lang<o:p></o:p></pre><pre><a
href=3D"mailto:lorenl-/TqMqfqZm+BBDgjK7y7TUQ@public.gmane.org">lorenl-/TqMqfqZm+BBDgjK7y7TUQ@public.gmane.org</a><o:p></o:p></pre=
><pre><a
href=3D"http://www.alzatex.com/">http://www.alzatex.com/</a><o:p></o:p></=
pre><pre><o:p>&nbsp;</o:p></pre><pre><o:p>&nbsp;</o:p></pre><pre>Public =
Key: <a
href=3D"ftp://ftp.tallye.com/pub/lorenl_pubkey.asc">ftp://ftp.tallye.com/=
pub/lorenl_pubkey.asc</a><o:p></o:p></pre><pre>Fingerprint: 10A0 7AE2 =
DAF5 4780 888A&nbsp; 3FA4 DCEE BB39 7654 DE5B<o:p></o:p></pre></div>

</body>

</html>

------_=_NextPart_001_01CCD1CE.F1B6A1DC--


--===============5268569514250055301==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

------------------------------------------------------------------------------
RSA(R) Conference 2012
Mar 27 - Feb 2
Save $400 by Jan. 27
Register now!
http://p.sf.net/sfu/rsa-sfdev2dev2
--===============5268569514250055301==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline


--===============5268569514250055301==--
