From: "ASIX Allan Email [office]" <allan@asix.com.tw>
Subject: RE: asix, setting MAC broken in v3.2. Bisected to "NET: fix phy init for AX88772 USB ethernet".
Date: Tue, 10 Jan 2012 13:27:39 +0800
Message-ID: <002801cccf58$92fe41f0$b8fac5d0$@com.tw>
References: <20120106131051.92814bd4b7x0nmqs@www.81.fi> <CANEJEGvXST4YzDL4kuF=kjZBN=ng-bC5UptCU2zk6JUmhpVjmg@mail.gmail.com> <20120108171802.287811bpiixnymys@www.81.fi> <002001ccce1a$3c5337a0$b4f9a6e0$@com.tw> <20120109125324.14414ynmnofsl5gc@www.81.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: <netdev@vger.kernel.org>, "'Freddy Xin'" <freddy@asix.com.tw>,
	"'Olof Johansson'" <olofj@chromium.org>,
	"'David S. Miller'" <davem@davemloft.net>,
	"'David Hollis'" <dhollis@davehollis.com>,
	=?UTF-8?B?QVNJWCBMb3VpcyBb6JiH5aiB6Zm4XQ==?= <louis@asix.com.tw>
To: "'Jussi Kivilinna'" <jussi.kivilinna@mbnet.fi>,
	"'Grant Grundler'" <grundler@chromium.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from asix.com.tw ([113.196.140.82]:63484 "EHLO asix.com.tw"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751017Ab2AJF1n convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 10 Jan 2012 00:27:43 -0500
In-Reply-To: 
Content-Language: zh-tw
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Dear Jussi and Grant,

Your driver patch should be OK, but you should also need to add the sim=
ilar driver patch in the ax88178_reset() routine. =20

This issue was caused by the reload EEPROM operation in the ax88772_res=
et() (and ax88178_reset()) routine that will overwrite the Node ID regi=
ster setting by using the MAC address setting from EEPROM. So you need =
to re-write the user defined MAC address after reloading the EEPROM in =
your test case.=20

You can submit the driver patches onto Linux kernel mainline source if =
you don't have other concerns. If you need us to submit it from our sit=
e, please feel free to let us know. Thanks a lot in advance.

=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
<<< Plugged in AX88772 dongle here >>>
[ 1395.199892] asix 1-1:1.0: eth0: register 'asix' at usb-0000:02:03.0-=
1, ASIX AX88772 USB 2.0 Ethernet, 00:0e:c6:87:72:02
[ 1395.199949] usbcore: registered new interface driver asix
[ 1395.464389] udev: renamed network interface eth0 to eth11
[ 1395.469491] ax88772_reset: #10 Node ID Register MAC address =3D 00 0=
e c6 87 72 02
[ 1395.489812] ax88772_reset: #11 Node ID Register MAC address =3D 00 0=
e c6 87 72 02
[ 1395.491980] ax88772_reset: #12 Node ID Register MAC address =3D 00 0=
e c6 87 72 02
[ 1395.652582] ax88772_reset: #13 Node ID Register MAC address =3D 00 0=
e c6 87 72 02
[ 1395.812136] ax88772_reset: #14 Node ID Register MAC address =3D 00 0=
e c6 87 72 02
[ 1395.971982] ax88772_reset: #15 Node ID Register MAC address =3D 00 0=
e c6 87 72 02
[ 1396.330473] ax88772_reset: #1 Node ID Register MAC address =3D 00 0e=
 c6 87 72 02
[ 1396.332009] ax88772_reset: EEPROM MAC address =3D 00 0e c6 87 72 02
[ 1396.333638] ax88772_reset: #1 Node ID Register MAC address =3D 00 0e=
 c6 87 72 02
[ 1396.339841] ADDRCONF(NETDEV_UP): eth11: link is not ready
[ 1398.399696] ADDRCONF(NETDEV_CHANGE): eth11: link becomes ready
[ 1398.432009] asix 1-1:1.0: eth11: link up, 100Mbps, full-duplex, lpa =
0xC1E1
[ 1408.864780] eth11: no IPv6 routers present

<<< Run "ifconfig eth11 down" command here >>>
<<< Run "ifconfig eth11 hw ether 02:12:34:56:78:9a" command here >>>
[ 1447.816565] asix_set_mac_address: Beginning.....
[ 1448.620602] asix_set_mac_address: #1 Node ID Register MAC address =3D=
 00 0e c6 87 72 02
[ 1448.620617] asix_set_mac_address: EEPROM MAC address =3D 02 12 34 56=
 78 9a
[ 1448.625896] asix_set_mac_address: #2 Node ID Register MAC address =3D=
 02 12 34 56 78 9a
[ 1448.625904] asix_set_mac_address: end.....

<<< Run "ifconfig eth11 up" command here >>>
[ 1452.661275] ax88772_reset: #10 Node ID Register MAC address =3D 02 1=
2 34 56 78 9a

<<< Run "ret =3D asix_write_gpio(dev, AX_GPIO_RSE | AX_GPIO_GPO_2 | AX_=
GPIO_GPO2EN, 5);" statement in ax88772_reset() routine to reload EEPROM=
 here (it will overwrite the Node ID register value by using the MAC ad=
dress setting from EEPROM >>>=20

Or <<< Run " asix_write_gpio(dev, AX_GPIO_RSE | AX_GPIO_GPO_1 | AX_GPIO=
_GPO1EN, 40); " statement in ax88178_reset() routine to reload EEPROM h=
ere (it will overwrite the Node ID register value by using the MAC addr=
ess setting from EEPROM >>>

[ 1452.678162] ax88772_reset: #11 Node ID Register MAC address =3D 00 0=
e c6 87 72 02
[ 1452.683305] ax88772_reset: #12 Node ID Register MAC address =3D 00 0=
e c6 87 72 02
[ 1452.843391] ax88772_reset: #13 Node ID Register MAC address =3D 00 0=
e c6 87 72 02
[ 1453.002635] ax88772_reset: #14 Node ID Register MAC address =3D 00 0=
e c6 87 72 02
[ 1453.163264] ax88772_reset: #15 Node ID Register MAC address =3D 00 0=
e c6 87 72 02
[ 1453.527994] ax88772_reset: #1 Node ID Register MAC address =3D 00 0e=
 c6 87 72 02
[ 1453.530656] ax88772_reset: EEPROM MAC address =3D 02 12 34 56 78 9a
[ 1453.533076] ax88772_reset: #1 Node ID Register MAC address =3D 02 12=
 34 56 78 9a
[ 1455.428494] asix 1-1:1.0: eth11: link up, 100Mbps, full-duplex, lpa =
0xC1E1
[ 1463.953124] eth11: no IPv6 routers present


---
Best regards,
Allan Chou
Technical Support Division
ASIX Electronics Corporation
TEL: 886-3-5799500 ext.228
=46AX: 886-3-5799558
E-mail: allan@asix.com.tw=20
http://www.asix.com.tw/=20

-----Original Message-----
=46rom: ASIX Allan Email [office] [mailto:allan@asix.com.tw]=20
Sent: Tuesday, January 10, 2012 9:54 AM
To: 'Jussi Kivilinna'; 'Grant Grundler'
Cc: 'netdev@vger.kernel.org'; 'Freddy Xin'; 'Olof Johansson'; 'David S.=
 Miller'; 'David Hollis'
Subject: RE: asix, setting MAC broken in v3.2. Bisected to "NET: fix ph=
y init for AX88772 USB ethernet".

Dear Jussi and Grant,

As I know, the manually changed MAC address function should be handled =
by the "asix_set_mac_address()" routine but not need to enable the prom=
iscuous mode. If you enabled the driver promiscuous mode, the asix.c dr=
iver will receive all Ethernet packets without checking the DA field of=
 the received packets. I suppose this should not be a good solution to =
solve this issue for normal operation cases.=20

I will try to reproduce your issue in our site and look into why the "a=
six_set_mac_address()" routine doesn't work as expected? If I got any r=
esults, I will let you know ASAP. Thanks a lot. =20


---
Best regards,
Allan Chou
Technical Support Division
ASIX Electronics Corporation
TEL: 886-3-5799500 ext.228
=46AX: 886-3-5799558
E-mail: allan@asix.com.tw=20
http://www.asix.com.tw/=20

-----Original Message-----
=46rom: grundler@google.com [mailto:grundler@google.com] On Behalf Of G=
rant Grundler
Sent: Tuesday, January 10, 2012 9:38 AM
To: Jussi Kivilinna
Cc: netdev@vger.kernel.org; Freddy Xin; Olof Johansson; David S. Miller=
; David Hollis; Allan Chou
Subject: Re: asix, setting MAC broken in v3.2. Bisected to "NET: fix ph=
y init for AX88772 USB ethernet".

On Mon, Jan 9, 2012 at 9:21 AM, Grant Grundler <grundler@chromium.org> =
wrote:
=2E..
>> Patch attached.
>
> I'll try the patch here to confirm. Thanks!

Jussi,
I can confirm you patch doesn't break my basic use case:
  Acked-By: Grant Grundler <grundler@chromium.org>


localhost ~ # ifconfig eth0
eth0      Link encap:Ethernet  HWaddr 00:00:00:00:08:b3
          inet addr:XX.XX.XX.1  Bcast:XX.XX.XX.255  Mask:255.255.252.0
=2E..
          UP BROADCAST RUNNING MULTICAST  MTU:1500  Metric:1
          RX packets:500 errors:0 dropped:19 overruns:0 frame:0
          TX packets:320 errors:0 dropped:0 overruns:0 carrier:0
          collisions:0 txqueuelen:1000
          RX bytes:110020 (107.4 KiB)  TX bytes:43569 (42.5 KiB)

localhost ~ # dmesg | fgrep eth0
[    2.049163] asix 1-4:1.0: eth0: register 'asix' at
usb-0000:00:1d.7-4, ASIX AX88772 USB 2.0 Ethernet, 00:00:00:00:08:b3
[    3.693169] ADDRCONF(NETDEV_UP): eth0: link is not ready
[    5.515078] ADDRCONF(NETDEV_CHANGE): eth0: link becomes ready
[    5.518469] asix 1-4:1.0: eth0: link up, 100Mbps, full-duplex, lpa 0=
xCDE1
localhost ~ #

-----Original Message-----
=46rom: grundler@google.com [mailto:grundler@google.com] On Behalf Of G=
rant Grundler
Sent: Tuesday, January 10, 2012 1:22 AM
To: Jussi Kivilinna
Cc: netdev@vger.kernel.org; Freddy Xin; Olof Johansson; David S. Miller=
; David Hollis; Allan Chou
Subject: Re: asix, setting MAC broken in v3.2. Bisected to "NET: fix ph=
y init for AX88772 USB ethernet".

On Sun, Jan 8, 2012 at 7:18 AM, Jussi Kivilinna
<jussi.kivilinna@mbnet.fi> wrote:
=2E..
> It's Wii Ethernet adapter,
> Bus 001 Device 008: ID 0b95:7720 ASIX Electronics Corp. AX88772

=2E..
> Both attached.

[lsusb/dmesg  output]  Thanks!

=2E..
> I found out that setting MAC in ax88722_reset() solves the issue for =
me.
> Maybe changes to init/reset sequence causes hardware to be reseted af=
ter
> set_mac_address call and revert to default MAC?

That's exactly what I was thinking too over the weekend.


> Patch attached.

I'll try the patch here to confirm. Thanks!

cheers,
grant

-----Original Message-----
=46rom: Jussi Kivilinna [mailto:jussi.kivilinna@mbnet.fi]=20
Sent: Monday, January 09, 2012 6:53 PM
To: allan
Cc: 'Grant Grundler'; netdev@vger.kernel.org; 'Freddy Xin'; 'Olof Johan=
sson'; 'David S. Miller'; 'David Hollis'
Subject: RE: asix, setting MAC broken in v3.2. Bisected to "NET: fix ph=
y init for AX88772 USB ethernet".

Hello,

Yes, that is exactly what I have for interface initialization. System =20
is running Debian Squeeze, with following entry in =20
/etc/network/interfaces:

  # wan1 is asix device
  auto wan1
  iface wan1 inet dhcp
          pre-up /etc/network/change-mac-addr-to.sh wan1 00:02:xx:xx:xx=
:xx

and change-mac-addr-to.sh is:

  #!/bin/sh

  # check if mac address already set
  if [ "$(ifconfig "$1" | grep HWaddr | grep "$2")" =3D "" ]; then
          # set new mac
          ifconfig "$1" down
          ifconfig "$1" hw ether "$2"
          ifconfig "$1" up

          echo Changed MAC-address for interface $1 to $2
  fi

  exit 0

This works with kernel v3.1, but not with v3.2. Not working means: 1. =20
DHCP does not work on wan1/asix, does not receive answer from DHCP =20
server. 2. PPPoE connection doesn't initialize over wan1/asix. (DHCP =20
is for ISP private/local network and Internet connection is through =20
PPPoE).

