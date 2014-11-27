From: Ming Lei <ming.lei@canonical.com>
Subject: Re: wl1251: NVS firmware data
Date: Thu, 27 Nov 2014 22:21:44 +0800
Message-ID: <CACVXFVMr8jH1ZzyPNG91VDK8DuVjQsHn9ks62sSNjOfUnNsURQ@mail.gmail.com>
References: <201411271506.20457@pali>
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
Return-path: <netdev-owner@vger.kernel.org>
Received: from youngberry.canonical.com ([91.189.89.112]:44437 "EHLO
	youngberry.canonical.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751552AbaK0OVr convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 27 Nov 2014 09:21:47 -0500
In-Reply-To: <201411271506.20457@pali>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Nov 27, 2014 at 10:06 PM, Pali Roh=C3=A1r <pali.rohar@gmail.com=
> wrote:
> Hello,
>
> wifi driver wl1251 needs NVS calibration data for working. These
> data are loaded by driver via request_firmware from userspace
> file: ti-connectivity/wl1251-nvs.bin. In linux-fimrware git tree
> there is generic wl1251-nvs.bin file which is used by default.
>
> Driver wl1251 is used on Nokia N900 cellphone for its wifi chip.
> This cellphone has one special MTD partition (called CAL) where
> are stored some configuration data in special binary (key-value)
> format. And there is also stored correct calibration data for
> specific device (each device has different data). It is preferred
> to use those data instead generic one (provided by linux-firmware
> git tree).
>
> Now my question is: How to correctly load calibration data from
> special Nokia N900 CAL partition into wl1251 kernel driver?

It is better to let user space script handle the request.

>
> By default kernel reads ti-connectivity/wl1251-nvs.bin file from
> VFS if exists without any userspace support. If it fails then it
> fallback to loading via udev.

You can remove or rename this file so that loading from user space
can be triggered.

>
> Reading correct data from CAL partition is not easy (structure is
> difficult), but there is open source program which can parse CAL
> partition and write NVS data to stdout. So adding this CAL parser
> into kernel is not good idea (program is GPLv3+ code --
> incompatible with kernel).
>
> So how to solve this problem? How to load correct NVS data from
> CAL partition into wl1251 driver?
>
> It is possible to tell kernel to use some helper userspace
> program for loading data and if it fails then fallback to direct
> loading? E.g first try to use model specific data and if it fails
> for some reasons then fallback to reading genetic data.

One solution is to introduce request_firmware_user() and let
this API handle your case, but CONFIG_FW_LOADER_USER_HELPER
has to be enabled.

If request_firmware_user() fails, request_firmware_direct() can be
tried further.

Thanks,
Ming Lei
