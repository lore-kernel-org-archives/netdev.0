From: scott@scottnz.com
Subject: Re: [PATCH rfc net] Allow the autoconfigured network interface to be
 renamed.
Date: Mon, 11 Jun 2012 21:58:45 +1200
Message-ID: <f8f3fa05ddbe3a2e1613588754f151ac.squirrel@scottnz.com>
References: <1339228087-14870-1-git-send-email-scott@scottnz.com>
    <20120610.202515.138701034400919651.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7BIT
Cc: scott@scottnz.com, netdev@vger.kernel.org,
	scott.parlane@alliedtelesis.co.nz
To: "David Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from edgewireless.tk ([184.82.109.251]:38153 "EHLO vps1.scottnz.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1751326Ab2FKJ7R (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 11 Jun 2012 05:59:17 -0400
In-Reply-To: <20120610.202515.138701034400919651.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> From: Scott Parlane <scott@scottnz.com>
> Date: Sat,  9 Jun 2012 19:48:07 +1200
>
>> From: Scott Parlane <scott.parlane@alliedtelesis.co.nz>
>>
>> if IP_PNP_RENAME_DEV is set, the first interface to be configured
>> automatically by the kernel during boot will be renamed.
>>
>> IP_PNP_DEV_NEWNAME is the name to give the autoconfigured device.
>>
>> No changes will be made to any interface that is not autoconfigured.
>>
>> This allows the assurance of the boot device name, without the need
>> for an initramfs.
>>
>> Signed-off-by: Scott Parlane <scott.parlane@alliedtelesis.co.nz>
>
> Making this a compile time option makes absolutely no sense at all.
>
> Assuming this feature is desirable at all (which is a big IF), it
> should be a kernel command line option.

My comment re how many devices was a reference to the level of testing,
not the usage, however I see it was probably moot given any person with
sufficient
knowledge of the area would see it works as described.
(unless I did something i haven't seen yet)

[background of this solution]
In our configuration we load the same kernel on to a number of testboxes,
each of which has several ethernet interfaces and serial ports
(for communicating with our devices under test)
They use nfsroot which prevents udev rules from working correctly
(because you cant take down the interface to rename it)
Previously we were using an initramfs that would rename the interface,
just before mounting the real root.
However a recent change to glibc prevents busybox's nfs utils from working,
so I made this patch to get the kernel to do it, and remove the need for
the initramfs
(which just slows our boot process anyways)

In our case, we run a custom kernel, and have this option turned on, with a
suitable name so that we can identify the boot interface.

While I agree that being able to configure it from the command line would
be useful,
I would rather that I could (if I wanted) configure it at compile time to
default,
purely because it means there is one less thing my admins need to deal
worry about
or can change in the pxelinux config. (every testbox has a unique cmdline,
because of
how our nfsroot mount points work)

Please let me know if you want me to extend it to support command line
configuration,
and what configuration you would like to trigger it.

Kind Regards,
Scott
