From: Jacob Keller <jacob.keller@gmail.com>
Subject: Re: [PATCH v6 0/8] ptp: IEEE 1588 hardware clock support
Date: Thu, 23 Sep 2010 11:21:55 -0700
Message-ID: <AANLkTim0JqVTyvrvjLRp1Cg423MdrwmyZG2uN6uSyeLb@mail.gmail.com>
References: <cover.1285261533.git.richard.cochran@omicron.at>
	<alpine.DEB.2.00.1009231238170.2962@router.home>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="===============1437980119197724313=="
Cc: John Stultz <johnstul@us.ibm.com>, Rodolfo Giometti <giometti@linux.it>,
	Arnd Bergmann <arnd@arndb.de>,
	Peter Zijlstra <peterz@infradead.org>, linux-api@vger.kernel.org,
	devicetree-discuss@lists.ozlabs.org,
	linux-kernel@vger.kernel.org, David Miller <davem@davemloft.net>,
	netdev@vger.kernel.org, Thomas Gleixner <tglx@linutronix.de>,
	linuxppc-dev@lists.ozlabs.org, Richard Cochran <richardcochran@gmail.com>,
	linux-arm-kernel@lists.infradead.org, Krzysztof Halasa <khc@pm.waw.pl>
To: Christoph Lameter <cl@linux.com>
Return-path: <linuxppc-dev-bounces+glppe-linuxppc-embedded-2=m.gmane.org@lists.ozlabs.org>
In-Reply-To: <alpine.DEB.2.00.1009231238170.2962@router.home>
List-Unsubscribe: <https://lists.ozlabs.org/options/linuxppc-dev>,
	<mailto:linuxppc-dev-request@lists.ozlabs.org?subject=unsubscribe>
List-Archive: <http://lists.ozlabs.org/pipermail/linuxppc-dev>
List-Post: <mailto:linuxppc-dev@lists.ozlabs.org>
List-Help: <mailto:linuxppc-dev-request@lists.ozlabs.org?subject=help>
List-Subscribe: <https://lists.ozlabs.org/listinfo/linuxppc-dev>,
	<mailto:linuxppc-dev-request@lists.ozlabs.org?subject=subscribe>
Sender: linuxppc-dev-bounces+glppe-linuxppc-embedded-2=m.gmane.org@lists.ozlabs.org
Errors-To: linuxppc-dev-bounces+glppe-linuxppc-embedded-2=m.gmane.org@lists.ozlabs.org
List-Id: netdev.vger.kernel.org

--===============1437980119197724313==
Content-Type: multipart/alternative; boundary=0015174bf266d2ff860490f15719

--0015174bf266d2ff860490f15719
Content-Type: text/plain; charset=ISO-8859-1

>
> >     In contrast to the standard Linux system clock, a PHC is
> >     adjustable in hardware, for example using frequency compensation
> >     registers or a VCO. The ability to directly tune the PHC is
> >     essential to reap the benefit of hardware timestamping.
>
> There is a reason for not being able to shift posix clocks: The system has
> one time base. The various clocks are contributing to maintaining that
> sytem wide time.
>
> Adjusting clocks is absolutely essential for proper functioning of the PTP
protocol. The slave obtains and calculates the offset from master and uses
that in order to adjust the clock properly, The problem is that the
timestamps are done via the hardware. We need a method to expose that
hardware so that the ptp software can properly adjust those clocks.


> I do not understand why you want to maintain different clocks running at
> different speeds. Certainly interesting for some uses I guess that I
> do not have the energy to imagine right now. But can we get the PTP killer
> feature of synchronized accurate system time first?
>

The problem is maintaining a hardware clock at the correct speed/frequency
and time. The timestamping is done via hardware, and that hardware clock
needs to be accurate. We need to be able to modify that clock. Yes, having
the system time be the same value would be nice, but the problem comes
because we don't want to jump through hoops to keep that hardware clock
accurate to the ptp protocol running on the network.



>
> >    Instead, the patch set provides a way to offer a Pulse Per Second
> >    (PPS) event from the PHC to the Linux PPS subsystem. A user space
> >    application can read the PPS events and tune the system clock, just
> >    like when using other external time sources like radio clocks or
> >    GPS.
>
> User space is subject to various latencies created by the OS etc. I would
> that in order to have fine grained (read microsecond) accurary we would
> have to run the portions that are relevant to obtaining the desired
> accuracy in the kernel.
>

All of the necessary features for microsecond or better accuracy are done
via the hardware. You can get accuracy to within <10 mircoseconds while only
sending sync packets and such once per second. The reason is because the
hardware timestamps are very accurate. But if we can't properly adjust the
clocks time and frequency, we cannot maintain the accuracy of the
timestamps.

