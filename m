From: Dave Taht <dave.taht-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: [PATCH] net_sched: htb: do not mix 1ns and 64ns time
	units
Date: Tue, 4 Jun 2013 13:26:09 -0700
Message-ID: <CAA93jw6BQ_Ji5zHxR93PPxAmAWg8VmRSYBFKTpJDFWE4MApaRg@mail.gmail.com>
References: <20130529151330.22c5c89e@redhat.com>
	<20130604141342.00c8eb9f@redhat.com>
	<1370359133.24311.208.camel@edumazet-glaptop>
	<1370361306.24311.214.camel@edumazet-glaptop>
	<1370361727.24311.215.camel@edumazet-glaptop>
	<1370365908.24311.222.camel@edumazet-glaptop>
	<20130604222135.67eedab8@redhat.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="===============6801637927995609329=="
Cc: =?ISO-8859-1?Q?Toke_H=F8iland=2DJ=F8rgensen?= <toke-LJ9M9ZcSy1A@public.gmane.org>,
	Mike Frysinger <vapier-aBrp7R+bbdUdnm+yROfE0A@public.gmane.org>,
	Jiri Pirko <jpirko-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	bloat-JXvr2/1DY2fm6VMwtOF2vx4hnT+Y9+D1@public.gmane.org, Jiri Benc <jbenc-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>,
	Patrick McHardy <kaber-dcUjhNyLwpNeoWH0uzbU5w@public.gmane.org>, Steven Barth <cyrus-p3rKhJxN3npAfugRpC6u6w@public.gmane.org>,
	David Miller <davem-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>,
	Jussi Kivilinna <jussi.kivilinna-E01nCVcF24I@public.gmane.org>,
	Felix Fietkau <nbd-Vt+b4OUoWG0@public.gmane.org>, Michal Soltys <soltys-R61QfzASbfY@public.gmane.org>
To: Jesper Dangaard Brouer <jbrouer-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Return-path: <bloat-bounces-JXvr2/1DY2fm6VMwtOF2vx4hnT+Y9+D1@public.gmane.org>
In-Reply-To: <20130604222135.67eedab8-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
List-Unsubscribe: <https://lists.bufferbloat.net/options/bloat>,
	<mailto:bloat-request-JXvr2/1DY2fm6VMwtOF2vx4hnT+Y9+D1@public.gmane.org?subject=unsubscribe>
List-Archive: <https://lists.bufferbloat.net/pipermail/bloat>
List-Post: <mailto:bloat-JXvr2/1DY2fm6VMwtOF2vx4hnT+Y9+D1@public.gmane.org>
List-Help: <mailto:bloat-request-JXvr2/1DY2fm6VMwtOF2vx4hnT+Y9+D1@public.gmane.org?subject=help>
List-Subscribe: <https://lists.bufferbloat.net/listinfo/bloat>,
	<mailto:bloat-request-JXvr2/1DY2fm6VMwtOF2vx4hnT+Y9+D1@public.gmane.org?subject=subscribe>
Sender: bloat-bounces-JXvr2/1DY2fm6VMwtOF2vx4hnT+Y9+D1@public.gmane.org
Errors-To: bloat-bounces-JXvr2/1DY2fm6VMwtOF2vx4hnT+Y9+D1@public.gmane.org
List-Id: netdev.vger.kernel.org

--===============6801637927995609329==
Content-Type: multipart/alternative; boundary=089e013cbdca39007204de59e484

--089e013cbdca39007204de59e484
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable

On Tue, Jun 4, 2013 at 1:21 PM, Jesper Dangaard Brouer
<jbrouer-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>wrote:

> On Tue, 04 Jun 2013 10:11:48 -0700
> Eric Dumazet <eric.dumazet-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org> wrote:
>
> > From: Eric Dumazet <edumazet-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
> >
> > commit 56b765b79 ("htb: improved accuracy at high rates") added
> > another regression for low rates, because it mixes 1ns and 64ns time
> > units.
> >
> > So the maximum delay (mbuffer) was not 60 second, but 937 ms.
> >
> > Lets convert all time fields to 1ns as 64bit arches are becoming the
> > norm.
>
> I'm of-cause happy as I need this fixed for big-HW machines at Red Hat.
>
> But how is this 64-bit usage going to affect performance for smaller
> ARM/MIPS based home routers, where shaping at these low rates is more
> relevant?  (I'm just asking because I don't know, and just test this
> on a 24-CPU machine).
>

I'm not worried about it but will find out shortly in cerowrt.

I take it this does not fix the DSL/ATM issue however?


