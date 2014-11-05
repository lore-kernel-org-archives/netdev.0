From: Tom Herbert <therbert@google.com>
Subject: Re: [PATCH net 0/5] Implement ndo_gso_check() for vxlan nics
Date: Wed, 5 Nov 2014 10:00:53 -0800
Message-ID: <CA+mtBx_BOmV+tOtio48M+xRatK79B31LoGnf4uvFJAbxYqOt_w@mail.gmail.com>
References: <1415138202-1197-1-git-send-email-joestringer@nicira.com>
	<CAJ3xEMjkxRg=uM+0kjOM0Zh84XYm_O6PiWoeYSw=LirU=ZJ+rA@mail.gmail.com>
	<CANr6G5xtNYenhd8KDWx+kRcnSZ0fahUdAL+6Wcz=5_dNvrQR6Q@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8BIT
Cc: Or Gerlitz <gerlitz.or@gmail.com>,
	Linux Netdev List <netdev@vger.kernel.org>,
	"sathya.perla" <sathya.perla@emulex.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
	"linux.nics" <linux.nics@intel.com>,
	Amir Vadai <amirv@mellanox.com>,
	"shahed.shaikh" <shahed.shaikh@qlogic.com>,
	dept-gelinuxnicdev <Dept-GELinuxNICDev@qlogic.com>,
	Linux Kernel <linux-kernel@vger.kernel.org>
To: Joe Stringer <joestringer@nicira.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f173.google.com ([209.85.223.173]:51809 "EHLO
	mail-ie0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751036AbaKESAy convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 5 Nov 2014 13:00:54 -0500
Received: by mail-ie0-f173.google.com with SMTP id tr6so1233863ieb.32
        for <netdev@vger.kernel.org>; Wed, 05 Nov 2014 10:00:53 -0800 (PST)
In-Reply-To: <CANr6G5xtNYenhd8KDWx+kRcnSZ0fahUdAL+6Wcz=5_dNvrQR6Q@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Nov 5, 2014 at 9:50 AM, Joe Stringer <joestringer@nicira.com> wrote:
>
> On 5 November 2014 04:38, Or Gerlitz <gerlitz.or@gmail.com> wrote:
>>
>> On Tue, Nov 4, 2014 at 11:56 PM, Joe Stringer <joestringer@nicira.com> wrote:
>> > Most NICs that report NETIF_F_GSO_UDP_TUNNEL support VXLAN, and not other
>> > UDP-based encapsulation protocols where the format and size of the header may
>> > differ. This patch series implements ndo_gso_check() for these NICs,
>> > restricting the GSO handling to something that looks and smells like VXLAN.
>> >
>> > Implementation shamelessly stolen from Tom Herbert (with minor fixups):
>> > http://thread.gmane.org/gmane.linux.network/332428/focus=333111
>>
>>
>> Hi Joe,
>>
>> 1st, thanks for picking this task...2nd, for drivers that currently
>> support only pure VXLAN, I don't see the point
>> to replicate the helper suggested by Tom (good catch on the size check
>> to be 16 and not 12) four times and who know how more in the future.
>> Let's just have one generic helper and make the mlx4/be/fm10k/benet
>> drivers to have it as their ndo, OK?
>
>
> Thanks for taking a look.
>
> I had debated whether to do this or not as the actual support on each NIC may differ, and each implementation may morph over time to match these capabilities better. Obviously the vendors will know better than me on this, so I'm posing this series to prod them for more information. At this point I've had just one maintainer come back and confirm that this helper is a good fit for their hardware, so I'd like to confirm that multiple drivers will use a ndo_gso_check_vxlan_helper() function before I go and create it.


Thanks for implementing this fix!

Personally, I would rather not have the helper. This is already a
small number of drivers, and each driver owner should consider what
limitations are of their device and try to enable to allow the maximum
number of use cases possible. I'm also hoping that new devices will
implement the more generic mechanism so that VXLAN is just one
supported protocol.
