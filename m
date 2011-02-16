From: "Mr. James W. Laferriere" <babydr@baby-dragons.com>
Subject: Re: [kernel] net.ipv6.route.max_size
Date: Tue, 15 Feb 2011 16:29:20 -0900 (AKST)
Message-ID: <alpine.LNX.2.01.1102151627260.23788@filesrv1.baby-dragons.com>
References: <alpine.LFD.2.00.1102142024460.6561@oceanic.wsisiz.edu.pl>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII; format=flowed
Cc: Linux Kernel Maillist <linux-kernel@vger.kernel.org>,
	NetDev <netdev@vger.kernel.org>
To: Lukasz Trabinski <lukasz@trabinski.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <alpine.LFD.2.00.1102142024460.6561@oceanic.wsisiz.edu.pl>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

 	Hello Lukasz ,
 	Since I have not seen anyone else suggest this or to do so I'll forward 
this onto the NetDev <netdev@vger.kernel.org> list for their perusal as well .

 		Hth ,  JimL

On Mon, 14 Feb 2011, Lukasz Trabinski wrote:
> Hello
>
> IPv6 route table size is still growing. In stanard linux box configuration
> with IPv6 BGP session (with ipv6 world table) and BGP application like 
> Quagga,
> we have problem like this:
>
> 2011/02/12 18:43:52 ZEBRA: netlink-cmd error: Cannot allocate memory,
> type=RTM_NEWROUTE(24), seq=11124600, pid=0
>
> This problem shows us that's all prefixes comes from BGP can't be install 
> into FIB
>
> IN BGP application we can see, that's we recive 4484 prefixes from ipv6 
> neighbor:
>
> cosmos> show bgp summary
> Neighbor        V    AS MsgRcvd MsgSent   TblVer  InQ OutQ Up/Down 
> State/PfxRcd
> 2001:1a68:0:c::1
>                4 24724  431945   70172        0    0    0 2d01h18m     4484
>
>
> I suggest that net->ipv6.sysctl.ip6_rt_max_size should be increase.
> Below _simple_ patch for this problem. I don't understand why in ipv4/route 
> we have different method to count ip4_rt_max_size? My value 65536 in near 
> future will be also wrong. I know also, that we can change it by sysctl, but 
> I thing that it's not good way to fix it.
>
>
> --- route.c~    2011-02-14 20:26:12.000000000 +0100
> +++ route.c     2011-02-14 20:30:04.000000000 +0100
> @@ -2708,7 +2708,7 @@
> #endif
>
>        net->ipv6.sysctl.flush_delay = 0;
> -       net->ipv6.sysctl.ip6_rt_max_size = 4096;
> +       net->ipv6.sysctl.ip6_rt_max_size = 65536;
>        net->ipv6.sysctl.ip6_rt_gc_min_interval = HZ / 2;
>        net->ipv6.sysctl.ip6_rt_gc_timeout = 60*HZ;
>        net->ipv6.sysctl.ip6_rt_gc_interval = 30*HZ;
>
> --
> To unsubscribe from this list: send the line "unsubscribe linux-kernel" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> Please read the FAQ at  http://www.tux.org/lkml/
>

-- 
+------------------------------------------------------------------+
| James   W.   Laferriere | System    Techniques | Give me VMS     |
| Network&System Engineer | 3237     Holden Road |  Give me Linux  |
| babydr@baby-dragons.com | Fairbanks, AK. 99709 |   only  on  AXP |
+------------------------------------------------------------------+
