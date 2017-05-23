From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH net-next] net: dsa: support cross-chip ageing time
Date: Tue, 23 May 2017 14:06:22 -0700
Message-ID: <625bdf3b-c23e-9e8e-acda-abdadc25a69a@gmail.com>
References: <20170523192059.1720-1-vivien.didelot@savoirfairelinux.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, kernel@savoirfairelinux.com,
        "David S. Miller" <davem@davemloft.net>,
        Andrew Lunn <andrew@lunn.ch>
To: Vivien Didelot <vivien.didelot@savoirfairelinux.com>,
        netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f67.google.com ([74.125.82.67]:33365 "EHLO
        mail-wm0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1162326AbdEWVGb (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 23 May 2017 17:06:31 -0400
In-Reply-To: <20170523192059.1720-1-vivien.didelot@savoirfairelinux.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 05/23/2017 12:20 PM, Vivien Didelot wrote:
> Now that the switchdev bridge ageing time attribute is propagated to all
> switch chips of the fabric, each switch can check if the requested value
> is valid and program itself, so that the whole fabric shares a common
> ageing time setting.
> 
> This is especially needed for switch chips in between others, containing
> no bridge port members but evidently used in the data path.
> 
> To achieve that, remove the condition which skips the other switches. We
> also don't need to identify the target switch anymore, thus remove the
> sw_index member of the dsa_notifier_ageing_time_info notifier structure.
> 
> On ZII Dev Rev B (with two 88E6352 and one 88E6185) and ZII Dev Rev C
> (with two 88E6390X), we have the following hardware configuration:
> 
>     # ip link add name br0 type bridge
>     # ip link set master br0 dev lan6
>     br0: port 1(lan6) entered blocking state
>     br0: port 1(lan6) entered disabled state
>     # echo 2000 > /sys/class/net/br0/bridge/ageing_time
> 
> Before this patch:
> 
>     zii-rev-b# cat /sys/kernel/debug/mv88e6xxx/sw*/age_time
>     300000
>     300000
>     15000
> 
>     zii-rev-c# cat /sys/kernel/debug/mv88e6xxx/sw*/age_time
>     300000
>     18750
> 
> After this patch:
> 
>     zii-rev-b# cat /sys/kernel/debug/mv88e6xxx/sw*/age_time
>     15000
>     15000
>     15000
> 
>     zii-rev-c# cat /sys/kernel/debug/mv88e6xxx/sw*/age_time
>     18750
>     18750
> 
> Signed-off-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>

Reviewed-by: Florian Fainelli <f.fainelli@gmail.com>
-- 
Florian
