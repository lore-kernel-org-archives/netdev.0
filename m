From: "allan" <allan@asix.com.tw>
Subject: RE: asix, setting MAC broken in v3.2. Bisected to "NET: fix phy init for AX88772 USB ethernet".
Date: Sun, 8 Jan 2012 23:28:41 +0800
Message-ID: <002001ccce1a$3c5337a0$b4f9a6e0$@com.tw>
References: <20120106131051.92814bd4b7x0nmqs@www.81.fi> <CANEJEGvXST4YzDL4kuF=kjZBN=ng-bC5UptCU2zk6JUmhpVjmg@mail.gmail.com> <20120108171802.287811bpiixnymys@www.81.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: <netdev@vger.kernel.org>, "'Freddy Xin'" <freddy@asix.com.tw>,
	"'Olof Johansson'" <olofj@chromium.org>,
	"'David S. Miller'" <davem@davemloft.net>,
	"'David Hollis'" <dhollis@davehollis.com>
To: "'Jussi Kivilinna'" <jussi.kivilinna@mbnet.fi>,
	"'Grant Grundler'" <grundler@chromium.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from asix.com.tw ([113.196.140.82]:52214 "EHLO asix.com.tw"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752727Ab2AHP3b convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 8 Jan 2012 10:29:31 -0500
In-Reply-To: <20120108171802.287811bpiixnymys@www.81.fi>
Content-Language: zh-tw
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Dear Jussi,

Please help to double check if the following information is helpful to =
solve your issue or not? If no, please deliver us your test asix.c driv=
er file and detailed test procedures for further investigation. Thanks =
a lot.

=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
Actually, if you just want to manually set the MAC address of your AX88=
772B/AX88772A/AX88178 devices for engineering testing, you can refer to=
 below procedures to temporary change the MAC address of your AX88772B/=
AX88772A/AX88178 device on Linux platform through the =E2=80=9Cax8817x_=
set_mac_addr()=E2=80=9D routine of AX88772B/AX88772A/AX88178 Linux driv=
er source code.

How to change MAC address in Linux
http://linuxhelp.blogspot.com/2005/09/how-to-change-mac-address-of-your=
=2Ehtml=20

# ifconfig eth0 down
# ifconfig eth0 hw ether 00:80:48:BA:d1:30
# ifconfig eth0 up


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
=46rom: Jussi Kivilinna [mailto:jussi.kivilinna@mbnet.fi]=20
Sent: Sunday, January 08, 2012 11:18 PM
To: Grant Grundler
Cc: netdev@vger.kernel.org; Freddy Xin; Olof Johansson; David S. Miller=
; David Hollis; Allan Chou
Subject: Re: asix, setting MAC broken in v3.2. Bisected to "NET: fix ph=
y init for AX88772 USB ethernet".

Quoting Grant Grundler <grundler@chromium.org>:

> On Fri, Jan 6, 2012 at 3:10 AM, Jussi Kivilinna
> <jussi.kivilinna@mbnet.fi> wrote:
>> Hello,
>>
>> I have asix adapter plugged to mini-server
>
> Which Asix adapter do you have? (Vendor/model)

It's Wii Ethernet adapter,
Bus 001 Device 008: ID 0b95:7720 ASIX Electronics Corp. AX88772

>
> Can you please provide:
> 1) dmesg output from asix driver
> 2) lsusb output for the device

Both attached.

>> and have to change MAC address
>> before DHCP because of ISP. This worked fine, until v3.2. Now I have=
 to set
>> interface in promisc mode to have custom MAC working.
>
> Sorry - I didn't test this but I also would not expect this to break
> with the changes in 3.2.
>
> I'll see if Freddy or Allan (ASIX) need my help with this.

I found out that setting MAC in ax88722_reset() solves the issue for =20
me. Maybe changes to init/reset sequence causes hardware to be reseted =
=20
after set_mac_address call and revert to default MAC?

Patch attached.

-Jussi
