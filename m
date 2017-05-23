From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH net-next] net: dsa: support cross-chip ageing time
Date: Tue, 23 May 2017 22:20:06 +0200
Message-ID: <20170523202006.GC24807@lunn.ch>
References: <20170523192059.1720-1-vivien.didelot@savoirfairelinux.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        kernel@savoirfairelinux.com,
        "David S. Miller" <davem@davemloft.net>,
        Florian Fainelli <f.fainelli@gmail.com>
To: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20170523192059.1720-1-vivien.didelot@savoirfairelinux.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, May 23, 2017 at 03:20:59PM -0400, Vivien Didelot wrote:
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

Reviewed-by: Andrew Lunn <andrew@lunn.ch>

    Andrew
