From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: STRANGE ERROR
Date: Sat, 19 May 2007 16:34:02 -0700
Message-ID: <20070519163402.b087b9d7.akpm@linux-foundation.org>
References: <dcf706c60705191530x5a78f9aewbb520a97ad516f6d@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, Jeff Garzik <jeff@garzik.org>,
	netdev@vger.kernel.org, Vitaly Bordug <vbordug@ru.mvista.com>
To: "Sasa Ostrouska" <casaxa@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2.linux-foundation.org ([207.189.120.14]:42688 "EHLO
	smtp2.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1760133AbXESXhM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 19 May 2007 19:37:12 -0400
In-Reply-To: <dcf706c60705191530x5a78f9aewbb520a97ad516f6d@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sun, 20 May 2007 00:30:55 +0200 "Sasa Ostrouska" <casaxa@gmail.com> wrote:

> Hi everybody,
> 
> I tried today to upgrade the kernel to 2.6.21.1 and i got the same
> error during the boot time.
> Here is the dmesg of the 2.6.20.2, can somebody tell me what this is ?
> 
> ...
>
> Marvell 88E1101: Registered new driver
> Fixed PHY: Registered new driver
> driver_bound: device fixed@100:1 already bound

I don't know what caused that one.

> Device 'fixed@100:1' does not have a release() function, it is broken
> and must be fixed.
> BUG: at drivers/base/core.c:104 device_release()
> 
> Call Trace:
>  [<ffffffff802ec380>] kobject_cleanup+0x53/0x7e
>  [<ffffffff802ec3ab>] kobject_release+0x0/0x9
>  [<ffffffff802ecf3f>] kref_put+0x74/0x81
>  [<ffffffff8035493b>] fixed_mdio_register_device+0x230/0x265
>  [<ffffffff80564d31>] fixed_init+0x1f/0x35
>  [<ffffffff802071a4>] init+0x147/0x2fb
>  [<ffffffff80223b6e>] schedule_tail+0x36/0x92
>  [<ffffffff8020a678>] child_rip+0xa/0x12
>  [<ffffffff80311714>] acpi_ds_init_one_object+0x0/0x83
>  [<ffffffff8020705d>] init+0x0/0x2fb
>  [<ffffffff8020a66e>] child_rip+0x0/0x12

This appears to have happened because fixed_mdio_register_device() (or
phy_device_create) didn't suitably initialise phy_device.dev.

But I don't immediately see why this doesn't affect all phy drivers. 
Presumably it's the fixed driver which is at fault.  Jeff, how is this
supposed to work?

Thanks.

