From: Stephen Hemminger <shemminger@osdl.org>
Subject: Re: V2.4 policy router operates faster/better than V2.6
Date: Mon, 3 Jan 2005 14:51:15 -0800
Message-ID: <20050103145115.4bdb2cd6@dxpl.pdx.osdl.net>
References: <200501031455.26980.jeremy.guthrie@berbee.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: jeremy.guthrie@berbee.com
In-Reply-To: <200501031455.26980.jeremy.guthrie@berbee.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Mon, 3 Jan 2005 14:55:24 -0600
"Jeremy M. Guthrie" <jeremy.guthrie@berbee.com> wrote:

> I have a dual processor box running Suse 9.1 Ent. that I changed over to the 
> V2.6.10 kernel.  The box has two interfaces in it, both E1000s.  The box 
> receives anywhere from  200mbit to 500+ mbit that it needs to route out to 
> other boxes.  The policy routing table is running ~ 150-200 rules.  ie.  data 
> comes in E3(e1000), is policy routed to a destination sent out E2(e1000).
> 
> Under V2.4 kernels, the system will operate just fine and drop few packets if 
> any.  ie. right now under V2.4, I have dropped all of three packets.  Under 
> 2.6, I can watch the RX drop counter increment.  See below.
> 
> [h-pr-msn-1 guthrie 1:48pm]~-> ifconfig eth3 ; sleep 10 ; ifconfig eth3
> eth3      Link encap:Ethernet  HWaddr 00:02:B3:D5:7E:30
>           inet addr:10.253.0.1  Bcast:10.255.255.255  Mask:255.255.255.0
>           inet6 addr: fe80::202:b3ff:fed5:7e30/64 Scope:Link
>           UP BROADCAST RUNNING MULTICAST  MTU:1500  Metric:1
>           RX packets:132919934 errors:311285 dropped:311285 overruns:247225 
> frame:0
>           TX packets:6 errors:0 dropped:0 overruns:0 carrier:0
>           collisions:0 txqueuelen:1000
>           RX bytes:2630721320 (2508.8 Mb)  TX bytes:484 (484.0 b)
>           Base address:0x22a0 Memory:eff80000-effa0000
> 
> eth3      Link encap:Ethernet  HWaddr 00:02:B3:D5:7E:30
>           inet addr:10.253.0.1  Bcast:10.255.255.255  Mask:255.255.255.0
>           inet6 addr: fe80::202:b3ff:fed5:7e30/64 Scope:Link
>           UP BROADCAST RUNNING MULTICAST  MTU:1500  Metric:1
>           RX packets:133847068 errors:325697 dropped:325697 overruns:258546 
> frame:0
>           TX packets:6 errors:0 dropped:0 overruns:0 carrier:0
>           collisions:0 txqueuelen:1000
>           RX bytes:3102796062 (2959.0 Mb)  TX bytes:484 (484.0 b)
>           Base address:0x22a0 Memory:eff80000-effa0000
> 
> If I turn off the policy routing, I instantly stop getting RX errors or 
> overruns as it appears the CPU can now pay attention to the packets coming in 
> and drop them(as I turned off IP forwarding as well).
> 
> V2.4 Kernel mpstat data:
> command:  mpstat -P ALL 60
> Linux 2.4.21-251-smp (h-pr-msn-1) 12/15/2004
> 
> 01:16:24 PM  CPU   %user   %nice %system   %idle    intr/s
> 01:17:19 PM  all    0.16    0.00   50.12   49.72  42114.18
> 01:17:19 PM    0    0.12    0.00   55.60   44.28  42114.18
> 01:17:19 PM    1    0.20    0.00   44.65   55.15  42114.18
> 
> 01:17:19 PM  CPU   %user   %nice %system   %idle    intr/s
> 01:18:19 PM  all    0.13    0.00   48.49   51.38  42103.08
> 01:18:19 PM    0    0.13    0.00   31.88   67.98  42103.08
> 01:18:19 PM    1    0.13    0.00   65.10   34.77  42103.08
> 
> V2.6 kernel mpstat data:
> command:  mpstat -P ALL 60
> Linux 2.6.5-7.111.5-smp (h-pr-msn-1)         12/15/04
> 
> 13:36:25     CPU   %user   %nice %system %iowait    %irq   %soft   %idle    
> intr/s
> 13:37:25     all    0.13    0.00    0.15    0.09    2.03   43.14   54.45  
> 25506.53
> 13:37:25       0    0.17    0.00    0.08    0.18    0.00   16.81   82.76   
> 2215.63
> 13:37:25       1    0.08    0.00    0.20    0.00    4.08   69.49   26.14  
> 23291.34
> 
> 13:37:25     CPU   %user   %nice %system %iowait    %irq   %soft   %idle    
> intr/s
> 13:38:24     all    0.14    0.00    0.12    0.12    2.02   42.89   54.71  
> 25900.70
> 13:38:24       0    0.03    0.00    0.05    0.22    0.00   16.67   83.03   
> 2246.10
> 13:38:24       1    0.25    0.00    0.20    0.03    4.02   69.12   26.40  
> 23654.55
> 
> Any insights as to why there would be such a stark difference in performance 
> between V2.6 and V2.4?

How many flows are going through the router? The neighbour cache
can get to be a bottleneck. Perhaps Robert "the Router Man" Olssen can
give some hints.
