From: Jesse Gross <jesse-l0M0P4e3n4LQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH] openvswitch: Make IPv6 packet parsing
	dependent on IPv6 config
Date: Fri, 16 Nov 2012 09:33:09 -0800
Message-ID: <CAEP_g=9TVS6v7mrZZvrP0k7nZoBpH1Um=QGsbfypD0XodDynJg@mail.gmail.com>
References: <50a5c2e5.lgIvZwesNLp78CVD%fengguang.wu@intel.com>
	<1353080434-14165-1-git-send-email-vyasevic@redhat.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="===============1972621828=="
Cc: dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, fengguang.wu-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org,
	davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org
To: Vlad Yasevich <vyasevic-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Return-path: <dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>
In-Reply-To: <1353080434-14165-1-git-send-email-vyasevic-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
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

--===============1972621828==
Content-Type: multipart/alternative; boundary=e89a8fb1f5967a82a304cea02a3d

--e89a8fb1f5967a82a304cea02a3d
Content-Type: text/plain; charset=UTF-8

On Fri, Nov 16, 2012 at 7:40 AM, Vlad Yasevich <vyasevic-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org> wrote:

> Openvswitch attempts to use IPv6 packet parsing functions without
> any dependency on IPv6 (unlike every other place in kernel).  Pull
> the IPv6 code in openvswitch togeter and put a conditional that's
> dependent on CONFIG_IPV6.
>
> Resolves:
> net/built-in.o: In function `ovs_flow_extract':
> (.text+0xbf5d5): undefined reference to `ipv6_skip_exthdr'
>
> Signed-off-by: Vlad Yasevich <vyasevic-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>


Doesn't this move in the opposite direction of your patches to make IPv6
GSO/GRO always available?  The packets being processed here
are generally created by the guest but with Open vSwitch running on the
host.  Also, ipv6_skip_exthdr() is in exthdrs_core.c, so it actually is
always available.  I suspect that the real problem is that the dependency
on the ipv6 directory changed to CONFIG_INET and Open vSwitch should now
depend on this.

--e89a8fb1f5967a82a304cea02a3d
Content-Type: text/html; charset=UTF-8
Content-Transfer-Encoding: quoted-printable

On Fri, Nov 16, 2012 at 7:40 AM, Vlad Yasevich <span dir=3D"ltr">&lt;<a hre=
f=3D"mailto:vyasevic-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org" target=3D"_blank">vyasevic-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org</a>&=
gt;</span> wrote:<br><div class=3D"gmail_quote"><blockquote class=3D"gmail_=
quote" style=3D"margin:0 0 0 .8ex;border-left:1px #ccc solid;padding-left:1=
ex">

Openvswitch attempts to use IPv6 packet parsing functions without<br>
any dependency on IPv6 (unlike every other place in kernel). =C2=A0Pull<br>
the IPv6 code in openvswitch togeter and put a conditional that&#39;s<br>
dependent on CONFIG_IPV6.<br>
<br>
Resolves:<br>
net/built-in.o: In function `ovs_flow_extract&#39;:<br>
(.text+0xbf5d5): undefined reference to `ipv6_skip_exthdr&#39;<br>
<br>
Signed-off-by: Vlad Yasevich &lt;<a href=3D"mailto:vyasevic-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org">vya=
sevic-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org</a>&gt;</blockquote><div><br></div><div><span style=3D"bac=
kground-color:rgb(255,255,255);color:rgb(34,34,34);font-family:arial,sans-s=
erif;font-size:13px">Doesn&#39;t this move in the opposite direction of you=
r patches to make IPv6 GSO/GRO always available? =C2=A0The packets being pr=
ocessed here are=C2=A0generally=C2=A0created by the guest but with Open vSw=
itch running on the host. =C2=A0Also, ipv6_skip_exthdr() is in exthdrs_core=
.c, so it actually is always available. =C2=A0I suspect that the real probl=
em is that the dependency on the ipv6 directory changed to CONFIG_INET and =
Open vSwitch should now depend on this.</span>=C2=A0</div>

</div>

--e89a8fb1f5967a82a304cea02a3d--

--===============1972621828==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline


--===============1972621828==--
