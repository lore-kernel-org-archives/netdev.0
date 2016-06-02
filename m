From: =?utf-8?Q?Bj=C3=B8rn_Mork?= <bjorn@mork.no>
Subject: Re: [PATCH] r8152: Add support for setting MAC to system's Auxiliary MAC address
Date: Thu, 02 Jun 2016 09:27:28 +0200
Message-ID: <87lh2oyrrz.fsf@nemi.mork.no>
References: <1464817844-27206-1-git-send-email-mario_limonciello@dell.com>
	<20160601230535.GA29279@kroah.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Greg KH <gregkh@linuxfoundation.org>, hayeswang@realtek.com,
	LKML <linux-kernel@vger.kernel.org>,
	Netdev <netdev@vger.kernel.org>,
	Linux USB <linux-usb@vger.kernel.org>, pali.rohar@gmail.com,
	anthony.wong@canonical.com
To: Mario Limonciello <mario_limonciello@dell.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20160601230535.GA29279@kroah.com> (Greg KH's message of "Wed, 1
	Jun 2016 16:05:35 -0700")
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Greg KH <gregkh@linuxfoundation.org> writes:

> And finally, this seems odd overall given that a MAC address should b=
e
> associated with the specific network device, not the overall system.

Definitely.

I wonder if this isn't a perfect candidate for an x86
arch_get_platform_mac_address() implementation?  Then you could just us=
e
the eth_platform_get_mac_address() helper in the driver and avoid any
platform specific code there.  Which will automagically make it work as
expected on a Sparc too :)

This will also make your job next year much easier, when the hardeware
guys decided to replace the chip and you need to implement the exact
same code in some other driver...

See https://patchwork.ozlabs.org/patch/564100/ for a detailed
discussion of this interface.


Bj=C3=B8rn
