From: Kay Sievers <kay.sievers@vrfy.org>
Subject: Re: network regression: cannot rename netdev twice
Date: Wed, 8 Feb 2012 04:50:15 +0100
Message-ID: <CAPXgP12ExDub9ML0=DcWRwyQP23GXDJ75jiNnw+BTXY17tEa8Q@mail.gmail.com>
References: <4F27120A.4040106@suse.cz> <CAPXgP12Sr2KzGJ9RA13QBOCkctb-z3O4+1uHOjANgMDDv2pxaQ@mail.gmail.com>
 <4F27C54F.1010107@suse.cz> <CAPXgP11=U_Y3LvJB2LRnXQ53y1WQQTqc0j1c7iva6ZXvF97wEw@mail.gmail.com>
 <20120204021457.GA25386@khazad-dum.debian.net> <CAPXgP12yZ74679JNwRB-pDfnjOBaxMzL2=krSDK31jM1mjXfuA@mail.gmail.com>
 <20120208020038.GE13296@khazad-dum.debian.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Jiri Slaby <jslaby@suse.cz>,
	"Eric W. Biederman" <ebiederm@xmission.com>,
	Greg KH <greg@kroah.com>, LKML <linux-kernel@vger.kernel.org>,
	ML netdev <netdev@vger.kernel.org>
To: Henrique de Moraes Holschuh <hmh@hmh.eng.br>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20120208020038.GE13296@khazad-dum.debian.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Feb 8, 2012 at 03:00, Henrique de Moraes Holschuh
<hmh@hmh.eng.br> wrote:
> On Mon, 06 Feb 2012, Kay Sievers wrote:
>> On Sat, Feb 4, 2012 at 03:14, Henrique de Moraes Holschuh
>> <hmh@hmh.eng.br> wrote:
>> > Is it possible to configure the kernel to use something other than=
 "eth#" as
>> > its initial namespace for netif names? =C2=A0Or is there some othe=
r way to get
>> > eth1 to be what you need eth1 to be during userland boot?
>>
>> I don't think there is a sane way to do that. Someone could add a
>> kernel command line parameter to switch ethX in the kernel to
>> something else, and create custom udev rules which match on device
>> properties and apply configured names which are ethX again. But for
>> all that, there will be no generally available support in common bas=
e
>> system tools, and we absolutely do not recommend anybody doing that.
>
> What sort of impact analysis on userspace was done about this change?

None. It will just not be supported for new setups. Existing ones will
do what they always did.

> Nobody in his right mind would go back to the dark ages of uncontroll=
ed
> ifnames. =C2=A0You're effectively forcing everybody with a clue away =
from the
> eth# namespace.

Yes. It's a game we have lost and we will not win in the future. I
gave up, and I warn everybody who think it's simple to manage.

> Just to be very clear: the impact of this is the need to change the
> interface names on potentially millions of lines of firewall rules an=
d
> scripts out there, as well as tracking down stuff (mostly scripts) th=
at
> special-cases the eth prefix.

Yeah, and for good, ethX is a pretty much random kernel name, and I
personally will no longer work on conceptually broken infrastructure
that can never deliver what it seems to promise. In the longer run,
tools need to be fixed to automatically handle changing names, or not
care about the names at all, or names need to be explicitly set up
outside the ethX namespace to be predictable.

After years of working in that area I will stop to work on these hacks
to promise stable ethX names. It was just wrong, like enumerations
always are in hotplug setups.

> Is there a really good reason why we cannot have a way to move the
> kernel away from the eth# namespace at boot (through a kernel paramet=
er,
> maybe with the default namespace set at compile time),

Could work, but I don't think it is worth. Simple enumeration, and
automatic persistent on-disk device name reservation in a flat
number-range is just a very flawed concept. I'm not interested in
working on that, but that surely should not stop anybody from trying
and providing tools that can do that.

> AND keep the
> "common base system tools" support to assign ifname based on MAC
> addresses that we have right now?

Not provided by udev's default setup, which did persistent name
reservation in the device hotplug path. It is already disabled and
will be entirely removed from the source tree some day. Other tools
can still try to provide that. But I declare that model as officially
failed and udev will not even try anything like that anymore.

People who need predictable interface names should just manually
configure custom/descriptive names, or names which are reliably
derived from the hardware, like firmware-provided names or the pci
slot number.

Kay
