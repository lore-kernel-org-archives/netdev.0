From: Sedat Dilek <sedat.dilek@gmail.com>
Subject: Re: Understanding what's going on when using a Huawei E173 USB 3G
 web-stick (UMTS/HSPA)
Date: Sun, 16 Nov 2014 03:48:08 +0100
Message-ID: <CA+icZUVVWyvw0FH6sRdcEG9ioQggHoQ_D3+ApVtydrWjWW4=mA@mail.gmail.com>
References: <CA+icZUXgLhuVSs0aqxi_e=GLZh-zX3JPMhDF+03ctr7O-Ae2og@mail.gmail.com>
	<1415120132.31049.11.camel@dcbw.local>
	<CA+icZUW2iRkoAK10ayJ9PFuFGWBQzKdFe+8mfd=8oKkAp1txtg@mail.gmail.com>
	<CA+icZUX6caBKnjMv6V_26y_-VNfDqkeXFXKJhDdQpZy7W4oofw@mail.gmail.com>
	<1415981880.22965.28.camel@dcbw.local>
	<CA+icZUUWK8R0zFLBHfvfE6zmZ7=+yP_FJgkkeELVbwdhPUYfRA@mail.gmail.com>
	<20141115200711.GA24643@kroah.com>
	<CA+icZUXFYYtvpKV-pOfj-pqhYD+TWBDB3SKKz_aBirrJbxvQkA@mail.gmail.com>
	<20141116023423.GA31016@kroah.com>
Reply-To: sedat.dilek@gmail.com
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Dan Williams <dcbw@redhat.com>,
	"David S. Miller" <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	linux-usb@vger.kernel.org,
	Aleksander Morgado <aleksander@aleksander.es>
To: Greg KH <greg@kroah.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wg0-f50.google.com ([74.125.82.50]:58896 "EHLO
	mail-wg0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755183AbaKPCsK convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 15 Nov 2014 21:48:10 -0500
In-Reply-To: <20141116023423.GA31016@kroah.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Nov 16, 2014 at 3:34 AM, Greg KH <greg@kroah.com> wrote:
> On Sun, Nov 16, 2014 at 02:40:15AM +0100, Sedat Dilek wrote:
>> On Sat, Nov 15, 2014 at 9:07 PM, Greg KH <greg@kroah.com> wrote:
>> > On Sat, Nov 15, 2014 at 10:23:55AM +0100, Sedat Dilek wrote:
>> >> On Fri, Nov 14, 2014 at 5:18 PM, Dan Williams <dcbw@redhat.com> w=
rote:
>> >> > On Fri, 2014-11-14 at 11:56 +0100, Sedat Dilek wrote:
>> >> >> On Wed, Nov 12, 2014 at 2:21 PM, Sedat Dilek <sedat.dilek@gmai=
l.com> wrote:
>> >> >> > On Tue, Nov 4, 2014 at 5:55 PM, Dan Williams <dcbw@redhat.co=
m> wrote:
>> >> >> >> On Tue, 2014-11-04 at 16:11 +0100, Sedat Dilek wrote:
>> >> >> >>> Hi,
>> >> >> >>>
>> >> >> >>> I wanted to understand what is going on the kernel-side wh=
en
>> >> >> >>> connecting to the Internet via a Huawei E173 USB web-stick=
 (3rd
>> >> >> >>> Generation: UMTS / HSPA).
>> >> >> >>>
>> >> >> >>> Especially the correlation between the diverse USB/NET ker=
nel-drivers
>> >> >> >>> and how the networking is setup.
>> >> >> >>
>> >> >> >
>> >> >> > [ Sitting in front of a foreign Windows machine ]
>> >> >> >
>> >> >> > [ CC Aleksander ]
>> >> >> >
>> >> >> > Hi Dan,
>> >> >> >
>> >> >> > sorry for the late (and short) response.
>> >> >> >
>> >> >> > AFAICS you have given a "skeleton" for a "usb-wwan-networkin=
g"
>> >> >> > documentation :-).
>> >> >> >
>> >> >> > Personally, I would like to take into account some kernel-co=
nfig
>> >> >> > options and some more things.
>> >> >> >
>> >> >>
>> >> >> I started with documenting...
>> >> >>
>> >> >> I have still some difficulties in understanding USB WWAN Netwo=
rking.
>> >> >> So, this is what I revealed...
>> >> >>
>> >> >> ##### USB: HUAWEI E173 3G/UMTS/HSPA INTERNET STICK
>> >> >>
>> >> >> ### USB-NETWORKING AND WWAN SETUP
>> >> >> CONFIG_USB_USBNET=3Dm        <--- usb networking
>> >> >> CONFIG_USB_NET_CDCETHER=3Dm  <--- usb-wwan (net) configuration
>> >> >> CONFIG_USB_SERIAL_WWAN=3Dm   <--- usb-wwan (serial) configurat=
ion
>> >> >> CONFIG_USB_SERIAL_OPTION=3Dm <--- usb-serial driver called "op=
tion"
>> >> >
>> >> > Most WWAN devices actually require option, because most WWAN de=
vices
>> >> > have "serial" ports (even if they aren't used for PPP), and 'op=
tion' is
>> >> > the driver that handles this.  The 'option' name is historic, b=
ut the
>> >> > driver should really be called something like 'wwan-serial-gene=
ric' or
>> >> > something like that.
>> >> >=C3=B6"
>> >>
>> >> Is there sth. against renaming the "option" driver to "wwan-seria=
l-generic"?
>> >
>> > Yes, people's scripts might break that are hard-coded to use the
>> > "option" driver.
>> >
>>
>> As far as I read on LKML... breaking userspace is a reason not to do
>> such changes.
>
> Exactly.
>
>> That's really a reason not to break "handmade" scripts on some machi=
nes?
>
> Yes.
>
>> As this is new to me... is that documented?
>
> It's our "culture" :)
>

OK.

>> Surely, it's fretful to change scripts, but life is change.
>> For me there is a more reasonable thing... Did you grep for "option"
>> pattern in the kernel sources?
>> Try.... :-).
>
> Oh I know, I wrote the first version of this driver and named it this=
 :)
>

Ah, IIRC the company was called so.

>> > greg "here, have a vowel, they are cheap" k-h
>>
>> Hmm, being a non-English native, I am not sure to get this...
>> What about languages from mostly Eastern countries having so much
>> consonants in a single word like Russian, Polish, etc.
>> Not every language is rich like German which has WOWels like "=C3=A4=
" (ae)
>> "=C3=B6" (oe) "=C3=BC" (ue).
>
> I was referring to your "sth." abbreviation above.
>

Hmm, I thought this is a "normal" abbreviation.
Maybe I should not mix IRC and Email writing styles.

Thanks for your comments.

- Sedat -

P.S.: /me was reading about the systemd transition (now default
init-system) and reading about Joey Hess leaving Debian, Damn and I
initiated the Debian systemd wiki. If I ever knew... Life is change
and neat and polite people died (I lost my parents the last two
years).

> thanks,
>
> greg k-h