>
>
 --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>

--0015174bf266d2ff860490f15719
Content-Type: text/html; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable

<br><br><div class=3D"gmail_quote"><blockquote class=3D"gmail_quote" style=
=3D"margin: 0pt 0pt 0pt 0.8ex; border-left: 1px solid rgb(204, 204, 204); p=
adding-left: 1ex;"><div class=3D"im">
&gt;<br>
&gt; =A0 =A0 In contrast to the standard Linux system clock, a PHC is<br>
&gt; =A0 =A0 adjustable in hardware, for example using frequency compensati=
on<br>
&gt; =A0 =A0 registers or a VCO. The ability to directly tune the PHC is<br=
>
&gt; =A0 =A0 essential to reap the benefit of hardware timestamping.<br>
<br>
</div>There is a reason for not being able to shift posix clocks: The syste=
m has<br>
one time base. The various clocks are contributing to maintaining that<br>
sytem wide time.<br>
<br></blockquote><div>Adjusting clocks is absolutely essential for proper f=
unctioning of the PTP protocol. The slave obtains and calculates the offset=
 from master and uses that in order to adjust the clock properly, The probl=
em is that the timestamps are done via the hardware. We need a method to ex=
pose that hardware so that the ptp software can properly adjust those clock=
s.<br>

=A0</div><blockquote class=3D"gmail_quote" style=3D"margin: 0pt 0pt 0pt 0.8=
ex; border-left: 1px solid rgb(204, 204, 204); padding-left: 1ex;">
I do not understand why you want to maintain different clocks running at<br=
>
different speeds. Certainly interesting for some uses I guess that I<br>
do not have the energy to imagine right now. But can we get the PTP killer<=
br>
feature of synchronized accurate system time first?<br></blockquote><div><b=
r>The problem is maintaining a hardware clock at the correct speed/frequenc=
y and time. The timestamping is done via hardware, and that hardware clock =
needs to be accurate. We need to be able to modify that clock. Yes, having =
the system time be the same value would be nice, but the problem comes beca=
use we don&#39;t want to jump through hoops to keep that hardware clock acc=
urate to the ptp protocol running on the network.<br>

</div><div><br>=A0</div><blockquote class=3D"gmail_quote" style=3D"margin: =
0pt 0pt 0pt 0.8ex; border-left: 1px solid rgb(204, 204, 204); padding-left:=
 1ex;">
<div class=3D"im"><br>
&gt; =A0 =A0Instead, the patch set provides a way to offer a Pulse Per Seco=
nd<br>
&gt; =A0 =A0(PPS) event from the PHC to the Linux PPS subsystem. A user spa=
ce<br>
&gt; =A0 =A0application can read the PPS events and tune the system clock, =
just<br>
&gt; =A0 =A0like when using other external time sources like radio clocks o=
r<br>
&gt; =A0 =A0GPS.<br>
<br>
</div>User space is subject to various latencies created by the OS etc. I w=
ould<br>
that in order to have fine grained (read microsecond) accurary we would<br>
have to run the portions that are relevant to obtaining the desired<br>
accuracy in the kernel. <br></blockquote><div><br>All of the necessary feat=
ures for microsecond or better accuracy are done via the hardware. You can =
get accuracy to within &lt;10 mircoseconds while only sending sync packets =
and such once per second. The reason is because the hardware timestamps are=
 very accurate. But if we can&#39;t properly adjust the clocks time and fre=
quency, we cannot maintain the accuracy of the timestamps. <br>

</div><blockquote class=3D"gmail_quote" style=3D"margin: 0pt 0pt 0pt 0.8ex;=
 border-left: 1px solid rgb(204, 204, 204); padding-left: 1ex;"><div><div>=
=A0</div></div></blockquote><blockquote class=3D"gmail_quote" style=3D"marg=
in: 0pt 0pt 0pt 0.8ex; border-left: 1px solid rgb(204, 204, 204); padding-l=
eft: 1ex;">

<div><div class=3D"h5">
--<br>
To unsubscribe from this list: send the line &quot;unsubscribe netdev&quot;=
 in<br>
the body of a message to <a href=3D"mailto:majordomo@vger.kernel.org">major=
domo@vger.kernel.org</a><br>
More majordomo info at =A0<a href=3D"http://vger.kernel.org/majordomo-info.=
html" target=3D"_blank">http://vger.kernel.org/majordomo-info.html</a><br>
</div></div></blockquote><br></div><br>

--0015174bf266d2ff860490f15719--

--===============1437980119197724313==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
Linuxppc-dev mailing list
Linuxppc-dev@lists.ozlabs.org
https://lists.ozlabs.org/listinfo/linuxppc-dev
--===============1437980119197724313==--
