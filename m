From: Kais Belgaied <kbelgaied-l0M0P4e3n4LQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH openvswitch v3] netlink: Implement & enable
 memory mapped netlink i/o
Date: Wed, 4 Dec 2013 09:56:35 -0800
Message-ID: <CAAnMRcYrPPtCDsDcdMbiyyGp_rmHxVVhGggMDf72oxGrNBNU2g@mail.gmail.com>
References: <1d9af26b2798901c68ae9aef704d6313b71d3287.1386069453.git.tgraf@redhat.com>
	<20131204163328.GE30874@nicira.com> <529F6475.3090903@redhat.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="===============0392596839=="
Cc: "dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org" <dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>, fleitner-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Thomas Graf <tgraf-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Return-path: <dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>
In-Reply-To: <529F6475.3090903-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
List-Unsubscribe: <http://openvswitch.org/mailman/options/dev>,
	<mailto:dev-request-yBygre7rU0TnMu66kgdUjQ@public.gmane.org?subject=unsubscribe>
List-Archive: <http://openvswitch.org/pipermail/dev>
List-Post: <mailto:dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>
List-Help: <mailto:dev-request-yBygre7rU0TnMu66kgdUjQ@public.gmane.org?subject=help>
List-Subscribe: <http://openvswitch.org/mailman/listinfo/dev>,
	<mailto:dev-request-yBygre7rU0TnMu66kgdUjQ@public.gmane.org?subject=subscribe>
Sender: dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org
Errors-To: dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org
List-Id: netdev.vger.kernel.org

--===============0392596839==
Content-Type: multipart/alternative; boundary=bcaec54317a450898204ecb922be

--bcaec54317a450898204ecb922be
Content-Type: text/plain; charset=ISO-8859-1

or maybe fewer frames per ring. The 8MB per ring uniformly set on each port
could be a rigid setting.
Ideally the ring size should be a function of the need, which is the amount
of netlink traffic for the port using that socket.

Kais


On Wed, Dec 4, 2013 at 9:20 AM, Thomas Graf <tgraf-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org> wrote:

> On 12/04/2013 05:33 PM, Ben Pfaff wrote:
>
>> If I'm doing the calculations correctly, this mmaps 8 MB per ring-based
>> Netlink socket on a system with 4 kB pages.  OVS currently creates one
>> Netlink socket for each datapath port.  With 1000 ports (a moderate
>> number; we sometimes test with more), that is 8 GB of address space.  On
>> a 32-bit architecture that is impossible.  On a 64-bit architecture it
>> is possible but it may reserve an actual 8 GB of RAM: OVS often runs
>> with mlockall() since it is something of a soft real-time system (users
>> don't want their packet delivery delayed to page data back in).
>>
>> Do you have any thoughts about this issue?
>>
>
> That's certainly a problem. I had the impression that the changes that
> allow to consolidate multiple bridges to a single DP would minimize the
> number of DPs used.
>
> How about we limit the number of mmaped sockets to a configurable
> maximum that defaults to 16 or 32?
>
> _______________________________________________
> dev mailing list
> dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org
> http://openvswitch.org/mailman/listinfo/dev
>

--bcaec54317a450898204ecb922be
Content-Type: text/html; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable

<div dir=3D"ltr">or maybe fewer frames per ring. The 8MB per ring uniformly=
 set on each port could be a rigid setting.<div style>Ideally the ring size=
 should be a function of the need, which is the amount of netlink traffic f=
or the port using that socket.</div>
<div style><br></div><div style>Kais</div></div><div class=3D"gmail_extra">=
<br><br><div class=3D"gmail_quote">On Wed, Dec 4, 2013 at 9:20 AM, Thomas G=
raf <span dir=3D"ltr">&lt;<a href=3D"mailto:tgraf-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org" target=3D"_bl=
ank">tgraf-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org</a>&gt;</span> wrote:<br>
<blockquote class=3D"gmail_quote" style=3D"margin:0 0 0 .8ex;border-left:1p=
x #ccc solid;padding-left:1ex"><div class=3D"im">On 12/04/2013 05:33 PM, Be=
n Pfaff wrote:<br>
<blockquote class=3D"gmail_quote" style=3D"margin:0 0 0 .8ex;border-left:1p=
x #ccc solid;padding-left:1ex">
If I&#39;m doing the calculations correctly, this mmaps 8 MB per ring-based=
<br>
Netlink socket on a system with 4 kB pages. =A0OVS currently creates one<br=
>
Netlink socket for each datapath port. =A0With 1000 ports (a moderate<br>
number; we sometimes test with more), that is 8 GB of address space. =A0On<=
br>
a 32-bit architecture that is impossible. =A0On a 64-bit architecture it<br=
>
is possible but it may reserve an actual 8 GB of RAM: OVS often runs<br>
with mlockall() since it is something of a soft real-time system (users<br>
don&#39;t want their packet delivery delayed to page data back in).<br>
<br>
Do you have any thoughts about this issue?<br>
</blockquote>
<br></div>
That&#39;s certainly a problem. I had the impression that the changes that<=
br>
allow to consolidate multiple bridges to a single DP would minimize the<br>
number of DPs used.<br>
<br>
How about we limit the number of mmaped sockets to a configurable<br>
maximum that defaults to 16 or 32?<div class=3D"HOEnZb"><div class=3D"h5"><=
br>
______________________________<u></u>_________________<br>
dev mailing list<br>
<a href=3D"mailto:dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org" target=3D"_blank">dev-yBygre7rU0TBIkM8BG5M+A@public.gmane.org=
g</a><br>
<a href=3D"http://openvswitch.org/mailman/listinfo/dev" target=3D"_blank">h=
ttp://openvswitch.org/<u></u>mailman/listinfo/dev</a><br>
</div></div></blockquote></div><br></div>

--bcaec54317a450898204ecb922be--

--===============0392596839==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline


--===============0392596839==--
