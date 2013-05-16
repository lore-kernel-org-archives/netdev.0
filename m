From: Mike Qiu <qiudayu@linux.vnet.ibm.com>
Subject: Re: BCM5719(tg3) use multiple MSI with RSS
Date: Thu, 16 May 2013 10:25:32 +0800
Message-ID: <5194439C.2050509@linux.vnet.ibm.com>
References: <51933FCB.4090402@linux.vnet.ibm.com> <1368630538.3768.12.camel@LTIRV-MCHAN1.corp.ad.broadcom.com> <1368633120.2652.11.camel@bwh-desktop.uk.solarflarecom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Michael Chan <mchan@broadcom.com>, eilong@broadcom.com,
	mcarlson@broadcom.com, zambrano@broadcom.com,
	jeffrey.t.kirsher@intel.com, netdev@vger.kernel.org
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e28smtp03.in.ibm.com ([122.248.162.3]:36768 "EHLO
	e28smtp03.in.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755027Ab3EPCZp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 15 May 2013 22:25:45 -0400
Received: from /spool/local
	by e28smtp03.in.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <netdev@vger.kernel.org> from <qiudayu@linux.vnet.ibm.com>;
	Thu, 16 May 2013 07:50:49 +0530
Received: from d28relay04.in.ibm.com (d28relay04.in.ibm.com [9.184.220.61])
	by d28dlp03.in.ibm.com (Postfix) with ESMTP id 217EB1258051
	for <netdev@vger.kernel.org>; Thu, 16 May 2013 07:57:31 +0530 (IST)
Received: from d28av05.in.ibm.com (d28av05.in.ibm.com [9.184.220.67])
	by d28relay04.in.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r4G2PWe214025046
	for <netdev@vger.kernel.org>; Thu, 16 May 2013 07:55:32 +0530
Received: from d28av05.in.ibm.com (loopback [127.0.0.1])
	by d28av05.in.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id r4G2PbhP012212
	for <netdev@vger.kernel.org>; Thu, 16 May 2013 12:25:37 +1000
In-Reply-To: <1368633120.2652.11.camel@bwh-desktop.uk.solarflarecom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=E4=BA=8E 2013/5/15 23:52, Ben Hutchings =E5=86=99=E9=81=93:
> On Wed, 2013-05-15 at 08:08 -0700, Michael Chan wrote:
>> On Wed, 2013-05-15 at 15:56 +0800, Mike Qiu wrote:
>>> Hi all
>>>
>>> Currently, I need to enable multiple MSI on BCM5719 network card.
>>> But I look in to the spec of 5719 from Broadcom, it seems
>>> that RSS just enable with MSI-X, so I'm not sure if multiple
>>> MSI can use RSS.
>>>
>> MSI can only support one IRQ source and cannot support RSS.
> It is possible for an MSI capability to have multiple MSIs, but they
> will use the same address and consecutive data values.
Yes, it should be this.
> On x86, if you can find a large enough block of free IRQs on an IOAPI=
C,
> it is possible to implement RSS this way.  Linux supports this on
> systems with an x2apic.
But, I see the tg3 spec, and it seems the RSS is just for MSI-X(and IOV=
).
And I try to enable RSS use multiple MSI for 4 irqs, the system
alloc 4 consecutive irqs to tg3, and each one can be test pass using=20
interrupt test.
But the last 3 interrupts seems not to be triggered as "cat /proc/inter=
rups"
shows after the driver loaded. Only the first irq can be triggered for
only sometimes. The network surely not work.
> Now, maybe tg3 hardware doesn't support this (and really, why bother
> when there is MSI-X?) but the option does exist.
Actually, I try to enable the multiple MSI feature, and needs tg3 card =
to
support this feature. For some old PCI device, it may only support=20
multiple MSI

Thanks
Mike
>
> Ben.
>
