From: Dave Taht <dave.taht-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: tc linklayer ADSL calc broken after commit 56b765b79
 (htb: improved accuracy at high rates)
Date: Wed, 29 May 2013 17:34:02 -0700
Message-ID: <CAA93jw7HAtiR3vVJcg7Dh3xYO3QALrw2Yj9NGS3w4gHNo9W4dg@mail.gmail.com>
References: <20130529151330.22c5c89e@redhat.com>
	<1369842724.5109.44.camel@edumazet-glaptop>
	<20130529155034.334092c5@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="===============9101287216605316126=="
Cc: =?ISO-8859-1?Q?Toke_H=F8iland=2DJ=F8rgensen?= <toke-LJ9M9ZcSy1A@public.gmane.org>,
	Mike Frysinger <vapier-aBrp7R+bbdUdnm+yROfE0A@public.gmane.org>,
	Jiri Pirko <jpirko-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	Patrick McHardy <kaber-dcUjhNyLwpNeoWH0uzbU5w@public.gmane.org>, Jiri Benc <jbenc-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>,
	Steven Barth <cyrus-p3rKhJxN3npAfugRpC6u6w@public.gmane.org>, bloat <bloat-JXvr2/1DY2fm6VMwtOF2vx4hnT+Y9+D1@public.gmane.org>,
	David Miller <davem-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>,
	Jussi Kivilinna <jussi.kivilinna-E01nCVcF24I@public.gmane.org>,
	Felix Fietkau <nbd-Vt+b4OUoWG0@public.gmane.org>, Michal Soltys <soltys-R61QfzASbfY@public.gmane.org>
To: Stephen Hemminger <stephen-OTpzqLSitTUnbdJkjeBofR2eb7JE58TQ@public.gmane.org>
Return-path: <bloat-bounces-JXvr2/1DY2fm6VMwtOF2vx4hnT+Y9+D1@public.gmane.org>
In-Reply-To: <20130529155034.334092c5-We1ePj4FEcvRI77zikRAJc56i+j3xesD0e7PPNI6Mm0@public.gmane.org>
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

--===============9101287216605316126==
Content-Type: multipart/alternative; boundary=047d7b8746d4b558ba04dde4a7fe

--047d7b8746d4b558ba04dde4a7fe
Content-Type: text/plain; charset=ISO-8859-1

On May 29, 2013 6:50 PM, "Stephen Hemminger" <stephen-OTpzqLSitTUnbdJkjeBofR2eb7JE58TQ@public.gmane.org>
wrote:
>
> On Wed, 29 May 2013 08:52:04 -0700
> Eric Dumazet <eric.dumazet-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org> wrote:
>
> > On Wed, 2013-05-29 at 15:13 +0200, Jesper Dangaard Brouer wrote:
> > > I recently discovered that the (traffic control) tc linklayer
> > > calculations for ATM/ADSL have been broken by:
> > >  commit 56b765b79 (htb: improved accuracy at high rates).
> > >
> > > Thus, people shaping on ADSL links, using e.g.:
> > >  tc class add ... htb rate X ceil Y linklayer atm overhead 10
> > >
> > > Will no-longer get ATM cell tax/overhead adjusted.
> > >
> > > How can we solve/fix this?
> > > Perhaps we can change to use the "stab" system instead (as it does
> > > not seem to be broken by the commit).
> > >
> > > But how do we facilitate a change to use "stab" system (for all the
> > > scripts using the old option)?
> > >
> > > Can we change the iproute2/tc command to handle this transparently, or
> > > should we give an error/warning if someone uses "tc" and "linklayer"
on
> > > a kernel above v.3.8. ?
> > >
> > >
> > > History:
> > >  - My linklayer ATM changes appeared in kernel 2.6.24 (and iproute2
2.6.25)
> > >  - The STAB changes appeared in kernel 2.6.27
> > >
> >
> > Hi Jesper
> >
> > stab suffers from the same problem : its table driven, so works only for
> > packet smaller than a given size.
> >
> > I am not sure it will solve the ATM logic (with the 5 bytes overhead per
> > 48 bytes cell)
> >
> > btw, even on old kernels :
>
>
> How bad is the failure? If it is fixed, will it break existing
installations?
>
> Which probably means, is anyone but the original developers ever using it
> and therefore likely to notice?

This debugging train stems on part from spending quite some time being very
puzzled about the behavior of DSL against multiple HTB based fq codel
shapers.

So I'm glad it is a real bug at this layer rather than elsewhere. I'll just
nip off and write off those datasets now.

