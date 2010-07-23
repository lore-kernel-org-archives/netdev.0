From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH iptables] extension: add xt_cpu match
Date: Fri, 23 Jul 2010 19:30:19 +0200
Message-ID: <1279906219.2481.94.camel@edumazet-laptop>
References: <1279807385.2467.67.camel@edumazet-laptop>
	 <alpine.LSU.2.01.1007221611510.1619@obet.zrqbmnf.qr>
	 <1279811939.2467.79.camel@edumazet-laptop>  <4C497644.7050201@trash.net>
	 <1279892621.2481.53.camel@edumazet-laptop>
	 <alpine.LSU.2.01.1007231841500.2880@obet.zrqbmnf.qr>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Patrick McHardy <kaber@trash.net>,
	Netfilter Development Mailinglist
	<netfilter-devel@vger.kernel.org>, netdev <netdev@vger.kernel.org>
To: Jan Engelhardt <jengelh@medozas.de>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <alpine.LSU.2.01.1007231841500.2880@obet.zrqbmnf.qr>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Le vendredi 23 juillet 2010 =C3=A0 18:46 +0200, Jan Engelhardt a =C3=A9=
crit :
> On Friday 2010-07-23 15:43, Eric Dumazet wrote:
> >+
> >+static const struct option cpu_opts[] =3D {
> >+	{ "cpu", 1, NULL, '1' },
> >+	{ .name =3D NULL }
> >+};
>=20
> I will never understand that sort of style mix logic. Why the
> C99 initializer only on the sentinel?
>=20
> {
> 	{.name =3D "cpu", .has_arg =3D true, .val =3D '1'},
> 	{NULL},
> };
>=20

copy/paste from another module ?

> >+cpu_print(const void *ip, const struct xt_entry_match *match, int n=
umeric)
> >+{
> >+	const struct xt_cpu_info *info =3D (void *)match->data;
> >+
> >+	printf("cpu %s%u ", info->invert ? "! ":"", info->cpu);
> >+}
> >+
> >+static void cpu_save(const void *ip, const struct xt_entry_match *m=
atch)
> >+{
> >+	const struct xt_cpu_info *info =3D (void *)match->data;
> >+
> >+	printf("%s--cpu %u ", info->invert ? "! ":"", info->cpu);
> >+}
>=20
> Using if (info->invert) would save the empty string.
>=20

Not sure what you mean. You want to save an empty string (1 byte long),
and add multiple printf() calls ?

> >diff --git a/extensions/libxt_cpu.man b/extensions/libxt_cpu.man
> >index e69de29..f42ac7a 100644
> >--- a/extensions/libxt_cpu.man
> >+++ b/extensions/libxt_cpu.man
> >@@ -0,0 +1,16 @@
> >+.TP
> >+[\fB!\fP] \fB\-\-cpu\fP \fInumber\fP
> >+
> >+Match cpu handling this packet. cpus are numbered from 0 to NR_CPUS=
-1
>=20
> Unwanted blank line.
>=20
> >+Can be used in combination with RPS (Remote Packet Steering) or
> >+multiqueue NICS to spread network traffic on different queues.
> >+.PP
> >+Example:
> >+.PP
> >+iptables \-t nat \-A PREROUTING \-p tcp \-\-dport 80 \-m cpu \-\-cp=
u 0=20
> >+        \-j REDIRECT \-\-to\-port 8080
>=20
> Unwanted indent.
>=20
> >+.PP
> >+iptables \-t nat \-A PREROUTING \-p tcp \-\-dport 80 \-m cpu \-\-cp=
u 1=20
> >+        \-j REDIRECT \-\-to\-port 8081
> >+.PP
> >+Available since linux 2.6.36
>=20
> Linux.


OK ;)

I'll provide a cleanup patch, not only to xt_cpu but all other iptables
modules that dont meet your coding style requirements ;)

Thanks


--
To unsubscribe from this list: send the line "unsubscribe netfilter-dev=
el" in
the body of a message to majordomo@vger.kernel.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
