From: Grant Likely <grant.likely@secretlab.ca>
Subject: Re: [RFC PATCH] platform: Faciliatate the creation of pseduo-platform
	busses
Date: Sat, 7 Aug 2010 00:35:21 -0600
Message-ID: <AANLkTimHbcF+fz=aBMLdhLo2s-rhfNvaPCtqE8nYJ8aT@mail.gmail.com>
References: <4C58A7AA.8020007@codeaurora.org> <20100803235631.GA17759@suse.de>
	<4C58AE15.6090900@codeaurora.org> <20100804000945.GA19729@suse.de>
	<4C58B1B6.9050005@quicinc.com> <AANLkTikVzh9=DvvUPbKmDeo6k2-pPVSnjH+GxAPdQFO4@mail.gmail.com>
	<20100806142727.GB4921@suse.de> <AANLkTi=VbVed09=u-Ea0L8c_CWZ_CLLjWH9ZjD2dyg6Y@mail.gmail.com>
	<20100806234635.GC16793@suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Patrick Pannuto <ppannuto@quicinc.com>,
	Patrick Pannuto <ppannuto@codeaurora.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"linux-arm-msm@vger.kernel.org" <linux-arm-msm@vger.kernel.org>,
	"linux-omap@vger.kernel.org" <linux-omap@vger.kernel.org>,
	"damm@opensource.se" <damm@opensource.se>,
	"lethal@linux-sh.org" <lethal@linux-sh.org>,
	"rjw@sisk.pl" <rjw@sisk.pl>, "dtor@mail.ru" <dtor@mail.ru>,
	"eric.y.miao@gmail.com" <eric.y.miao@gmail.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Kevin Hilman <khilman@deeprootsystems.com>
To: Greg KH <gregkh@suse.de>
Return-path: <linux-omap-owner@vger.kernel.org>
In-Reply-To: <20100806234635.GC16793@suse.de>
Sender: linux-omap-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Aug 6, 2010 at 5:46 PM, Greg KH <gregkh@suse.de> wrote:
> On Fri, Aug 06, 2010 at 09:12:27AM -0600, Grant Likely wrote:
>> On Fri, Aug 6, 2010 at 8:27 AM, Greg KH <gregkh@suse.de> wrote:
>> > On Thu, Aug 05, 2010 at 04:59:35PM -0600, Grant Likely wrote:
>> >> (On that point Greg, what is the reason for even having the
>> >> /sys/devices/platform/ parent? =A0Why not just let the platform d=
evices
>> >> sit at the root of the device tree? =A0In the OF case (granted, I=
'm
>> >> biased) all of the platform_device registrations reflect the actu=
al
>> >> device hierarchy expressed in the device tree data.)
>> >
>> > If we sat them at the "root", there would be a bunch of them there=
=2E =A0I
>> > don't know, we could drop the parent, I guess whoever created the
>> > platform device oh so long ago, decided that it would look nicer t=
o be
>> > in this type of structure.
>>
>> Personally I'd rather see a meaningful structure used here. =A0Maybe
>> having them all in the root will encourage people to find realistic
>> parents for their platform devices. =A0:-)
>
> That would be nice, but take your "standard" PC today:
> =A0 =A0 =A0 =A0> ls /sys/devices/platform/
> =A0 =A0 =A0 =A0Fixed MDIO bus.0 =A0i8042 =A0pcspkr =A0power =A0serial=
8250 =A0uevent vesafb.0
>
> There are tty devices below the serial port, which is nice to see, bu=
t
> the others? =A0I don't know what type of bus they would be on, do you=
?

Does it matter?  On my PC I count 7 devices.  On my servers, I see the
same.  I don't personally don't see any disadvantage to having them at
the root.

However, looking at them:

"Fixed MDIO bus" is actually a complete hack that I'm going to try and
get rid of.
i8042 is keyboard/mouse that probably lives on the southbridge.  I
imagine hanging off the PCI bus in the ISA IO range.
ditto pcspkr
ditto serial8250
ditto vesafb

I wouldn't have any problem modifying those specific drivers to
register under something like /sys/devices/legacy, but I don't really
think it is in any way necessary.

I suppose one *could* try to figure out the actual PCI topology that
leads to these devices, but that gets into trying to guess what the
BIOS set up to decide where to register those things.  Probably a lot
of error-prone work for absolutely no benefit.  :-)

However, on the embedded side I'm seeing a lot of devices show up
under /sys/devices/platform.  Embedded is generally different.  We
*know* what the bus topology is.  However, it seems to me that many
developers are under the mistaken assumption that platform devices
must live in /sys/devices/platform, so they don't bother reflecting
the topology in the device model and it seems to be affecting how
embedded PM is being approached (my opinion).  Removing the "struct
device platform_bus" may reduce the confusion.

>> Why don't I float a patch to remove this and see if anybody freaks
>> out. =A0Should I wrap it with a CONFIG_ so that it can be configurab=
le
>> for a release or to, or just make it unconditional?
>
> If you can figure out a structure for the desktop/server machines, su=
re,
> I say just always enable it :)

I've got a patch in my tree now.  I'll play with it a bit before
posting it for RFC.

g.
--
To unsubscribe from this list: send the line "unsubscribe linux-omap" i=
n
the body of a message to majordomo@vger.kernel.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
