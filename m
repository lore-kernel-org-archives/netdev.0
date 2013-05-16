From: Mike Qiu <qiudayu@linux.vnet.ibm.com>
Subject: Re: BCM5719(tg3) use multiple MSI with RSS
Date: Thu, 16 May 2013 10:30:36 +0800
Message-ID: <519444CC.6080406@linux.vnet.ibm.com>
References: <51933FCB.4090402@linux.vnet.ibm.com> <1368630538.3768.12.camel@LTIRV-MCHAN1.corp.ad.broadcom.com> <1368633120.2652.11.camel@bwh-desktop.uk.solarflarecom.com> <1368633836.6796.1.camel@LTIRV-MCHAN1.corp.ad.broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Ben Hutchings <bhutchings@solarflare.com>, eilong@broadcom.com,
	mcarlson@broadcom.com, zambrano@broadcom.com,
	jeffrey.t.kirsher@intel.com, netdev@vger.kernel.org
To: Michael Chan <mchan@broadcom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e28smtp07.in.ibm.com ([122.248.162.7]:36860 "EHLO
	e28smtp07.in.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751887Ab3EPCas (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 15 May 2013 22:30:48 -0400
Received: from /spool/local
	by e28smtp07.in.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <netdev@vger.kernel.org> from <qiudayu@linux.vnet.ibm.com>;
	Thu, 16 May 2013 07:55:03 +0530
Received: from d28relay03.in.ibm.com (d28relay03.in.ibm.com [9.184.220.60])
	by d28dlp03.in.ibm.com (Postfix) with ESMTP id E62901258023
	for <netdev@vger.kernel.org>; Thu, 16 May 2013 08:02:35 +0530 (IST)
Received: from d28av05.in.ibm.com (d28av05.in.ibm.com [9.184.220.67])
	by d28relay03.in.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r4G2UZtC66912480
	for <netdev@vger.kernel.org>; Thu, 16 May 2013 08:00:35 +0530
Received: from d28av05.in.ibm.com (loopback [127.0.0.1])
	by d28av05.in.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id r4G2UfpG028206
	for <netdev@vger.kernel.org>; Thu, 16 May 2013 12:30:43 +1000
In-Reply-To: <1368633836.6796.1.camel@LTIRV-MCHAN1.corp.ad.broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=E4=BA=8E 2013/5/16 0:03, Michael Chan =E5=86=99=E9=81=93:
> On Wed, 2013-05-15 at 16:52 +0100, Ben Hutchings wrote:
>> On Wed, 2013-05-15 at 08:08 -0700, Michael Chan wrote:
>>> On Wed, 2013-05-15 at 15:56 +0800, Mike Qiu wrote:
>>>> Hi all
>>>>
>>>> Currently, I need to enable multiple MSI on BCM5719 network card.
>>>> But I look in to the spec of 5719 from Broadcom, it seems
>>>> that RSS just enable with MSI-X, so I'm not sure if multiple
>>>> MSI can use RSS.
>>>>
>>> MSI can only support one IRQ source and cannot support RSS.
>> It is possible for an MSI capability to have multiple MSIs, but they
>> will use the same address and consecutive data values.
>>
>> On x86, if you can find a large enough block of free IRQs on an IOAP=
IC,
>> it is possible to implement RSS this way.  Linux supports this on
>> systems with an x2apic.
>>
>> Now, maybe tg3 hardware doesn't support this (and really, why bother
>> when there is MSI-X?) but the option does exist.
> Yes, tg3 hardware (may be all Broadcom hardware) can only use MSI as =
a
> replacement for INTA.
That you mean, it can't use multiple MSI for RSS ?
>
