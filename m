From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: Options for forcedeth Linux kernel module
Date: Sun, 14 Nov 2004 12:53:00 +0100
Message-ID: <20041114115300.GA32451@electric-eye.fr.zoreil.com>
References: <200411131913.iADJDZ321996@sun80.thp.Uni-Koeln.DE> <41971E3B.40605@stud.feec.vutbr.cz> <200411141028.iAEASVL27021@sun80.thp.Uni-Koeln.DE>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Michal Schmidt <xschmi00@stud.feec.vutbr.cz>, netdev@oss.sgi.com,
        c-d.hailfinger.kernel.2004@gmx.net, manfred@colorfullife.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Andreas Sindermann <sinder@thp.Uni-Koeln.DE>
Content-Disposition: inline
In-Reply-To: <200411141028.iAEASVL27021@sun80.thp.Uni-Koeln.DE>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Andreas Sindermann <sinder@thp.Uni-Koeln.DE> :
[...]
> Thanks for your answer! I tried ethtool but without success. The
> mii-tool doesn't seem to be delivered with Suse 9.2 and I can't find
> the sources right now on the net. Here what I tried with ethtool:
> 
> linux3:~ # ethtool  -s eth0 speed 100 duplex full autoneg off
> Cannot get current device settings: Operation not supported
>   not setting speed
>   not setting duplex
>   not setting autoneg
[...]
> So unfortunately ethtool doesn't seem to work properly for me at the
> moment.

At least in 2.6.10-rc1-bk20 + 2.6.10-rc1-bk14-netdev1, the driver does
not provide a set_settings() method in its ethtool_ops structure. It
does not use generic_mii_ioctl() or support SIOC#MII### either.
So neither ethtool nor mii-tool will allow you to set the required
option.

Otoh it seems that phy_init() contains most of the code one needs to
glue to have mii-tool/ethtool support.

--
Ueimor
