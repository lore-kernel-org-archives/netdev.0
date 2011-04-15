From: Andy Fleming <afleming@gmail.com>
Subject: Re: [Bugme-new] [Bug 33042] New: Marvell 88E1145 phy configured
 incorrectly in fiber mode
Date: Fri, 15 Apr 2011 15:57:04 -0500
Message-ID: <BANLkTikJ60ND7s5-jfGTBDG3BoM-294CSA@mail.gmail.com>
References: <BANLkTikH09jMZZk1ZgeQi+HOoeFqgTpdBA@mail.gmail.com>
	<903944.53826.qm@web37604.mail.mud.yahoo.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Andrew Morton <akpm@linux-foundation.org>,
	David Daney <ddaney@caviumnetworks.com>,
	netdev@vger.kernel.org, bugzilla-daemon@bugzilla.kernel.org,
	bugme-daemon@bugzilla.kernel.org,
	Grant Likely <grant.likely@secretlab.ca>,
	Andy Fleming <afleming@freescale.com>
To: Alex Dubov <oakad@yahoo.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-px0-f179.google.com ([209.85.212.179]:56170 "EHLO
	mail-px0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755423Ab1DOU5G convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 15 Apr 2011 16:57:06 -0400
Received: by pxi2 with SMTP id 2so1845155pxi.10
        for <netdev@vger.kernel.org>; Fri, 15 Apr 2011 13:57:05 -0700 (PDT)
In-Reply-To: <903944.53826.qm@web37604.mail.mud.yahoo.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Apr 14, 2011 at 2:59 AM, Alex Dubov <oakad@yahoo.com> wrote:
>
>
> --- On Thu, 14/4/11, Andy Fleming <afleming@gmail.com> wrote:
>
>>
>> I've just rewritten the U-Boot code for PHY management, so
>> I'd be
>> interested in hearing if this breaks your board.=A0 But
>> what's
>> interesting to me is that, in order for U-Boot to report
>> that the link
>> is a "fiber" link, something had to set the TSEC_FIBER
>> flag, and only
>> one PHY in the public source did.=A0 This implies to me
>> that your board
>> isn't supported by mainline U-Boot, and suggests that
>> someone may have
>> modified the 88e1145 driver. Otherwise, I don't see any
>> fiber-related
>> differences between the U-Boot 1145 driver, and the Linux
>> one.
>
> I had not seen any difference, that's true. But the problem somehow
> creeps in.
>
> The u-boot is standard stock u-boot pulled from the recent git,
> no special configuration involved.


Are you seeing this message when you run ethernet in u-boot?

"Speed: 1000, full duplex, fiber mode"

Because that last part only shows up if someone sets TSEC_FIBER in the
tsec's "flags" field...



> I tried to prevent kernel from reconfiguring the phy, but to no avail=
=2E
> It seems very weird to me, because I did quite a lot of testing with
> u-boot and network just works on that interface. However, when kernel
> starts booting it suddenly looses the ability to talk to it.


Believe me, I feel your pain.  These devices are often remarkably
fickle. The kernel tries to be
more robust, but sometimes the PHYs just don't like to be touched at al=
l.

You could probably change to use a fixed link by removing the
phy-handle property from your ethernet device node, and adding:
"fixed-link=3D<0 1000 1 0 0>".  If that works, then the issue is that
Linux is breaking something when it connects. It might be good enough
for you to use fixed-link, though it would be good to actually find
out what's going wrong with the PHY driver.

Andy