--047d7b8746d4b558ba04dde4a7fe
Content-Type: text/html; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable

<p dir=3D"ltr"><br>
On May 29, 2013 6:50 PM, &quot;Stephen Hemminger&quot; &lt;<a href=3D"mailt=
o:stephen-OTpzqLSitTUnbdJkjeBofR2eb7JE58TQ@public.gmane.org">stephen-OTpzqLSitTUnbdJkjeBofR2eb7JE58TQ@public.gmane.org</a>&gt; wrote:<br>
&gt;<br>
&gt; On Wed, 29 May 2013 08:52:04 -0700<br>
&gt; Eric Dumazet &lt;<a href=3D"mailto:eric.dumazet-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org">eric.dumaze=
t@gmail.com</a>&gt; wrote:<br>
&gt;<br>
&gt; &gt; On Wed, 2013-05-29 at 15:13 +0200, Jesper Dangaard Brouer wrote:<=
br>
&gt; &gt; &gt; I recently discovered that the (traffic control) tc linklaye=
r<br>
&gt; &gt; &gt; calculations for ATM/ADSL have been broken by:<br>
&gt; &gt; &gt; =A0commit 56b765b79 (htb: improved accuracy at high rates).<=
br>
&gt; &gt; &gt;<br>
&gt; &gt; &gt; Thus, people shaping on ADSL links, using e.g.:<br>
&gt; &gt; &gt; =A0tc class add ... htb rate X ceil Y linklayer atm overhead=
 10<br>
&gt; &gt; &gt;<br>
&gt; &gt; &gt; Will no-longer get ATM cell tax/overhead adjusted.<br>
&gt; &gt; &gt;<br>
&gt; &gt; &gt; How can we solve/fix this?<br>
&gt; &gt; &gt; Perhaps we can change to use the &quot;stab&quot; system ins=
tead (as it does<br>
&gt; &gt; &gt; not seem to be broken by the commit).<br>
&gt; &gt; &gt;<br>
&gt; &gt; &gt; But how do we facilitate a change to use &quot;stab&quot; sy=
stem (for all the<br>
&gt; &gt; &gt; scripts using the old option)?<br>
&gt; &gt; &gt;<br>
&gt; &gt; &gt; Can we change the iproute2/tc command to handle this transpa=
rently, or<br>
&gt; &gt; &gt; should we give an error/warning if someone uses &quot;tc&quo=
t; and &quot;linklayer&quot; on<br>
&gt; &gt; &gt; a kernel above v.3.8. ?<br>
&gt; &gt; &gt;<br>
&gt; &gt; &gt;<br>
&gt; &gt; &gt; History:<br>
&gt; &gt; &gt; =A0- My linklayer ATM changes appeared in kernel 2.6.24 (and=
 iproute2 2.6.25)<br>
&gt; &gt; &gt; =A0- The STAB changes appeared in kernel 2.6.27<br>
&gt; &gt; &gt;<br>
&gt; &gt;<br>
&gt; &gt; Hi Jesper<br>
&gt; &gt;<br>
&gt; &gt; stab suffers from the same problem : its table driven, so works o=
nly for<br>
&gt; &gt; packet smaller than a given size.<br>
&gt; &gt;<br>
&gt; &gt; I am not sure it will solve the ATM logic (with the 5 bytes overh=
ead per<br>
&gt; &gt; 48 bytes cell)<br>
&gt; &gt;<br>
&gt; &gt; btw, even on old kernels :<br>
&gt;<br>
&gt;<br>
&gt; How bad is the failure? If it is fixed, will it break existing install=
ations?<br>
&gt;<br>
&gt; Which probably means, is anyone but the original developers ever using=
 it<br>
&gt; and therefore likely to notice?</p>
<p dir=3D"ltr">This debugging train stems on part from spending quite some =
time being very puzzled about the behavior of DSL against multiple HTB base=
d fq codel shapers. </p>
<p dir=3D"ltr">So I&#39;m glad it is a real bug at this layer rather than e=
lsewhere. I&#39;ll just nip off and write off those datasets now.</p>
<p dir=3D"ltr"> <br>
</p>

--047d7b8746d4b558ba04dde4a7fe--

--===============9101287216605316126==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
Bloat mailing list
Bloat-JXvr2/1DY2fm6VMwtOF2vx4hnT+Y9+D1@public.gmane.org
https://lists.bufferbloat.net/listinfo/bloat

--===============9101287216605316126==--
