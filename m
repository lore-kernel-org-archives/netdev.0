From: Krzysztof Oledzki <olel@ans.pl>
Subject: Re: [PATCH 0/3] bonding: 3 fixes for 2.6.24
Date: Wed, 9 Jan 2008 07:35:35 +0100 (CET)
Message-ID: <Pine.LNX.4.64.0801090732490.1135@bizon.gios.gov.pl>
References: <11997574203125-git-send-email-fubar@us.ibm.com>
 <Pine.LNX.4.64.0801081949290.1135@bizon.gios.gov.pl> <29560.1199820632@death>
Mime-Version: 1.0
Content-Type: MULTIPART/MIXED; BOUNDARY="-187430788-569974034-1199860535=:1135"
Cc: netdev@vger.kernel.org, Jeff Garzik <jgarzik@pobox.com>,
	David Miller <davem@davemloft.net>,
	Andy Gospodarek <andy@greyhouse.net>
To: Jay Vosburgh <fubar@us.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from bizon.gios.gov.pl ([212.244.124.8]:40159 "EHLO
	bizon.gios.gov.pl" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751286AbYAIGgA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 9 Jan 2008 01:36:00 -0500
In-Reply-To: <29560.1199820632@death>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

---187430788-569974034-1199860535=:1135
Content-Type: TEXT/PLAIN; charset=ISO-8859-2; format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE



On Tue, 8 Jan 2008, Jay Vosburgh wrote:

> Krzysztof Oledzki <olel@ans.pl> wrote:
>
>> On Mon, 7 Jan 2008, Jay Vosburgh wrote:
>>
>>> =09Following are three fixes to fix locking problems and
>>> silence locking-related warnings in the current 2.6.24-rc.
>>>
>>> =09patch 1: fix locking in sysfs primary/active selection
>>>
>>> =09Call core network functions with expected locks to
>>> eliminate potential deadlock and silence warnings.
>>>
>>> =09patch 2: fix ASSERT_RTNL that produces spurious warnings
>>>
>>> =09Relocate ASSERT_RTNL to remove a false warning; after patch,
>>> ASSERT is located in code that holds only RTNL (additional locks were
>>> causing the ASSERT to trip)
>>>
>>> =09patch 3: fix locking during alb failover and slave removal
>>>
>>> =09Fix all call paths into alb_fasten_mac_swap to hold only RTNL.
>>> Eliminates deadlock and silences warnings.
>>>
>>> =09Patches are against the current netdev-2.6#upstream branch.
>>>
>>> =09Please apply for 2.6.24.
>>
>> 2.6.24-rc7 + patches #1, #2, #3:
>>
>> bonding: bond0: setting mode to active-backup (1).
>> bonding: bond0: Setting MII monitoring interval to 100.
>> ADDRCONF(NETDEV_UP): bond0: link is not ready
>> bonding: bond0: Adding slave eth0.
>> e1000: eth0: e1000_watchdog: NIC Link is Up 1000 Mbps Full Duplex, Flow =
Control: RX/TX
>> bonding: bond0: making interface eth0 the new active one.
>> bonding: bond0: first active interface up!
>> bonding: bond0: enslaving eth0 as an active interface with an up link.
>> bonding: bond0: Adding slave eth1.
>> ADDRCONF(NETDEV_CHANGE): bond0: link becomes ready
>>
>> =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D
>> [ INFO: possible irq lock inversion dependency detected ]
>> 2.6.24-rc7 #1
>> ---------------------------------------------------------
>> events/0/9 just changed the state of lock:
>> (&mc->mca_lock){-+..}, at: [<c041258e>] mld_ifc_timer_expire+0x130/0x1fb
>> but this lock took another, soft-read-irq-unsafe lock in the past:
>> (&bond->lock){-.--}
>>
>> and interrupts could create inverse lock ordering between them.
>
> =09Just to be clear: the patch set I posted yesterday was not
> intended to resolve the lockdep problem; I haven't studied that one yet.

Fine. Just let you know that someone test your patches and everything=20
works, except mentioned problem.

Best regards,

 =09=09=09=09Krzysztof Ol=EAdzki
---187430788-569974034-1199860535=:1135--
