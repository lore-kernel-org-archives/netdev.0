From: Ming Lei <ming.lei@canonical.com>
Subject: Re: wl1251: NVS firmware data
Date: Thu, 27 Nov 2014 23:13:51 +0800
Message-ID: <CACVXFVMCJxQRUo94C8peT7G-VFkVeNYCWGKPYE5jq=twCULrpA@mail.gmail.com>
References: <201411271506.20457@pali>
	<CACVXFVMr8jH1ZzyPNG91VDK8DuVjQsHn9ks62sSNjOfUnNsURQ@mail.gmail.com>
	<201411271543.23527@pali>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "John W. Linville" <linville@tuxdriver.com>,
	Grazvydas Ignotas <notasas@gmail.com>,
	"linux-wireless@vger.kernel.org" <linux-wireless@vger.kernel.org>,
	Network Development <netdev@vger.kernel.org>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
	Pavel Machek <pavel@ucw.cz>,
	Ivaylo Dimitrov <ivo.g.dimitrov.75@gmail.com>,
	Aaro Koskinen <aaro.koskinen@iki.fi>,
	Kalle Valo <kvalo@adurom.com>,
	Sebastian Reichel <sre@ring0.de>,
	David Gnedt <david.gnedt@davizone.at>
To: =?UTF-8?Q?Pali_Roh=C3=A1r?= <pali.rohar@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <201411271543.23527@pali>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Nov 27, 2014 at 10:43 PM, Pali Roh=C3=A1r <pali.rohar@gmail.com=
> wrote:
> On Thursday 27 November 2014 15:21:44 Ming Lei wrote:
>> On Thu, Nov 27, 2014 at 10:06 PM, Pali Roh=C3=A1r
> <pali.rohar@gmail.com> wrote:
>> > Hello,
>> >
>> > wifi driver wl1251 needs NVS calibration data for working.
>> > These data are loaded by driver via request_firmware from
>> > userspace file: ti-connectivity/wl1251-nvs.bin. In
>> > linux-fimrware git tree there is generic wl1251-nvs.bin
>> > file which is used by default.
>> >
>> > Driver wl1251 is used on Nokia N900 cellphone for its wifi
>> > chip. This cellphone has one special MTD partition (called
>> > CAL) where are stored some configuration data in special
>> > binary (key-value) format. And there is also stored correct
>> > calibration data for specific device (each device has
>> > different data). It is preferred to use those data instead
>> > generic one (provided by linux-firmware git tree).
>> >
>> > Now my question is: How to correctly load calibration data
>> > from special Nokia N900 CAL partition into wl1251 kernel
>> > driver?
>>
>> It is better to let user space script handle the request.
>>
>
> Yes, this makes sense. Implementing CAL parser in kernel wl1251
> driver would be hard...
>
>> > By default kernel reads ti-connectivity/wl1251-nvs.bin file
>> > from VFS if exists without any userspace support. If it
>> > fails then it fallback to loading via udev.
>>
>> You can remove or rename this file so that loading from user
>> space can be triggered.
>>
>
> It is no so easy... In case when CAL does not contains NVS data
> then we want to use this generic NVS file. And telling everybody
> to rename this is file is not good solution...
>
>> > Reading correct data from CAL partition is not easy
>> > (structure is difficult), but there is open source program
>> > which can parse CAL partition and write NVS data to stdout.
>> > So adding this CAL parser into kernel is not good idea
>> > (program is GPLv3+ code -- incompatible with kernel).
>> >
>> > So how to solve this problem? How to load correct NVS data
>> > from CAL partition into wl1251 driver?
>> >
>> > It is possible to tell kernel to use some helper userspace
>> > program for loading data and if it fails then fallback to
>> > direct loading? E.g first try to use model specific data
>> > and if it fails for some reasons then fallback to reading
>> > genetic data.
>>
>> One solution is to introduce request_firmware_user() and let
>> this API handle your case, but CONFIG_FW_LOADER_USER_HELPER
>> has to be enabled.
>>
>> If request_firmware_user() fails, request_firmware_direct()
>> can be tried further.
>>
>> Thanks,
>> Ming Lei
>
> Ok, new kernel function which will change order of loading
> firmware should work.

I mean you can do that in your driver.

>
> Which userspace helper programs for (automatic) firmware loading
> are used? Can be udev configured to use own program for loading

At default, udev had its builtin firmware helper, but some new
udev stops to handle firmware request.

If the udev you are using still supports to handle firmware request,
you can write your load helper and add your rule for handling
the special case. Otherwise, you need to write code to monitor
the netlink uevents from the kernel and handle your firmware
loading request.

Thanks,
Ming Lei
