From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH net] net: systemport: Fix 64-bit stats deadlock
Date: Fri, 15 Sep 2017 14:28:40 -0700
Message-ID: <C414D433-28B3-4BA4-938B-B5C868918532@gmail.com>
References: <1505247266-42195-1-git-send-email-f.fainelli@gmail.com> <20170915.142511.221689318302073484.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain;
 charset=utf-8
Content-Transfer-Encoding: quoted-printable
Cc: netdev@vger.kernel.org, edumazet@google.com, jqiaoulk@gmail.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f68.google.com ([74.125.83.68]:35931 "EHLO
        mail-pg0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751555AbdIOV2p (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 15 Sep 2017 17:28:45 -0400
Received: by mail-pg0-f68.google.com with SMTP id d8so1897474pgt.3
        for <netdev@vger.kernel.org>; Fri, 15 Sep 2017 14:28:45 -0700 (PDT)
In-Reply-To: <20170915.142511.221689318302073484.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On September 15, 2017 2:25:11 PM PDT, David Miller <davem@davemloft=2Enet> =
wrote:
>From: Florian Fainelli <f=2Efainelli@gmail=2Ecom>
>Date: Tue, 12 Sep 2017 13:14:26 -0700
>
>> We can enter a deadlock situation because there is no sufficient
>protection
>> when ndo_get_stats64() runs in process context to guard against RX or
>TX NAPI
>> contexts running in softirq, this can lead to the following lockdep
>splat and
>> actual deadlock was experienced as well with an iperf session in the
>background
>> and a while loop doing ifconfig + ethtool=2E
> =2E=2E=2E
>> So just remove the u64_stats_update_begin()/end() pair in
>ndo_get_stats64()
>> since it does not appear to be useful for anything=2E No inconsistency
>was
>> observed with either ifconfig or ethtool, global TX counts equal the
>sum of
>> per-queue TX counts on a 32-bit architecture=2E
>>=20
>> Fixes: 10377ba7673d ("net: systemport: Support 64bit statistics")
>> Signed-off-by: Florian Fainelli <f=2Efainelli@gmail=2Ecom>
>
>Applied=2E

FYI, there is another patch needed to ensure consistency between ethtool r=
eported stats and netdevice stats, will submit that after some more testing=
=2E Thanks!

--=20
Florian
