From: Tom Gundersen <teg@jklm.no>
Subject: Re: [PATCH 0/4] Provide netdev naming-policy via sysfs
Date: Sat, 1 Mar 2014 15:19:03 +0100
Message-ID: <CAG-2HqVQRTdA5NvjirR35qLbAkDUB1dN6oAvU2CLs4dnFS42Nw@mail.gmail.com>
References: <1393512434-1325-1-git-send-email-dh.herrmann@gmail.com> <CAG-2HqWahCVvDLPwoMo7O4kam+W0o7BQGm4cRBvc9=X_p0fF7Q@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev <netdev@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>,
	Kay Sievers <kay.sievers@vrfy.org>,
	Johannes berg <johannes@sipsolutions.net>,
	LKML <linux-kernel@vger.kernel.org>,
	Linux Wireless List <linux-wireless@vger.kernel.org>
To: David Herrmann <dh.herrmann@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CAG-2HqWahCVvDLPwoMo7O4kam+W0o7BQGm4cRBvc9=X_p0fF7Q@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Feb 27, 2014 at 4:47 PM, Tom Gundersen <teg@jklm.no> wrote:
> On Thu, Feb 27, 2014 at 3:47 PM, David Herrmann <dh.herrmann@gmail.com> wrote:
>> This series implements a new sysfs attribute for netdevs called
>> "name_assign_type". It provides an integer that describes where an interface
>> name comes from. See Patch #1 for a description of this attribute. It is
>> modelled after the existing "addr_assign_type" attribute.
>>
>> The main use-case is to allow udev to skip applying reliable ifnames to virtual
>> devices. For instance, if wifi-P2P devices are created, wpas already provides a
>> suitable naming-policy and udev shouldn't touch these devices. Same is true for
>> other virtual devices.
>> The idea is that if a device-name was provided by user-space, we should always
>> prefer fixing this naming-policy instead of making udev rename the device. For
>> kernel provided names that's hardly possible, though. Providing the
>> naming-policy source via sysfs is thus a simple way to see whether renames are
>> needed.
>>
>> Additionally, this field allows to detect whether a netdev has been manually
>> renamed, which is quite useful for debugging and during crash-recovery.
>
> Moreover, it would be useful for udev to reliably know if some other
> userspace process already renamed a device, so we know not to touch
> it. This can easily happen for instance if some renaming happens in
> the initrd or from script called from udev rules.

Incidentally, just after writing this email I ran into precisely this
problem due to buggy udev rules in a third-party package. The result
was that the upstream NIC naming rules were unable to detect that a
given NIC had already been renamed and ended up renaming them a second
time (hence wrecking havoc).

The problem was easy enough to fix, but with these patches we would be
able to avoid the issue altogether, so I'm looking forward to fixing
up udev to using this interface.

> Acked-by: Tom Gundersen <teg@jklm.no>
