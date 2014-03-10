From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH] net: phy: Add sysfs attribute to prevent PHY suspend
Date: Mon, 10 Mar 2014 09:56:49 -0700
Message-ID: <CAGVrzcaMn2gevGK2=NrGO6-V31XvExQANz89Mk=EGZqxjdmWSA@mail.gmail.com>
References: <531CF864.9040406@gmail.com> <20140309.203001.1318893833441564547.davem@davemloft.net>
 <531D094C.1090205@gmail.com> <20140309.204101.47552917508273123.davem@davemloft.net>
 <531D0D0D.4050703@gmail.com> <20140310142531.1fde5797@alan.etchedpixels.co.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Sebastian Hesselbarth <sebastian.hesselbarth@gmail.com>,
	David Miller <davem@davemloft.net>,
	Rob Landley <rob@landley.net>, Andrew Lunn <andrew@lunn.ch>,
	netdev <netdev@vger.kernel.org>,
	"linux-doc@vger.kernel.org" <linux-doc@vger.kernel.org>,
	"linux-arm-kernel@lists.infradead.org"
	<linux-arm-kernel@lists.infradead.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: One Thousand Gnomes <gnomes@lxorguk.ukuu.org.uk>
Return-path: <linux-doc-owner@vger.kernel.org>
In-Reply-To: <20140310142531.1fde5797@alan.etchedpixels.co.uk>
Sender: linux-doc-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

2014-03-10 7:25 GMT-07:00 One Thousand Gnomes <gnomes@lxorguk.ukuu.org.uk>:
> On Mon, 10 Mar 2014 01:53:33 +0100
> Sebastian Hesselbarth <sebastian.hesselbarth@gmail.com> wrote:
>
>> On 03/10/2014 01:41 AM, David Miller wrote:
>> > From: Sebastian Hesselbarth <sebastian.hesselbarth@gmail.com>
>> > Date: Mon, 10 Mar 2014 01:37:32 +0100
>> >
>> >> The mechanism is manual, no automatic way to determine it.
>> >
>> > We recognize BIOS and ACPI bugs and work around them, by looking at
>> > version information and whatnot, so you really can't convince me that
>> > something similar can't be done here perhaps in the platform code.
>>
>> Hmm, if the is a way to determine the version of that particual u-boot
>> I'd be happy to exploit that information.
>
> If there isn't a way for a kernel to determine the U-boot version then
> maybe that should get fixed instead. That also solves your problem
> because if you can't find the uboot version you know its too old.

Once you have fixed how to determine the u-boot version (which BTW, is
probably much simpler to determine from user-space by reading from the
MTD partition exposing it, and using strings on the binary blob), you
are left with the other bootloaders out there which also do not clear
the BMCR_PWRDOWN bit of your PHY and will fail booting off the network
as well.

While I agree that there should be something done to help any OS
determine which bootloader version/model it got booted from (ala. x86
with type_of_bootloader), we still need a way to control this policy
(auto-suspending the unused Ethernet PHYs) from Linux, regardless of
whether the boot program is broken or not.
-- 
Florian
