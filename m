From: Nicholas Bastin <nick.bastin-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: [ovs-discuss] kernel panic receiving flooded VXLAN traffic with
	OVS
Date: Sat, 6 Dec 2014 12:47:59 -1000
Message-ID: <CADmMkWdGhw3Rn3gMEtAV8ESZB-k+uAK=Ed=LwsShKOtyHdJS_g@mail.gmail.com>
References: <19014.1415325508@famine> <8549.1417657547@famine>
 <CAEP_g=_mfSCH1250ezx_h8_yM_4FzsYcsS6EnGi99AFoWO_MKw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="===============6854475129961503547=="
Cc: "discuss-yBygre7rU0TnMu66kgdUjQ@public.gmane.org" <discuss-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>,
 netdev <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: Jesse Gross <jesse-l0M0P4e3n4LQT0dZR+AlfA@public.gmane.org>
Return-path: <discuss-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>
In-Reply-To: <CAEP_g=_mfSCH1250ezx_h8_yM_4FzsYcsS6EnGi99AFoWO_MKw-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
List-Unsubscribe: <http://openvswitch.org/mailman/options/discuss>,
 <mailto:discuss-request-yBygre7rU0TnMu66kgdUjQ@public.gmane.org?subject=unsubscribe>
List-Archive: <http://openvswitch.org/pipermail/discuss>
List-Post: <mailto:discuss-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>
List-Help: <mailto:discuss-request-yBygre7rU0TnMu66kgdUjQ@public.gmane.org?subject=help>
List-Subscribe: <http://openvswitch.org/mailman/listinfo/discuss>,
 <mailto:discuss-request-yBygre7rU0TnMu66kgdUjQ@public.gmane.org?subject=subscribe>
Errors-To: discuss-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org
Sender: "discuss" <discuss-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>
List-Id: netdev.vger.kernel.org

--===============6854475129961503547==
Content-Type: multipart/alternative; boundary=001a11c2b44031e092050993fc72

--001a11c2b44031e092050993fc72
Content-Type: text/plain; charset=UTF-8

On Fri, Dec 5, 2014 at 4:51 PM, Jesse Gross <jesse-l0M0P4e3n4LQT0dZR+AlfA@public.gmane.org> wrote:

> I don't think there is anything inherently wrong with aggregating TCP
> segments in VXLAN that are not destined for the local host. This is
> conceptually the same as doing aggregation for TCP packets where we
> only perform L2 bridging - in theory we shouldn't look at the upper
> layers but it is fine as long as we faithfully reconstruct it on the
> way out.
>

But you don't faithfully reconstruct what the user originally sent -
in-path reassembly is always wrong, which is why hardware switches don't do
it (by default, anyhow).  If you configure a middlebox to do some kind of
assembly/translation/whatever work for you, that's fine, but something that
advertises itself as a "switch" or "router" should definitely not do this
by default.

If you reassemble frames you completely obviate any kind of PMTU-D or
configured MTU that your user is using, and this breaks a lot of paths.  We
completely disable all GRO/TSO/etc., but if you are able to determine that
a packet is not destined for the local host you should definitely not
mutate it.

--
Nick

--001a11c2b44031e092050993fc72
Content-Type: text/html; charset=UTF-8
Content-Transfer-Encoding: quoted-printable

<div dir=3D"ltr"><div class=3D"gmail_extra"><div class=3D"gmail_quote">On F=
ri, Dec 5, 2014 at 4:51 PM, Jesse Gross <span dir=3D"ltr">&lt;<a href=3D"ma=
ilto:jesse-l0M0P4e3n4LQT0dZR+AlfA@public.gmane.org" target=3D"_blank">jesse-l0M0P4e3n4LQT0dZR+AlfA@public.gmane.org</a>&gt;</span> wr=
ote:<br><blockquote class=3D"gmail_quote" style=3D"margin:0 0 0 .8ex;border=
-left:1px #ccc solid;padding-left:1ex"><div class=3D"HOEnZb"><div class=3D"=
h5"><span style=3D"color:rgb(34,34,34)">I don&#39;t think there is anything=
 inherently wrong with aggregating TCP</span><br></div></div>
segments in VXLAN that are not destined for the local host. This is<br>
conceptually the same as doing aggregation for TCP packets where we<br>
only perform L2 bridging - in theory we shouldn&#39;t look at the upper<br>
layers but it is fine as long as we faithfully reconstruct it on the<br>
way out.<br></blockquote><div><br></div><div>But you don&#39;t faithfully r=
econstruct what the user originally sent - in-path reassembly is always wro=
ng, which is why hardware switches don&#39;t do it (by default, anyhow).=C2=
=A0 If you configure a middlebox to do some kind of assembly/translation/wh=
atever work for you, that&#39;s fine, but something that advertises itself =
as a &quot;switch&quot; or &quot;router&quot; should definitely not do this=
 by default.</div><div><br></div><div>If you reassemble frames you complete=
ly obviate any kind of PMTU-D or configured MTU that your user is using, an=
d this breaks a lot of paths.=C2=A0 We completely disable all GRO/TSO/etc.,=
 but if you are able to determine that a packet is not destined for the loc=
al host you should definitely not mutate it.</div><div><br></div><div>--</d=
iv><div>Nick</div></div></div></div>

--001a11c2b44031e092050993fc72--

--===============6854475129961503547==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: base64
Content-Disposition: inline

X19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX18KZGlzY3VzcyBt
YWlsaW5nIGxpc3QKZGlzY3Vzc0BvcGVudnN3aXRjaC5vcmcKaHR0cDovL29wZW52c3dpdGNoLm9y
Zy9tYWlsbWFuL2xpc3RpbmZvL2Rpc2N1c3MK

--===============6854475129961503547==--
