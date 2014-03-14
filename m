From: Pasi =?iso-8859-1?Q?K=E4rkk=E4inen?= <pasik-X3B1VOXEql0@public.gmane.org>
Subject: Re: [PATCH net-next v6 0/3] The huawei_cdc_ncm driver / E3276
 problem
Date: Fri, 14 Mar 2014 19:33:36 +0200
Message-ID: <20140314173336.GF3200@reaktio.net>
References: <20140314075548.GX3200@reaktio.net>
 <87wqfxnppc.fsf@nemi.mork.no>
 <20140314084159.GA3200@reaktio.net>
 <87siqlnol8.fsf@nemi.mork.no>
 <20140314090525.GB3200@reaktio.net>
 <87ob19nndo.fsf@nemi.mork.no>
 <20140314125934.GC3200@reaktio.net>
 <87vbvgnbv3.fsf@nemi.mork.no>
 <20140314142559.GD3200@reaktio.net>
 <1394817415.5829.6.camel@dcbw.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: =?iso-8859-1?Q?Bj=F8rn?= Mork <bjorn-yOkvZcmFvRU@public.gmane.org>,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	Enrico Mioso <mrkiko.rs-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	Oliver Neukum <oliver-GvhC2dPhHPQdnm+yROfE0A@public.gmane.org>
To: Dan Williams <dcbw-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <1394817415.5829.6.camel-ZWpNTBV2bRGs1BDpvl8NfQ@public.gmane.org>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Fri, Mar 14, 2014 at 12:16:55PM -0500, Dan Williams wrote:
> On Fri, 2014-03-14 at 16:25 +0200, Pasi K=E4rkk=E4inen wrote:
> > On Fri, Mar 14, 2014 at 02:33:36PM +0100, Bj=F8rn Mork wrote:
> > > Pasi K=E4rkk=E4inen <pasik-X3B1VOXEql0@public.gmane.org> writes:
> > > > On Fri, Mar 14, 2014 at 10:24:51AM +0100, Bj=F8rn Mork wrote:
> > > >> Pasi K=E4rkk=E4inen <pasik-X3B1VOXEql0@public.gmane.org> writes:
> > > >>=20
> > > >> > # ifconfig wwp0s26u1u5i1
> > > >> > wwp0s26u1u5i1: flags=3D4163<UP,BROADCAST,RUNNING,MULTICAST> =
 mtu 1500
> > > >> >         inet 10.8.219.204  netmask 255.255.255.248  broadcas=
t 10.8.219.207
> > > >> >         inet6 fe80::e5b:8fff:fe27:9a64  prefixlen 64  scopei=
d 0x20<link>
> > > >> >         ether 0c:5b:8f:27:9a:64  txqueuelen 1000  (Ethernet)
> > > >> >         RX packets 0  bytes 0 (0.0 B)
> > > >> >         RX errors 1493  dropped 0  overruns 0  frame 0
> > > >> >
> > > >> > Note the RX errors.. ?=20
> > > >>=20
> > > >>=20
> > > >> Yes, that is not expected and is quite possibly hiding the exp=
lanation.
> > > >>=20
> > > >
> > > > Ok, good to know.
> > > >
> > > >> Could you do a usbmon dump to try to capture the contents of t=
he USB
> > > >> buffers we drop here?  See
> > > >> https://www.kernel.org/doc/Documentation/usb/usbmon.txt
> > > >>=20
> > > >> Note that the text interface may truncate the buffers too earl=
y for the
> > > >> result to be useful.  wireshark/thsark will for example allow =
you to
> > > >> capture the whole buffer (when snooping on the "usbmonX" inter=
face - not
> > > >> the netdev!)
> > > >>=20
> > > >
> > > > I'll try that..=20
> > > >
> > > >> We also have a few debug messages in the driver for different =
types of
> > > >> errors we drop.  Turning on those might explain something (ass=
uming you
> > > >> have DYNAMIC_DEBUG enabled):
> > > >>=20
> > > >>   ethtool -s wwp0s26u1u5i1 msglvl rx_err on
> > > >>=20
> > > >> Note that these will be logged at "debug" level, so you need t=
o turn on
> > > >> logging/showing such messages as well.
> > > >>=20
> > > >
> > > > # uname -a
> > > > Linux localhost.localdomain 3.13.6-200.fc20.x86_64 #1 SMP Fri M=
ar 7 17:02:28 UTC 2014 x86_64 x86_64 x86_64 GNU/Linux
> > > >
> > > > # grep -i DYNAMIC_DEBUG /boot/config-3.13.6-200.fc20.x86_64
> > > > CONFIG_DYNAMIC_DEBUG=3Dy
> > > >
> > > > # echo 8 > /proc/sys/kernel/printk
> > > > # cat /proc/sys/kernel/printk
> > > > 8       4       1       7
> > > >
> > > > # ethtool -s wwp0s26u1u5i1 msglvl rx_err on
> > > >
> > > > Is that enough?
> > >=20
> > > I believe so, but I don't feel too steady on all the dynamic-ness=
 here.
