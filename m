From: Greg KH <greg@kroah.com>
Subject: Re: Understanding what's going on when using a Huawei E173 USB 3G
 web-stick (UMTS/HSPA)
Date: Sat, 15 Nov 2014 18:34:23 -0800
Message-ID: <20141116023423.GA31016@kroah.com>
References: <CA+icZUXgLhuVSs0aqxi_e=GLZh-zX3JPMhDF+03ctr7O-Ae2og@mail.gmail.com>
 <1415120132.31049.11.camel@dcbw.local>
 <CA+icZUW2iRkoAK10ayJ9PFuFGWBQzKdFe+8mfd=8oKkAp1txtg@mail.gmail.com>
 <CA+icZUX6caBKnjMv6V_26y_-VNfDqkeXFXKJhDdQpZy7W4oofw@mail.gmail.com>
 <1415981880.22965.28.camel@dcbw.local>
 <CA+icZUUWK8R0zFLBHfvfE6zmZ7=+yP_FJgkkeELVbwdhPUYfRA@mail.gmail.com>
 <20141115200711.GA24643@kroah.com>
 <CA+icZUXFYYtvpKV-pOfj-pqhYD+TWBDB3SKKz_aBirrJbxvQkA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Dan Williams <dcbw@redhat.com>,
	"David S. Miller" <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	linux-usb@vger.kernel.org,
	Aleksander Morgado <aleksander@aleksander.es>
To: Sedat Dilek <sedat.dilek@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out4-smtp.messagingengine.com ([66.111.4.28]:37575 "EHLO
	out4-smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755082AbaKPCeZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 15 Nov 2014 21:34:25 -0500
Received: from compute4.internal (compute4.nyi.internal [10.202.2.44])
	by mailout.nyi.internal (Postfix) with ESMTP id 1A9202067D
	for <netdev@vger.kernel.org>; Sat, 15 Nov 2014 21:34:25 -0500 (EST)
Content-Disposition: inline
In-Reply-To: <CA+icZUXFYYtvpKV-pOfj-pqhYD+TWBDB3SKKz_aBirrJbxvQkA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Nov 16, 2014 at 02:40:15AM +0100, Sedat Dilek wrote:
> On Sat, Nov 15, 2014 at 9:07 PM, Greg KH <greg@kroah.com> wrote:
> > On Sat, Nov 15, 2014 at 10:23:55AM +0100, Sedat Dilek wrote:
> >> On Fri, Nov 14, 2014 at 5:18 PM, Dan Williams <dcbw@redhat.com> wr=
ote:
> >> > On Fri, 2014-11-14 at 11:56 +0100, Sedat Dilek wrote:
> >> >> On Wed, Nov 12, 2014 at 2:21 PM, Sedat Dilek <sedat.dilek@gmail=
=2Ecom> wrote:
> >> >> > On Tue, Nov 4, 2014 at 5:55 PM, Dan Williams <dcbw@redhat.com=
> wrote:
> >> >> >> On Tue, 2014-11-04 at 16:11 +0100, Sedat Dilek wrote:
> >> >> >>> Hi,
> >> >> >>>
> >> >> >>> I wanted to understand what is going on the kernel-side whe=
n
> >> >> >>> connecting to the Internet via a Huawei E173 USB web-stick =
(3rd
> >> >> >>> Generation: UMTS / HSPA).
> >> >> >>>
> >> >> >>> Especially the correlation between the diverse USB/NET kern=
el-drivers
> >> >> >>> and how the networking is setup.
> >> >> >>
> >> >> >
> >> >> > [ Sitting in front of a foreign Windows machine ]
> >> >> >
> >> >> > [ CC Aleksander ]
> >> >> >
> >> >> > Hi Dan,
> >> >> >
> >> >> > sorry for the late (and short) response.
> >> >> >
> >> >> > AFAICS you have given a "skeleton" for a "usb-wwan-networking=
"
> >> >> > documentation :-).
> >> >> >
> >> >> > Personally, I would like to take into account some kernel-con=
fig
> >> >> > options and some more things.
> >> >> >
> >> >>
> >> >> I started with documenting...
> >> >>
> >> >> I have still some difficulties in understanding USB WWAN Networ=
king.
> >> >> So, this is what I revealed...
> >> >>
> >> >> ##### USB: HUAWEI E173 3G/UMTS/HSPA INTERNET STICK
> >> >>
> >> >> ### USB-NETWORKING AND WWAN SETUP
> >> >> CONFIG_USB_USBNET=3Dm        <--- usb networking
> >> >> CONFIG_USB_NET_CDCETHER=3Dm  <--- usb-wwan (net) configuration
> >> >> CONFIG_USB_SERIAL_WWAN=3Dm   <--- usb-wwan (serial) configurati=
on
> >> >> CONFIG_USB_SERIAL_OPTION=3Dm <--- usb-serial driver called "opt=
ion"
> >> >
> >> > Most WWAN devices actually require option, because most WWAN dev=
ices
> >> > have "serial" ports (even if they aren't used for PPP), and 'opt=
ion' is
> >> > the driver that handles this.  The 'option' name is historic, bu=
t the
> >> > driver should really be called something like 'wwan-serial-gener=
ic' or
> >> > something like that.
> >> >=F6"
> >>
> >> Is there sth. against renaming the "option" driver to "wwan-serial=
-generic"?
> >
> > Yes, people's scripts might break that are hard-coded to use the
> > "option" driver.
> >
>=20
> As far as I read on LKML... breaking userspace is a reason not to do
> such changes.

Exactly.

> That's really a reason not to break "handmade" scripts on some machin=
es?

Yes.

> As this is new to me... is that documented?

It's our "culture" :)

> Surely, it's fretful to change scripts, but life is change.
> For me there is a more reasonable thing... Did you grep for "option"
> pattern in the kernel sources?
> Try.... :-).

Oh I know, I wrote the first version of this driver and named it this :=
)

> > greg "here, have a vowel, they are cheap" k-h
>=20
> Hmm, being a non-English native, I am not sure to get this...
> What about languages from mostly Eastern countries having so much
> consonants in a single word like Russian, Polish, etc.
> Not every language is rich like German which has WOWels like "=E4" (a=
e)
> "=F6" (oe) "=FC" (ue).

I was referring to your "sth." abbreviation above.

thanks,

greg k-h
