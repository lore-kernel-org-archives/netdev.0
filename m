From: Janos Farkas <jf-ml-k1-1087813225@lk8rp.mail.xeon.eu.org>
Subject: waiting for ppp0 to become free (Re: ppp0 out of control)
Date: Wed, 26 Jan 2005 10:44:22 +0100
Message-ID: <20050126094422.GA31040@lk8rp.mail.xeon.eu.org>
References: <20050121144444.GA2100@roxor.be>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: quoted-printable
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: linux-kernel@vger.kernel.org
Content-Disposition: inline
In-Reply-To: <20050121144444.GA2100@roxor.be>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On 2005-01-21 at 15:44:44, Aur=E9lien G=C9R=D4ME wrote:
> I am running 2.6.10 from kernel.org on Debian Sid ppc/x86, the same
> issue occurs with 2.6.9. Though, 2.6.8.1 and previous are fine.
>=20
> When my ISP connection via PPPoE (kernel side) goes down, reconnection
> does not occur, and the kernel displays continuous:
>=20
> kernel: unregister_netdevice: waiting for ppp0 to become free. Usage co=
unt =3D 1

BTW, I have seen many cases when this symptom annoyed me too, the last
one is that my shutdown scripts tried unloading the network driver
modules.  Is your setup doing this by any chance?  In my case,
apparently there were conntrack entries keeping the device in use,
which is almost useless when preparing to shutdown :)

OTOH, I couldn't find a way to flush those conntracks, so I worked
around it by not rmmoding ethernet drivers.

In your case, it's probably conntrack too, I'd presume you are using
that PPPoE machine as a masquerading gateway, which by definition needs
connection tracking...  I'm not sure either if this is a "real" change,
I only vaguely recollect as some moons earlier this wasn't a problem in
2.6.

--=20
Janos | romfs is at http://romfs.sourceforge.net/ | Don't talk about sile=
nce.
