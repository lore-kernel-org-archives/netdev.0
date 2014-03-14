From: Pasi =?iso-8859-1?Q?K=E4rkk=E4inen?= <pasik-X3B1VOXEql0@public.gmane.org>
Subject: Re: [PATCH net-next v6 0/3] The huawei_cdc_ncm driver / E3276
 problem
Date: Fri, 14 Mar 2014 14:59:34 +0200
Message-ID: <20140314125934.GC3200@reaktio.net>
References: <1383555049-24834-1-git-send-email-bjorn@mork.no>
 <20140313202557.GV3200@reaktio.net>
 <1394746907.15946.8.camel@dcbw.local>
 <20140313220812.GW3200@reaktio.net>
 <20140314075548.GX3200@reaktio.net>
 <87wqfxnppc.fsf@nemi.mork.no>
 <20140314084159.GA3200@reaktio.net>
 <87siqlnol8.fsf@nemi.mork.no>
 <20140314090525.GB3200@reaktio.net>
 <87ob19nndo.fsf@nemi.mork.no>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Dan Williams <dcbw-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Enrico Mioso <mrkiko.rs-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	Oliver Neukum <oliver-GvhC2dPhHPQdnm+yROfE0A@public.gmane.org>
To: =?iso-8859-1?Q?Bj=F8rn?= Mork <bjorn-yOkvZcmFvRU@public.gmane.org>
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <87ob19nndo.fsf-lbf33ChDnrE/G1V5fR+Y7Q@public.gmane.org>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Fri, Mar 14, 2014 at 10:24:51AM +0100, Bj=F8rn Mork wrote:
> Pasi K=E4rkk=E4inen <pasik-X3B1VOXEql0@public.gmane.org> writes:
>=20
> > # ifconfig wwp0s26u1u5i1
> > wwp0s26u1u5i1: flags=3D4163<UP,BROADCAST,RUNNING,MULTICAST>  mtu 15=
00
> >         inet 10.8.219.204  netmask 255.255.255.248  broadcast 10.8.=
219.207
> >         inet6 fe80::e5b:8fff:fe27:9a64  prefixlen 64  scopeid 0x20<=
link>
> >         ether 0c:5b:8f:27:9a:64  txqueuelen 1000  (Ethernet)
> >         RX packets 0  bytes 0 (0.0 B)
> >         RX errors 1493  dropped 0  overruns 0  frame 0
> >
> > Note the RX errors.. ?=20
>=20
>=20
> Yes, that is not expected and is quite possibly hiding the explanatio=
n.
>=20

Ok, good to know.

> Could you do a usbmon dump to try to capture the contents of the USB
> buffers we drop here?  See
> https://www.kernel.org/doc/Documentation/usb/usbmon.txt
>=20
> Note that the text interface may truncate the buffers too early for t=
he
> result to be useful.  wireshark/thsark will for example allow you to
> capture the whole buffer (when snooping on the "usbmonX" interface - =
not
> the netdev!)
>=20

I'll try that..=20

> We also have a few debug messages in the driver for different types o=
f
> errors we drop.  Turning on those might explain something (assuming y=
ou
> have DYNAMIC_DEBUG enabled):
>=20
>   ethtool -s wwp0s26u1u5i1 msglvl rx_err on
>=20
> Note that these will be logged at "debug" level, so you need to turn =
on
> logging/showing such messages as well.
>=20

# uname -a
Linux localhost.localdomain 3.13.6-200.fc20.x86_64 #1 SMP Fri Mar 7 17:=
02:28 UTC 2014 x86_64 x86_64 x86_64 GNU/Linux

# grep -i DYNAMIC_DEBUG /boot/config-3.13.6-200.fc20.x86_64
CONFIG_DYNAMIC_DEBUG=3Dy

# echo 8 > /proc/sys/kernel/printk
# cat /proc/sys/kernel/printk
8       4       1       7

# ethtool -s wwp0s26u1u5i1 msglvl rx_err on

Is that enough? I don't see any errors logged in "dmesg" output,
but the RX errors counters do keep increasing in ifconfig output..=20

>=20
>=20
> Bj=F8rn

Thanks,


-- Pasi

--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
