From: AndyLiebman@aol.com
Subject: Re: Frequent Oops on Shutdown 2.6.10
Date: Wed, 23 Feb 2005 09:51:44 EST
Message-ID: <b9.522b6602.2f4df280@aol.com>
Mime-Version: 1.0
Content-Type: multipart/alternative; boundary="-----------------------------1109170304"
Cc: terryg@axian.com, netdev@oss.sgi.com, davem@davemloft.net, akpm@osdl.org,
        AndyLiebman@aol.com
To: herbert@gondor.apana.org.au, yoshfuji@linux-ipv6.org
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


-------------------------------1109170304
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit

 
Hello, Yoshi
 
Should I bother to apply this patch, or should I wait for you to make this  
last change? What did you think about my comment that the Oops only occurred  
when the Ethernet cable had been unplugged during operation? 
 
Regards, 
Andy Liebman

On Wed,  Feb 23, 2005 at 06:35:55PM +0900, YOSHIFUJI Hideaki / ?$B5HF#1QL@  
wrote:
> 
> What do you think of this?

Thanks, this looks  great.  There is just one technical detail
to patch up.

>  -int snmp6_unregister_dev(struct inet6_dev *idev)
> +int  snmp6_free_dev(struct inet6_dev *idev)
>  {
>     snmp6_mib_free((void **)idev->stats.icmpv6);
>     return 0;
>  }

You need to check whether icmpv6[0] is  NULL either here or in
snmp6_mib_free.  Otherwise when snmp6_alloc_dev  fails we'll
wind up here and then call free_percpu on a pair of NULL  pointers.

Cheers,
-- 
Visit Openswan at  http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~}  <herbert@gondor.apana.org.au>
Home Page:  http://gondor.apana.org.au/~herbert/
PGP Key:  http://gondor.apana.org.au/~herbert/pubkey.txt





-------------------------------1109170304
Content-Type: text/html; charset="US-ASCII"
Content-Transfer-Encoding: quoted-printable

<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.0 Transitional//EN">
<HTML><HEAD>
<META http-equiv=3DContent-Type content=3D"text/html; charset=3DUS-ASCII">
<META content=3D"MSHTML 6.00.2900.2180" name=3DGENERATOR></HEAD>
<BODY id=3Drole_body style=3D"FONT-SIZE: 10pt; COLOR: #000000; FONT-FAMILY:=20=
Arial"=20
bottomMargin=3D7 leftMargin=3D7 topMargin=3D7 rightMargin=3D7><FONT id=3Drol=
e_document=20
face=3DArial color=3D#000000 size=3D2>
<DIV>
<DIV>Hello, Yoshi</DIV>
<DIV>&nbsp;</DIV>
<DIV>Should I bother to apply this patch, or should I wait for you to make t=
his=20
last change? What did you think about my comment that the Oops only occurred=
=20
when the Ethernet cable had been unplugged during operation? </DIV>
<DIV>&nbsp;</DIV>
<DIV>Regards, </DIV>
<DIV>Andy Liebman</DIV>
<BLOCKQUOTE=20
style=3D"PADDING-LEFT: 5px; MARGIN-LEFT: 5px; BORDER-LEFT: blue 2px solid"><=
FONT=20
  style=3D"BACKGROUND-COLOR: transparent" face=3DArial color=3D#000000 size=
=3D2>On Wed,=20
  Feb 23, 2005 at 06:35:55PM +0900, YOSHIFUJI Hideaki / ?$B5HF#1QL@=20
  wrote:<BR>&gt; <BR>&gt; What do you think of this?<BR><BR>Thanks, this loo=
ks=20
  great.&nbsp; There is just one technical detail<BR>to patch up.<BR><BR>&gt=
;=20
  -int snmp6_unregister_dev(struct inet6_dev *idev)<BR>&gt; +int=20
  snmp6_free_dev(struct inet6_dev *idev)<BR>&gt;&nbsp; {<BR>&gt;&nbsp; &nbsp=
;=20
  &nbsp; snmp6_mib_free((void **)idev-&gt;stats.icmpv6);<BR>&gt;&nbsp; &nbsp=
;=20
  &nbsp; return 0;<BR>&gt;&nbsp; }<BR><BR>You need to check whether icmpv6[0=
] is=20
  NULL either here or in<BR>snmp6_mib_free.&nbsp; Otherwise when snmp6_alloc=
_dev=20
  fails we'll<BR>wind up here and then call free_percpu on a pair of NULL=20
  pointers.<BR><BR>Cheers,<BR>-- <BR>Visit Openswan at=20
  http://www.openswan.org/<BR>Email: Herbert Xu ~{PmV&gt;HI~}=20
  &lt;herbert@gondor.apana.org.au&gt;<BR>Home Page:=20
  http://gondor.apana.org.au/~herbert/<BR>PGP Key:=20
  http://gondor.apana.org.au/~herbert/pubkey.txt<BR></FONT></BLOCKQUOTE></DI=
V>
<DIV></DIV>
<DIV>&nbsp;</DIV></FONT></BODY></HTML>

-------------------------------1109170304--
