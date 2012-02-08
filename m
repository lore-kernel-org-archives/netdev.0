From: Henrique de Moraes Holschuh <hmh@hmh.eng.br>
Subject: Re: network regression: cannot rename netdev twice
Date: Wed, 8 Feb 2012 00:00:38 -0200
Message-ID: <20120208020038.GE13296@khazad-dum.debian.net>
References: <4F27120A.4040106@suse.cz>
 <CAPXgP12Sr2KzGJ9RA13QBOCkctb-z3O4+1uHOjANgMDDv2pxaQ@mail.gmail.com>
 <4F27C54F.1010107@suse.cz>
 <CAPXgP11=U_Y3LvJB2LRnXQ53y1WQQTqc0j1c7iva6ZXvF97wEw@mail.gmail.com>
 <20120204021457.GA25386@khazad-dum.debian.net>
 <CAPXgP12yZ74679JNwRB-pDfnjOBaxMzL2=krSDK31jM1mjXfuA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Jiri Slaby <jslaby@suse.cz>,
	"Eric W. Biederman" <ebiederm@xmission.com>,
	Greg KH <greg@kroah.com>, LKML <linux-kernel@vger.kernel.org>,
	ML netdev <netdev@vger.kernel.org>
To: Kay Sievers <kay.sievers@vrfy.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <CAPXgP12yZ74679JNwRB-pDfnjOBaxMzL2=krSDK31jM1mjXfuA@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 06 Feb 2012, Kay Sievers wrote:
> On Sat, Feb 4, 2012 at 03:14, Henrique de Moraes Holschuh
> <hmh@hmh.eng.br> wrote:
> > Is it possible to configure the kernel to use something other than =
"eth#" as
> > its initial namespace for netif names? =A0Or is there some other wa=
y to get
> > eth1 to be what you need eth1 to be during userland boot?
>=20
> I don't think there is a sane way to do that. Someone could add a
> kernel command line parameter to switch ethX in the kernel to
> something else, and create custom udev rules which match on device
> properties and apply configured names which are ethX again. But for
> all that, there will be no generally available support in common base
> system tools, and we absolutely do not recommend anybody doing that.

What sort of impact analysis on userspace was done about this change?

Nobody in his right mind would go back to the dark ages of uncontrolled
ifnames.  You're effectively forcing everybody with a clue away from th=
e
eth# namespace.

Just to be very clear: the impact of this is the need to change the
interface names on potentially millions of lines of firewall rules and
scripts out there, as well as tracking down stuff (mostly scripts) that
special-cases the eth prefix.

Is there a really good reason why we cannot have a way to move the
kernel away from the eth# namespace at boot (through a kernel parameter=
,
maybe with the default namespace set at compile time), AND keep the
"common base system tools" support to assign ifname based on MAC
addresses that we have right now?

--=20
  "One disk to rule them all, One disk to find them. One disk to bring
  them all and in the darkness grind them. In the Land of Redmond
  where the shadows lie." -- The Silicon Valley Tarot
  Henrique Holschuh