>
> Tested-by: Jesper Dangaard Brouer <brouer-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
>
> I have tested you patch, and it works for me.
> Tested shaping at 100Kbit/s:
>  - max "rate 100656bit" on dev lo
>  - max "rate 102016bit" on a real  1 Gbit/s NIC (dev eth63).
>  - max "rate 103256bit" on a real 10 Gbit/s NIC (dev eth31).
>
> The traffic "of-cause" spikes due to the GSO frames, if measuring the
> traffic at a higher resolution (I've seen upto 3 sec without traffic).
>
> Thanks for the quick fix! :-)))
> --
> Best regards,
>   Jesper Dangaard Brouer
>   MSc.CS, Sr. Network Kernel Developer at Red Hat
>   Author of http://www.iptv-analyzer.org
>   LinkedIn: http://www.linkedin.com/in/brouer
>
> Reproducer commands:
>  tc qdisc add dev lo root handle 1: htb default 1
>  tc class add dev lo parent 1: classid 1:1 htb rate 100kbit
>  netserver
>  netperf -t TCP_STREAM -l 60 -H 127.0.0.1 -- -m 1024
>
> Measuring the qdisc "rate" via:
>  tc -s -d class show dev lo classid 1:1
>
> Data:
> =3D=3D=3D=3D=3D
> From dev "lo":
> --------------
> class htb 1:1 root prio 0 quantum 1250 rate 100000bit ceil 100000bit burs=
t
> 1600b/1 mpu 0b overhead 0b cburst 1600b/1 mpu 0b overhead 0b level 0
>  Sent 597719 bytes 64 pkt (dropped 942, overlimits 0 requeues 0)
>  rate 100656bit 1pps backlog 0b 1p requeues 0
>  lended: 64 borrowed: 0 giants: 0
>  tokens: -27387576 ctokens: -27387576
>
> From 1Gbit/s dev eth63:
> -----------------------
> class htb 1:1 root prio 0 quantum 1250 rate 100000bit ceil 100000bit burs=
t
> 1600b/1 mpu 0b overhead 0b cburst 1600b/1 mpu 0b overhead 0b level 0
>  Sent 1801152 bytes 3224 pkt (dropped 0, overlimits 0 requeues 0)
>  rate 102016bit 9pps backlog 0b 12p requeues 0
>  lended: 2284 borrowed: 0 giants: 0
>  tokens: -18923820 ctokens: -18923820
>
>
> From 10Gbit/s dev eth31:
> ------------------------
> class htb 1:1 root prio 0 quantum 1250 rate 100000bit ceil 100000bit burs=
t
> 1600b/1 mpu 0b overhead 0b cburst 1600b/1 mpu 0b overhead 0b level 0
>  Sent 855814 bytes 581 pkt (dropped 0, overlimits 0 requeues 0)
>  rate 103256bit 9pps backlog 0b 9p requeues 0
>  lended: 81 borrowed: 0 giants: 0
>  tokens: -45419150 ctokens: -45419150
>
>


--=20
Dave T=E4ht

Fixing bufferbloat with cerowrt:
http://www.teklibre.com/cerowrt/subscribe.html

--089e013cbdca39007204de59e484
Content-Type: text/html; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable

<br><br><div class=3D"gmail_quote">On Tue, Jun 4, 2013 at 1:21 PM, Jesper D=
angaard Brouer <span dir=3D"ltr">&lt;<a href=3D"mailto:jbrouer-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org" =
target=3D"_blank">jbrouer-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org</a>&gt;</span> wrote:<br><blockquote c=
lass=3D"gmail_quote" style=3D"margin:0 0 0 .8ex;border-left:1px #ccc solid;=
padding-left:1ex">
<div class=3D"im">On Tue, 04 Jun 2013 10:11:48 -0700<br>
Eric Dumazet &lt;<a href=3D"mailto:eric.dumazet-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org">eric.dumazet@gma=
il.com</a>&gt; wrote:<br>
<br>
&gt; From: Eric Dumazet &lt;<a href=3D"mailto:edumazet-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org">edumazet=
@google.com</a>&gt;<br>
&gt;<br>
&gt; commit 56b765b79 (&quot;htb: improved accuracy at high rates&quot;) ad=
ded<br>
&gt; another regression for low rates, because it mixes 1ns and 64ns time<b=
r>
&gt; units.<br>
&gt;<br>
&gt; So the maximum delay (mbuffer) was not 60 second, but 937 ms.<br>
&gt;<br>
&gt; Lets convert all time fields to 1ns as 64bit arches are becoming the<b=
r>
&gt; norm.<br>
<br>
</div>I&#39;m of-cause happy as I need this fixed for big-HW machines at Re=
d Hat.<br>
<br>
But how is this 64-bit usage going to affect performance for smaller<br>
ARM/MIPS based home routers, where shaping at these low rates is more<br>
relevant? =A0(I&#39;m just asking because I don&#39;t know, and just test t=
his<br>
on a 24-CPU machine).<br></blockquote><div><br>I&#39;m not worried about it=
 but will find out shortly in cerowrt.<br><br>I take it this does not fix t=
