From: Vasiliy Kulikov <segoon@openwall.com>
Subject: Re: [PATCH] net: ipv4: add IPPROTO_ICMP socket kind
Date: Wed, 13 Apr 2011 15:32:04 +0400
Message-ID: <20110413113204.GB6948@albatros>
References: <BANLkTi=ogJg_uJqsJFpnwnnr6LS+SFT3Vg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	Pavel Kankovsky <peak@argo.troja.mff.cuni.cz>,
	Solar Designer <solar@openwall.com>,
	Kees Cook <kees.cook@canonical.com>,
	Dan Rosenberg <dan.j.rosenberg@gmail.com>,
	Eugene Teo <eugene@redhat.com>,
	Nelson Elhage <nelhage@ksplice.com>,
	"David S. Miller" <davem@davemloft.net>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	Pekka Savola <pekkas@netcore.fi>,
	James Morris <jmorris@namei.org>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	Patrick McHardy <kaber@trash.net>
To: Alexey Dobriyan <adobriyan@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <BANLkTi=ogJg_uJqsJFpnwnnr6LS+SFT3Vg@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Apr 13, 2011 at 13:29 +0300, Alexey Dobriyan wrote:
> On Sat, Apr 9, 2011 at 1:15 PM, Vasiliy Kulikov <segoon@openwall.com>=
 wrote:
> > This patch adds IPPROTO_ICMP socket kind.
>=20
> > + =A0 =A0 =A0 seq_printf(f, "%5d: %08X:%04X %08X:%04X"
> > + =A0 =A0 =A0 =A0 =A0 =A0 =A0 " %02X %08X:%08X %02X:%08lX %08X %5d =
%8d %lu %d %p %d%n",
> > + =A0 =A0 =A0 =A0 =A0 =A0 =A0 bucket, src, srcp, dest, destp, sp->s=
k_state,
> > + =A0 =A0 =A0 =A0 =A0 =A0 =A0 sk_wmem_alloc_get(sp),
> > + =A0 =A0 =A0 =A0 =A0 =A0 =A0 sk_rmem_alloc_get(sp),
> > + =A0 =A0 =A0 =A0 =A0 =A0 =A0 0, 0L, 0, sock_i_uid(sp), 0, sock_i_i=
no(sp),
>=20
> These zeroes can be embedded into format string for slightly faster p=
rinting.

Is it really needed?  I mean, it is not a fast path, so such a small
overhead is not very bad.  But embedding them into the string makes it =
a
bit more difficult to read.

> > +static const struct file_operations ping_seq_fops =3D {
> > + =A0 =A0 =A0 .owner =A0 =A0 =A0 =A0 =A0=3D THIS_MODULE,
>=20
> Unnecessary line.
> ->owner is unused for proc files, this is not documented anywhere, bu=
t
> it's unused.

OK.

> > +static const char ping_proc_name[] =3D "icmp";
>=20
> Ewww :-)
> Does not compiler create only one string?

I used it for better readability as it is used 2 times.

> > + =A0 =A0 =A0 p =3D proc_create_data(ping_proc_name, S_IRUGO, net->=
proc_net,
> > + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0&ping_seq_=
fops, NULL);
>=20
> There is proc_net_fops_create().

OK.

> > +#ifdef CONFIG_IP_PING
> > + =A0 =A0 =A0 =A0 =A0 =A0 =A0 table[7].data =3D
> > + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 &net->ipv4.sysctl_pin=
g_group_range;
> > +#endif
>=20
> Now I understand it's not related, but next sysctl will have
> "table[8].data =3D ..." line which is off-by-one if CONFIG_IP_PING=3D=
n.

Agreed that hardcoded indexes look a bit ugly, especially with
configurable elements.  But as Dave suggested to completely remove
CONFIG_IP_PING, it doesn't make sense now.

Thank you,

--=20
Vasiliy Kulikov
http://www.openwall.com - bringing security into open computing environ=
ments