> > >=20
> > > > I don't see any errors logged in "dmesg" output,
> > > > but the RX errors counters do keep increasing in ifconfig outpu=
t..=20
> > >=20
> > > OK, let's see if we can figure it out based on the usbmon data.
> > >=20
> >=20
> > http://pasik.reaktio.net/huawei-e3276-usbmon3.pcapng
> >=20
> > (I did move the dongle to a different usb bus nr 3 to make it the o=
nly device on that bus before capturing..)=20
> >=20
> > So what I did:
> >=20
> > - Start wireshark capture on USB bus nr 3.
> > - Plug in the Huawei E3276 dongle.
> > - Wait for usb_modeswitch to happen.
> > - Use minicom to talk to /dev/cdc-wdm0 and send AT commands to conn=
ect to Internet:
> > 	- ATQ0 V1 E1 S0=3D0
> > 	- AT^NDISDUP=3D1,1,"internet"
>=20
> Are you sure the device has actually registered with the network at t=
he
> point you do the NDISDUP?  At this point what do you get for "AT+CREG=
?"
> and "AT+CFUN?" ?
>=20

When capturing the USB traffic I did get the ^NDISSTAT:1,,,"IPV4" notif=
ication and the AT^DHCP?=20
command showed the IP address and other info so I *assume* it was prope=
rly connected..=20
also the LED on the dongle showed it's connected..

So now a fresh start.. Before running NDISDUP I send AT+CREG? and I get=
 this reply:

+CREG: 0,1

Then I send AT+CFUN? and get this reply:

+CFUN: 1

Then I send AT^NDISDUP=3D1,1,"internet" and get:

OK
^RSSI: 7
^NDISSTAT:1,,,"IPV4"

Then I send AT^DHCP? and get:

^DHCP: 4A503D0A,FCFFFFFF,49503D0A,49503D0A,E67B59C0,E77B59C0,85600,8560=
0
OK


Does that look OK?=20

Thanks,

-- Pasi


> Dan
>=20
> > - After the dongle has connected query for DHCP status:
> > 	- AT^DHCP?
> >=20
> > - Launch dhcp client (dhclient) on wwp0s20u1i1 interface.
> > - Wait for a while and see RX error counters increasing on ifconfig=
 output.
> > - Cancel (ctrl+c) the dhclient.
> > - Stop wireshark capture.=20
> >=20
> >=20
> > Does that capture file show anything interesting to you?=20
> >=20
> > >=20
> > >=20
> > > Bj=F8rn
> >=20
> >=20
> > Thanks,
> >=20
> > -- Pasi
> >=20
> > --
> > To unsubscribe from this list: send the line "unsubscribe netdev" i=
n
> > the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
> > More majordomo info at  http://vger.kernel.org/majordomo-info.html
>=20
>=20
--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