he DSL/ATM issue however?<br>=A0<br></div><blockquote class=3D"gmail_quote"=
 style=3D"margin:0 0 0 .8ex;border-left:1px #ccc solid;padding-left:1ex">

<br>
Tested-by: Jesper Dangaard Brouer &lt;<a href=3D"mailto:brouer-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org">=
brouer-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org</a>&gt;<br>
<br>
I have tested you patch, and it works for me.<br>
Tested shaping at 100Kbit/s:<br>
=A0- max &quot;rate 100656bit&quot; on dev lo<br>
=A0- max &quot;rate 102016bit&quot; on a real =A01 Gbit/s NIC (dev eth63).<=
br>
=A0- max &quot;rate 103256bit&quot; on a real 10 Gbit/s NIC (dev eth31).<br=
>
<br>
The traffic &quot;of-cause&quot; spikes due to the GSO frames, if measuring=
 the<br>
traffic at a higher resolution (I&#39;ve seen upto 3 sec without traffic).<=
br>
<br>
Thanks for the quick fix! :-)))<br>
--<br>
Best regards,<br>
=A0 Jesper Dangaard Brouer<br>
=A0 MSc.CS, Sr. Network Kernel Developer at Red Hat<br>
=A0 Author of <a href=3D"http://www.iptv-analyzer.org" target=3D"_blank">ht=
tp://www.iptv-analyzer.org</a><br>
=A0 LinkedIn: <a href=3D"http://www.linkedin.com/in/brouer" target=3D"_blan=
k">http://www.linkedin.com/in/brouer</a><br>
<br>
Reproducer commands:<br>
=A0tc qdisc add dev lo root handle 1: htb default 1<br>
=A0tc class add dev lo parent 1: classid 1:1 htb rate 100kbit<br>
=A0netserver<br>
=A0netperf -t TCP_STREAM -l 60 -H 127.0.0.1 -- -m 1024<br>
<br>
Measuring the qdisc &quot;rate&quot; via:<br>
=A0tc -s -d class show dev lo classid 1:1<br>
<br>
Data:<br>
=3D=3D=3D=3D=3D<br>
>From dev &quot;lo&quot;:<br>
--------------<br>
class htb 1:1 root prio 0 quantum 1250 rate 100000bit ceil 100000bit burst =
1600b/1 mpu 0b overhead 0b cburst 1600b/1 mpu 0b overhead 0b level 0<br>
=A0Sent 597719 bytes 64 pkt (dropped 942, overlimits 0 requeues 0)<br>
=A0rate 100656bit 1pps backlog 0b 1p requeues 0<br>
=A0lended: 64 borrowed: 0 giants: 0<br>
=A0tokens: -27387576 ctokens: -27387576<br>
<br>
>From 1Gbit/s dev eth63:<br>
-----------------------<br>
class htb 1:1 root prio 0 quantum 1250 rate 100000bit ceil 100000bit burst =
1600b/1 mpu 0b overhead 0b cburst 1600b/1 mpu 0b overhead 0b level 0<br>
=A0Sent 1801152 bytes 3224 pkt (dropped 0, overlimits 0 requeues 0)<br>
=A0rate 102016bit 9pps backlog 0b 12p requeues 0<br>
=A0lended: 2284 borrowed: 0 giants: 0<br>
=A0tokens: -18923820 ctokens: -18923820<br>
<br>
<br>
>From 10Gbit/s dev eth31:<br>
------------------------<br>
class htb 1:1 root prio 0 quantum 1250 rate 100000bit ceil 100000bit burst =
1600b/1 mpu 0b overhead 0b cburst 1600b/1 mpu 0b overhead 0b level 0<br>
=A0Sent 855814 bytes 581 pkt (dropped 0, overlimits 0 requeues 0)<br>
=A0rate 103256bit 9pps backlog 0b 9p requeues 0<br>
=A0lended: 81 borrowed: 0 giants: 0<br>
=A0tokens: -45419150 ctokens: -45419150<br>
<br>
</blockquote></div><br><br clear=3D"all"><br>-- <br>Dave T=E4ht<br><br>Fixi=
ng bufferbloat with cerowrt: <a href=3D"http://www.teklibre.com/cerowrt/sub=
scribe.html" target=3D"_blank">http://www.teklibre.com/cerowrt/subscribe.ht=
ml</a>=20

--089e013cbdca39007204de59e484--

--===============6801637927995609329==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
Bloat mailing list
Bloat-JXvr2/1DY2fm6VMwtOF2vx4hnT+Y9+D1@public.gmane.org
https://lists.bufferbloat.net/listinfo/bloat

--===============6801637927995609329==--
