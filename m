From: Marcin Wojtas <mw@semihalf.com>
Subject: Re: [PATCH 07/13] bus: mvebu-mbus: provide api for obtaining IO and
 DRAM window information
Date: Sun, 22 Nov 2015 22:24:01 +0100
Message-ID: <CAPv3WKeUPT2VtbvBpchOntNpOpBrpazi4YUaL6+6Yu=NOROFbw@mail.gmail.com>
References: <1448178839-3541-1-git-send-email-mw@semihalf.com>
	<1448178839-3541-8-git-send-email-mw@semihalf.com>
	<5746764.cNlI6PeatM@wuerfel>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "linux-arm-kernel@lists.infradead.org"
	<linux-arm-kernel@lists.infradead.org>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	Thomas Petazzoni <thomas.petazzoni@free-electrons.com>,
	Andrew Lunn <andrew@lunn.ch>,
	Russell King - ARM Linux <linux@arm.linux.org.uk>,
	Jason Cooper <jason@lakedaemon.net>,
	Yair Mahalalel <myair@marvell.com>,
	Grzegorz Jaszczyk <jaz@semihalf.com>,
	Simon Guinot <simon.guinot@sequanux.org>,
	Evan Wang <xswang@marvell.com>, nadavh@marvell.com,
	Lior Amsalem <alior@marvell.com>,
	Tomasz Nowicki <tn@semihalf.com>,
	=?UTF-8?Q?Gregory_Cl=C3=A9ment?=
	<gregory.clement@free-electrons.com>, nitroshift@yahoo.com,
	"David S. Miller" <davem@davemloft.net>,
	Sebastian Hesselbarth <sebastian.hesselbarth@gmail.com>
To: Arnd Bergmann <arnd@arndb.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f47.google.com ([209.85.218.47]:33260 "EHLO
	mail-oi0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752269AbbKVVYD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 22 Nov 2015 16:24:03 -0500
Received: by oixx65 with SMTP id x65so103231602oix.0
        for <netdev@vger.kernel.org>; Sun, 22 Nov 2015 13:24:01 -0800 (PST)
In-Reply-To: <5746764.cNlI6PeatM@wuerfel>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Arnd,

2015-11-22 21:02 GMT+01:00 Arnd Bergmann <arnd@arndb.de>:
> On Sunday 22 November 2015 08:53:53 Marcin Wojtas wrote:
>> This commit enables finding appropriate mbus window and obtaining its
>> target id and attribute for given physical address in two separate
>> routines, both for IO and DRAM windows. This functionality
>> is needed for Armada XP/38x Network Controller's Buffer Manager and
>> PnC configuration.
>>
>> Signed-off-by: Marcin Wojtas <mw@semihalf.com>
>>
>> [DRAM window information reference in LKv3.10]
>> Signed-off-by: Evan Wang <xswang@marvell.com>
>>
>
> It's too long ago to remember all the details, but I thought we
> had designed this so the configuration can just be done by
> describing it in DT. What am I missing?
>

And those functions do not break this approach. They just enable
finding and reading the settings of MBUS windows done during initial
configuration. Please remember that mvebu-mbus driver fills the MBUS
windows registers basing on DT, however it just configures access CPU
- DRAM/perfipheral.

In this particular case only physical adresses of buffers are known
and we have to 'open windows' between BM <-> DRAM and NETA <-> BM
internal memory. Hence instead of hardcoding size/target/attribute, we
can take information stored in CPU DRAM/IO windows registers.

Best regards,
Marcin
