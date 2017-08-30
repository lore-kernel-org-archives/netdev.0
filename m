From: Florian Fainelli <f.fainelli@gmail.com>
Subject: RE: [PATCH net-next v2] net: bcmgenet: Use correct I/O accessors
Date: Wed, 30 Aug 2017 09:00:39 -0700
Message-ID: <9B0290AA-64A9-4DF5-80E5-94AEA41D9D72@gmail.com>
References: <1504034731-31613-1-git-send-email-f.fainelli@gmail.com> <063D6719AE5E284EB5DD2968C1650D6DD0069792@AcuExch.aculab.com>
Mime-Version: 1.0
Content-Type: text/plain;
 charset=utf-8
Content-Transfer-Encoding: quoted-printable
Cc: "davem@davemloft.net" <davem@davemloft.net>,
        "opendmb@gmail.com" <opendmb@gmail.com>,
        "jaedon.shin@gmail.com" <jaedon.shin@gmail.com>
To: David Laight <David.Laight@ACULAB.COM>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f65.google.com ([209.85.218.65]:38289 "EHLO
        mail-oi0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751405AbdH3QAw (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 30 Aug 2017 12:00:52 -0400
Received: by mail-oi0-f65.google.com with SMTP id r203so5899837oih.5
        for <netdev@vger.kernel.org>; Wed, 30 Aug 2017 09:00:52 -0700 (PDT)
In-Reply-To: <063D6719AE5E284EB5DD2968C1650D6DD0069792@AcuExch.aculab.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On August 30, 2017 4:39:52 AM PDT, David Laight <David=2ELaight@ACULAB=2ECO=
M> wrote:
>From: Florian Fainelli
>> Sent: 29 August 2017 20:26
>> The GENET driver currently uses __raw_{read,write}l which means
>> native I/O endian=2E This works correctly for an ARM LE kernel
>(default)
>> but fails miserably on an ARM BE (BE8) kernel where registers are
>kept
>> little endian, so replace uses with {read,write}l_relaxed here which
>is
>> what we want because this is all performance sensitive code=2E
>=2E=2E=2E
>> +	if (IS_ENABLED(CONFIG_MIPS) && IS_ENABLED(CONFIG_CPU_BIG_ENDIAN))
>> +		__raw_writel(value, offset);
>> +	else
>> +		writel_relaxed(value, offset);
>
>How do you know that all BE MIPS that might have this driver have
>the BE registers of your card?
>(Or that all ARM BE systems have LE registers=2E)
>

This is the embedded network controller found on Broadcom STB SoCs, they w=
ere MIPS-based before, now ARM/ARM64-based=2E Any MIPS-based SoC that has t=
his controller is using one of Broadcom's BMIPS processor (4350/4380/5000/5=
200) and all obey the same rule that their endian strap propagates to bus r=
egister endian setting as such that the result is always native endian for =
them=2E All ARM/ARM64-based SoC are paired with a newer version of the regi=
ster bus that voluntarily dropped support for changing its endian, such tha=
t it is always LE for these newer SoCs=2E

You won't find this controller in any other product from Broadcom, just li=
ke there was not a version designed for e=2Eg: running on a PCI(e) attached=
 FPGA or anything=2E

>If nothing else the driver code should be predicated on a
>condition set by the kernel config that depends on the cpu build
>rather than embedding that condition in a lot of drivers

The driver is made to build for as many configurations as possible but it =
won't get probed unless the appropriate DT nodes are populated=2E

--=20
Florian
