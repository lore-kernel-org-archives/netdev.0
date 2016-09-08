From: =?utf-8?Q?Bj=C3=B8rn_Mork?= <bjorn@mork.no>
Subject: Re: [PATCH net-next 0/3] r8152: configuration setting
Date: Thu, 08 Sep 2016 15:16:09 +0200
Message-ID: <8737lah6qu.fsf@miraculix.mork.no>
References: <1394712342-15778-215-Taiwan-albertk@realtek.com>
        <87h99rizsi.fsf@miraculix.mork.no>
        <0835B3720019904CB8F7AA43166CEEB2010259B5@RTITMBSV03.realtek.com.tw>
        <87vay6hlmc.fsf@miraculix.mork.no>
        <0835B3720019904CB8F7AA43166CEEB201026170@RTITMBSV03.realtek.com.tw>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable
Cc: "netdev\@vger.kernel.org" <netdev@vger.kernel.org>,
        nic_swsd <nic_swsd@realtek.com>,
        "linux-kernel\@vger.kernel.org" <linux-kernel@vger.kernel.org>,
        "linux-usb\@vger.kernel.org" <linux-usb@vger.kernel.org>,
        Oliver Neukum <oliver@neukum.org>
To: Hayes Wang <hayeswang@realtek.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <0835B3720019904CB8F7AA43166CEEB201026170@RTITMBSV03.realtek.com.tw>
        (Hayes Wang's message of "Thu, 8 Sep 2016 13:02:01 +0000")
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hayes Wang <hayeswang@realtek.com> writes:

> Bj=C3=B8rn Mork [mailto:bjorn@mork.no]
>> Sent: Thursday, September 08, 2016 3:55 PM
> [...]
>> Yes, I see that.  But is that strictly necessary? Couldn't you just say:
>> "CDC ECM is supported by cdc_ether and therefore limited to the features
>> implemented by cdc_ether.  If you want feature X, then please use our
>> vendor specific mode with the r8152 driver?"
>
> My customs have a case that they must force the speed to 100M
> for some reasons. I also wish to implement the driver as simple
> as possible, but I don't think I could determine this. I accept
> you reject my patches. However, I couldn't deny the requests
> from the boss or customs without doing anything. I must prove
> the way is unacceptable.

That's an odd combination of requirements, but I know how customers can
be :)

Just to make it clear:  I provide comments, but I am in no position to
reject any of your patches.  Or have any wish to do so.  You maintain
r8152.  Oliver maintains cdc_ether.  I am confident that whatever you
two decide is going to be fine.

> [...]
>> Each USB configuation comes with a set of descriptors identifying the
>> functions, and USB interface drivers attach to the functions they
>> support.  The user can dynamically switch the device from e.g. cfg #1 to
>> cfg #3 by writing "3" to /sys/bus/usb/devices/<port>/bConfigurationValue
>> This will cause the ECM and ACM USB interfaces to disappear, and the
>> associated class drivers will unbind, and new vendor specific USB
>> interfaces appear instead, causing a matching vendor specific driver to
>> load and bind.
>>=20
>> Naturally, end users will not switch configurations all the time.  They
>> will select the configuration providing the set of functions they want.
>> If this is different from the default configuration  selected by the
>> Linux USB core, then that's a simple udev rule to update the
>> bConfigurationValue sysfs attribute on device disceovery.
>
> I tested above method before. And I found that the cdc_ether
> was loaded before switching the configuration. The behavior
> of loading one driver and changing to another driver has
> opportunity to let our some previous chips become abnormal.
> To switch configuration is fine. However, it may have problem
> to switch driver. That is why the current kernel only supports
> vendor mode. If the method works fine, I have no trouble now.

Yes, many firmwares/devices are not prepared to do "late" config
switching and can end up in a strange limbo if they are initialized
before switching. An udev rule should still run early enough to prevent
this problem I believe.

But if that doesn't work, then I agree that a blacklist makes more
sense. Just make it runtime configurable so that distros can do
something sane with it.



Bj=C3=B8rn