With v3.2 I found out that enabling promisc for wan1 interface =20
(ifconfig wan1 promisc 1) allows DHCP and PPPoE to make connection and =
=20
to work.

Also the patch attached in previous message (patch is for kernel v3.2) =
=20
fixes the problem (for me).

-Jussi

Quoting allan <allan@asix.com.tw>:

> Dear Jussi,
>
> Please help to double check if the following information is helpful =20
> to solve your issue or not? If no, please deliver us your test
asix.c
> driver file and detailed test procedures for further investigation. =20
> Thanks a lot.
>
> =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
> Actually, if you just want to manually set the MAC address of your =20
> AX88772B/AX88772A/AX88178 devices for engineering testing, you can =20
> refer to below procedures to temporary change the MAC address of
your
> AX88772B/AX88772A/AX88178 device on Linux platform through the =20
> =E2=80=9Cax8817x_set_mac_addr()=E2=80=9D routine of AX88772B/AX88772A=
/AX88178
Linux
> driver source code.
>
> How to change MAC address in Linux
>
http://linuxhelp.blogspot.com/2005/09/how-to-change-mac-address-of-your=
=2Ehtml
>
> # ifconfig eth0 down
> # ifconfig eth0 hw ether 00:80:48:BA:d1:30
> # ifconfig eth0 up
>
>
> ---
> Best regards,
> Allan Chou
> Technical Support Division
> ASIX Electronics Corporation
> TEL: 886-3-5799500 ext.228
> FAX: 886-3-5799558
> E-mail: allan@asix.com.tw
> http://www.asix.com.tw/
>
> -----Original Message-----
> From: Jussi Kivilinna [mailto:jussi.kivilinna@mbnet.fi]
> Sent: Sunday, January 08, 2012 11:18 PM
> To: Grant Grundler
> Cc: netdev@vger.kernel.org; Freddy Xin; Olof Johansson; David S. =20
> Miller; David Hollis; Allan Chou
> Subject: Re: asix, setting MAC broken in v3.2. Bisected to "NET: fix

