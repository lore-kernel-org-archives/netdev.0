From: Rudresh NB <rudrii@gmail.com>
Subject: Re: [B.A.T.M.A.N.] [PATCH 1/2] bridge: multicast: call
 skb_checksum_{simple_, }validate
Date: Sun, 12 Apr 2015 19:08:02 +0530
Message-ID: <CAJNZDZaRzXhjqTDKAj5v5jCf1kmgOwLwpGf30MBgY23CmzQiTg@mail.gmail.com>
References: <1428687999-18428-1-git-send-email-linus.luessing@c0d3.blue>
Mime-Version: 1.0
Content-Type: multipart/alternative; boundary=001a113495004856360513871bf9
Cc: Herbert Xu <herbert@gondor.apana.org.au>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	netdev@vger.kernel.org, bridge@lists.linux-foundation.org,
	linux-kernel@vger.kernel.org, "David S. Miller" <davem@davemloft.net>,
	Tom Herbert <therbert@google.com>
To: The list for a Better Approach To Mobile Ad-hoc Networking
	<b.a.t.m.a.n@lists.open-mesh.org>
Return-path: <bridge-bounces@lists.linux-foundation.org>
In-Reply-To: <1428687999-18428-1-git-send-email-linus.luessing@c0d3.blue>
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

--001a113495004856360513871bf9
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable

Hi All,
            I am getting following message if i post to b.a.t.m.a.n@
lists.open-mesh.org. So I am mailing to this group.

Our wifi does not support adhoc mode. I am trying batman-adv setup on
managed mode.

Can anybody tell me the settings fro batman-adv in managed mode/STA mode?

Regards,
Rudresh

On 10 April 2015 at 23:16, Linus L=C3=BCssing <linus.luessing@c0d3.blue> wr=
ote:

