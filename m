From: =?utf-8?Q?Bj=C3=B8rn_Mork?= <bjorn@mork.no>
Subject: Re: [PATCH] r8152: Add support for setting MAC to system's Auxiliary MAC address
Date: Thu, 02 Jun 2016 10:11:10 +0200
Message-ID: <8760tsypr5.fsf@nemi.mork.no>
References: <1464817844-27206-1-git-send-email-mario_limonciello@dell.com>
	<20160601230535.GA29279@kroah.com>
	<cfff846f3ca34b6a889f07f971b27271@ausx13mpc124.AMER.DELL.COM>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: <gregkh@linuxfoundation.org>, <hayeswang@realtek.com>,
	<linux-kernel@vger.kernel.org>, <netdev@vger.kernel.org>,
	<linux-usb@vger.kernel.org>, <pali.rohar@gmail.com>,
	<anthony.wong@canonical.com>
To: <Mario_Limonciello@Dell.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <cfff846f3ca34b6a889f07f971b27271@ausx13mpc124.AMER.DELL.COM>
	(Mario Limonciello's message of "Thu, 2 Jun 2016 02:53:06 +0000")
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

<Mario_Limonciello@Dell.com> writes:

>> > +static u8 amac_ascii_to_hex(int c)
>> > +{
>> > +	if (c <=3D 0x39)
>> > +		return (u8)(c - 0x30);
>> > +	else if (c <=3D 0x46)
>> > +		return (u8)(c - 0x37);
>> > +	return (u8)(c - 0x57);
>> > +}
>>=20
>
> Sorry forgot to address this. =20
>
>> We really don't have such a function somewhere in the kernel already=
?
>
> There is a function in acpi/acpica/uthex.c that does this, but it doe=
sn't seem to be used by anything outside of acpica so far.  Would it be=
 OK style wise to=20
> #include " ../../acpi/acpica/acutils.h" from r8152.c? =20

Makes me wonder where you looked....  You have hex_to_bin() and
hex2bin() in include/linux/kernel.h

You could look at usbnet_get_ethernet_addr() for an example of how to d=
o
this properly.  It's pretty close to this driver in the tree, and shoul=
d
be a natural starting point before reinventing the wheel...



Bj=C3=B8rn