> phy init for AX88772 USB ethernet".
>
> Quoting Grant Grundler <grundler@chromium.org>:
>
>> On Fri, Jan 6, 2012 at 3:10 AM, Jussi Kivilinna
>> <jussi.kivilinna@mbnet.fi> wrote:
>>> Hello,
>>>
>>> I have asix adapter plugged to mini-server
>>
>> Which Asix adapter do you have? (Vendor/model)
>
> It's Wii Ethernet adapter,
> Bus 001 Device 008: ID 0b95:7720 ASIX Electronics Corp. AX88772
>
>>
>> Can you please provide:
>> 1) dmesg output from asix driver
>> 2) lsusb output for the device
>
> Both attached.
>
>>> and have to change MAC address
>>> before DHCP because of ISP. This worked fine, until v3.2. Now I
have to set
>>> interface in promisc mode to have custom MAC working.
>>
>> Sorry - I didn't test this but I also would not expect this to
break
>> with the changes in 3.2.
>>
>> I'll see if Freddy or Allan (ASIX) need my help with this.
>
> I found out that setting MAC in ax88722_reset() solves the issue for
> me. Maybe changes to init/reset sequence causes hardware to be
reseted
> after set_mac_address call and revert to default MAC?
>
> Patch attached.
>
> -Jussi
>
>
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>
>
