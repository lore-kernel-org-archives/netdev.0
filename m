From: Larry Finger <Larry.Finger@lwfinger.net>
Subject: Re: calling request_firmware() from module init will not work with
 recent/future udev versions
Date: Sat, 14 Jan 2012 12:45:32 -0600
Message-ID: <4F11CD4C.9020308@lwfinger.net>
References: <CAPXgP11iT9K2KcDCJvw_druf5qdNjs0jLfrbpS7CcYh5vXrz_w@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-wireless@vger.kernel.org,
	Tom Gundersen <teg@jklm.no>, Andy Whitcroft <apw@canonical.com>
To: Kay Sievers <kay.sievers@vrfy.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yw0-f46.google.com ([209.85.213.46]:62808 "EHLO
	mail-yw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755505Ab2ANSpg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 14 Jan 2012 13:45:36 -0500
In-Reply-To: <CAPXgP11iT9K2KcDCJvw_druf5qdNjs0jLfrbpS7CcYh5vXrz_w@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 01/14/2012 09:25 AM, Kay Sievers wrote:
> Hey,
>
> just a heads-up, when bug reports are coming in now. The kernel log
> might look like a kernel failure, but it's caused by recent userspace
> changes.
>
> We changed udev to strictly enforce sequence order and dependency
> handling of events. This seems to break some netdev drivers which
> block in modprobe until the firmware from userspace is loaded into the
> driver.
>
> I think it's out of question, that nothing must block in module init
> and rely on a userspace transaction to be fulfilled to finish the
> init_module() syscall. If userspace is not running properly, nothing
> will work. Built-in drivers and the transition from initramfs to the
> real root can't be handled properly that way.
>
> These drivers need to be fixed to load their firmware during ifup,
> which would be the most flexible solution. That way, it should also
> work if the driver is built-in, or is loaded from initramfs and no
> firmware is available.
> Alternatively, the firmware request should be able to use the aync
> firmware_request API and not the blocking one.
>
> We might need to work around that in the current udev for now, but
> these drivers will definitely break in future udev versions.
> Userspace, these days, should not be in charge of papering over
> obvious kernel bugs like this.
>
> These are the drivers we received bug reports so far. We didn't look
> into any of details of the drivers, but according to the logs, they
> seem to block for 60 seconds in modprobe, when userspace is not
> behaving like expected:
>    bnx2/bnx2-mips-06-6.2.1.fw
>    rtlwifi/rtl8192sefw.bin
>    brcm/bcm43xx-0.fw

Thanks for the heads-up. Do you have a reference for the problem with 
rtlwifi/rtl8192sefw.bin? Google did not find anything that looked appropriate.

Thanks,

Larry