> Let's use these new, neat helpers.
>
> Signed-off-by: Linus L=C3=BCssing <linus.luessing@c0d3.blue>
> ---
>  net/bridge/br_multicast.c |   28 ++++------------------------
>  1 file changed, 4 insertions(+), 24 deletions(-)
>
> diff --git a/net/bridge/br_multicast.c b/net/bridge/br_multicast.c
> index 4b6722f..b52f4cb 100644
> --- a/net/bridge/br_multicast.c
> +++ b/net/bridge/br_multicast.c
> @@ -1610,16 +1610,8 @@ static int br_multicast_ipv4_rcv(struct net_bridge
> *br,
>         if (!pskb_may_pull(skb2, sizeof(*ih)))
>                 goto out;
>
> -       switch (skb2->ip_summed) {
> -       case CHECKSUM_COMPLETE:
> -               if (!csum_fold(skb2->csum))
> -                       break;
> -               /* fall through */
> -       case CHECKSUM_NONE:
> -               skb2->csum =3D 0;
> -               if (skb_checksum_complete(skb2))
> -                       goto out;
> -       }
> +       if (skb_checksum_simple_validate(skb2))
> +               goto out;
>
>         err =3D 0;
>
> @@ -1737,20 +1729,8 @@ static int br_multicast_ipv6_rcv(struct net_bridge
> *br,
>
>         ip6h =3D ipv6_hdr(skb2);
>
> -       switch (skb2->ip_summed) {
> -       case CHECKSUM_COMPLETE:
> -               if (!csum_ipv6_magic(&ip6h->saddr, &ip6h->daddr, skb2->le=
n,
> -                                       IPPROTO_ICMPV6, skb2->csum))
> -                       break;
> -               /*FALLTHROUGH*/
> -       case CHECKSUM_NONE:
> -               skb2->csum =3D ~csum_unfold(csum_ipv6_magic(&ip6h->saddr,
> -                                                       &ip6h->daddr,
> -                                                       skb2->len,
> -                                                       IPPROTO_ICMPV6,
> 0));
> -               if (__skb_checksum_complete(skb2))
> -                       goto out;
> -       }
> +       if (skb_checksum_validate(skb2, IPPROTO_ICMPV6,
> ip6_compute_pseudo))
> +               goto out;
>
>         err =3D 0;
>
> --
> 1.7.10.4
>
>

--001a113495004856360513871bf9
Content-Type: text/html; charset=UTF-8
Content-Transfer-Encoding: quoted-printable

<div dir=3D"ltr">Hi All,<div>=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 I am=
 getting following message if i post to=C2=A0<span style=3D"color:rgb(119,1=
19,119);font-family:&#39;normal arial&#39;,sans-serif;font-size:12px">b.a.t=
.m.a.n</span><span style=3D"color:rgb(119,119,119);font-family:&#39;normal =
arial&#39;,sans-serif;font-size:12px">@<a href=3D"http://lists.open-mesh.or=
g">lists.open-mesh.org</a>. So I am mailing to this group.</span></div><div=
><span style=3D"color:rgb(119,119,119);font-family:&#39;normal arial&#39;,s=
ans-serif;font-size:12px"><br></span></div><div><font color=3D"#777777" fac=
e=3D"normal arial, sans-serif"><span style=3D"font-size:12px">Our wifi does=
 not support adhoc mode. I am trying batman-adv setup on managed mode.</spa=
n></font></div><div><font color=3D"#777777" face=3D"normal arial, sans-seri=
f"><span style=3D"font-size:12px"><br></span></font></div><div><font color=
=3D"#777777" face=3D"normal arial, sans-serif"><span style=3D"font-size:12p=
x">Can anybody tell me the settings fro batman-adv in managed mode/STA mode=
?</span></font></div><div><font color=3D"#777777" face=3D"normal arial, san=
s-serif"><span style=3D"font-size:12px"><br></span></font></div><div><font =
color=3D"#777777" face=3D"normal arial, sans-serif"><span style=3D"font-siz=
e:12px">Regards,</span></font></div><div><font color=3D"#777777" face=3D"no=
rmal arial, sans-serif"><span style=3D"font-size:12px">Rudresh</span></font=
></div></div><div class=3D"gmail_extra"><br><div class=3D"gmail_quote">On 1=
0 April 2015 at 23:16, Linus L=C3=BCssing <span dir=3D"ltr">&lt;<a href=3D"=
mailto:linus.luessing@c0d3.blue" target=3D"_blank">linus.luessing@c0d3.blue=
</a>&gt;</span> wrote:<br><blockquote class=3D"gmail_quote" style=3D"margin=
:0 0 0 .8ex;border-left:1px #ccc solid;padding-left:1ex">Let&#39;s use thes=
e new, neat helpers.<br>
<br>
Signed-off-by: Linus L=C3=BCssing &lt;linus.luessing@c0d3.blue&gt;<br>
---<br>
=C2=A0net/bridge/br_multicast.c |=C2=A0 =C2=A028 ++++----------------------=
--<br>
=C2=A01 file changed, 4 insertions(+), 24 deletions(-)<br>
<br>
diff --git a/net/bridge/br_multicast.c b/net/bridge/br_multicast.c<br>
index 4b6722f..b52f4cb 100644<br>
--- a/net/bridge/br_multicast.c<br>
+++ b/net/bridge/br_multicast.c<br>
@@ -1610,16 +1610,8 @@ static int br_multicast_ipv4_rcv(struct net_bridge *=
br,<br>
=C2=A0 =C2=A0 =C2=A0 =C2=A0 if (!pskb_may_pull(skb2, sizeof(*ih)))<br>
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 goto out;<br>
<br>
-=C2=A0 =C2=A0 =C2=A0 =C2=A0switch (skb2-&gt;ip_summed) {<br>
-=C2=A0 =C2=A0 =C2=A0 =C2=A0case CHECKSUM_COMPLETE:<br>
-=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0if (!csum_fold(skb2=
-&gt;csum))<br>
-=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0break;<br>
-=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0/* fall through */<=
br>
-=C2=A0 =C2=A0 =C2=A0 =C2=A0case CHECKSUM_NONE:<br>
-=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0skb2-&gt;csum =3D 0=
;<br>
-=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0if (skb_checksum_co=
mplete(skb2))<br>
-=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0goto out;<br>
-=C2=A0 =C2=A0 =C2=A0 =C2=A0}<br>
+=C2=A0 =C2=A0 =C2=A0 =C2=A0if (skb_checksum_simple_validate(skb2))<br>
+=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0goto out;<br>
<br>
=C2=A0 =C2=A0 =C2=A0 =C2=A0 err =3D 0;<br>
<br>
@@ -1737,20 +1729,8 @@ static int br_multicast_ipv6_rcv(struct net_bridge *=
br,<br>
<br>
=C2=A0 =C2=A0 =C2=A0 =C2=A0 ip6h =3D ipv6_hdr(skb2);<br>
<br>
-=C2=A0 =C2=A0 =C2=A0 =C2=A0switch (skb2-&gt;ip_summed) {<br>
-=C2=A0 =C2=A0 =C2=A0 =C2=A0case CHECKSUM_COMPLETE:<br>
-=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0if (!csum_ipv6_magi=
c(&amp;ip6h-&gt;saddr, &amp;ip6h-&gt;daddr, skb2-&gt;len,<br>
-=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0IPPROTO_I=
CMPV6, skb2-&gt;csum))<br>
-=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0break;<br>
-=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0/*FALLTHROUGH*/<br>
-=C2=A0 =C2=A0 =C2=A0 =C2=A0case CHECKSUM_NONE:<br>
-=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0skb2-&gt;csum =3D ~=
csum_unfold(csum_ipv6_magic(&amp;ip6h-&gt;saddr,<br>
-=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0&amp;ip6h-&gt;daddr,<br>
-=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0skb2-&gt;len,<br>
-=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0IPPROTO_ICMPV6, 0));<br>
-=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0if (__skb_checksum_=
complete(skb2))<br>
-=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0goto out;<br>
-=C2=A0 =C2=A0 =C2=A0 =C2=A0}<br>
+=C2=A0 =C2=A0 =C2=A0 =C2=A0if (skb_checksum_validate(skb2, IPPROTO_ICMPV6,=
 ip6_compute_pseudo))<br>
+=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0goto out;<br>
<br>
=C2=A0 =C2=A0 =C2=A0 =C2=A0 err =3D 0;<br>
<span class=3D"HOEnZb"><font color=3D"#888888"><br>
--<br>
1.7.10.4<br>
<br>
</font></span></blockquote></div><br></div>

--001a113495004856360513871bf9--
