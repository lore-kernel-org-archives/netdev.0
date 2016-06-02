From: =?utf-8?Q?Bj=C3=B8rn_Mork?= <bjorn@mork.no>
Subject: Re: [PATCH] r8152: Add support for setting MAC to system's Auxiliary MAC address
Date: Thu, 02 Jun 2016 20:04:02 +0200
Message-ID: <87vb1rwjql.fsf@nemi.mork.no>
References: <1464817844-27206-1-git-send-email-mario_limonciello@dell.com>
	<20160601230535.GA29279@kroah.com>
	<0bdb98b72b884682b936c0587f965629@ausx13mpc124.AMER.DELL.COM>
	<20160602152244.GA26494@kroah.com>
	<6d9575fd791c4e25b464b9a1b11daa83@ausx13mpc124.AMER.DELL.COM>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: <gregkh@linuxfoundation.org>, <hayeswang@realtek.com>,
	<linux-kernel@vger.kernel.org>, <netdev@vger.kernel.org>,
	<linux-usb@vger.kernel.org>, <pali.rohar@gmail.com>,
	<anthony.wong@canonical.com>
To: <Mario_Limonciello@Dell.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <6d9575fd791c4e25b464b9a1b11daa83@ausx13mpc124.AMER.DELL.COM>
	(Mario Limonciello's message of "Thu, 2 Jun 2016 15:46:41 +0000")
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

<Mario_Limonciello@Dell.com> writes:

>> > 2) Track whether this is the first or second USB NIC plugged in.  =
Only offer it
>> on the first NIC detected by r8152.  When the second NIC is plugged =
in don't
>> match from ACPI.
>> > There would be a question of what to do if the first NIC is remove=
d and
>> added back if it should get the persistent system MAC or not.
>> > I'd say yes, just make sure that only one NIC can have it at a tim=
e.
>>=20
>> You are going to get things very complex very quickly if you try to =
do this.
>
> It's really not that hard, track a module wide static variable whethe=
r
> the feature is in use.  Track in each device whether the feature was
> in use.  If it in use, don't assign the next device plugged in via th=
e
> ACPI string.  If a device is removed that has the feature activated,
> change the module wide static variable.

Having the mac address jump around in an arbitrary way like this is
going to confuse the hell out of your users.  Consider what happens if
the user docks a laptop with an r8152 usb dongle already plugged in...
How are you going to explain that the dock gets some other mac address
in this case? How are you going to explain the difference between using
an r8152 based dongle and some other ethernet usb dongle with your
systems?

Make it behave consistently if you're going to add this.  Which can be
done by specifically matching the Dell dock (doesn't it have an unique
Dell device ID?) and ignoring any other r8152 device.  You could also
choose to set the same mac for all r8152 devices.  Which is fine, but
will probably confuse many users.

What you definitely should not do is to change the mac for some
arbitrary "first" device.  Then you are better off with the userspace
proposal where you and your users have some chance to implement a
sensible policy based on e.g. usb port numbers.



Bj=C3=B8rn
