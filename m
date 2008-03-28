From: Harald Hannelius <harald@iki.fi>
Subject: Re: tg3 bad performance, lots of hardware interrupts
Date: Fri, 28 Mar 2008 15:04:25 +0200 (EET)
Message-ID: <alpine.DEB.1.00.0803281440460.23558@penti.org>
References: <alpine.DEB.1.00.0803271532570.30549@penti.org> <20080327.144925.196529669.davem@davemloft.net> <1206666100.5368.6.camel@dell>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; format=flowed; charset=US-ASCII
Cc: David Miller <davem@davemloft.net>, linux-kernel@vger.kernel.org,
	netdev <netdev@vger.kernel.org>
To: Michael Chan <mchan@broadcom.com>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1758293AbYC1NEp@vger.kernel.org>
In-Reply-To: <1206666100.5368.6.camel@dell>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


On Thu, 27 Mar 2008, Michael Chan wrote:

> On Thu, 2008-03-27 at 14:49 -0700, David Miller wrote:
>> From: Harald Hannelius <harald@iki.fi>
>> Date: Thu, 27 Mar 2008 15:53:56 +0200 (EET)
>>
>>> I experience a lot of hardware interrupts with a BCM5751 PCI-express NIC
>>> (tg3). modprobe tg3, ifconfig ethX up and friends makes the system
>>> unresponsive. Just having the interface up makes the system sluggish.
>>>
>
> I just tested a similar NIC using the same kernel and driver, but I did
> not notice anything unusual.  netperf gave me 941Mbps.
>
>>> Onboard forcedeth works fine (with the same cable).
>>>
>>> iperf gives me just 2Mbps on a 1Gbps ethernet. Load average near 1.0. top
>>> reports 40-50%hi (hardware interrupts) when generating traffic over that
>>> interface.
>
> Can you look at /proc/interrupts to see roughly how many are reported
> per second when link is down, link is up with no traffic, and with
> traffic?
>
> Finally, you can also try ethtool -t eth0 to see if it passes a simple
> self test.

Phew, I thought that running ethtool -t was like doing stop-A-sync on a 
Sun. It took almost half an hour to run that ethtool -t command;

'mpstat 2' output while running 'ethtool -t eth2':

Full log here (2160 lines): http://www.iki.fi/~harald/mpstat.log

A few lines from that log here;

Linux 2.6.24.4 (mauer)  03/28/2008

10:37:14 AM  CPU   %user   %nice    %sys %iowait    %irq   %soft  %steal   %idle    intr/s
10:37:16 AM  all    0.00    0.00    0.00    0.00    0.00    0.00    0.00  100.00    115.50
10:37:18 AM  all    0.00    0.00    1.00    0.00    0.00    0.00    0.00  99.00    123.50
10:37:20 AM  all    0.00    0.00    0.75    0.00    0.00    0.00    0.00   99.25    142.79
10:37:23 AM  all    0.00    0.00   25.66    0.00   23.77    2.26    0.00   48.30     76.38
10:37:25 AM  all    0.00    0.00   17.13    0.00   31.12   21.68    0.00   30.07     75.12
10:37:27 AM  all    0.00    0.00   12.17    0.00   25.48   28.90    0.00   33.46    103.00
10:37:29 AM  all    0.00    0.00    0.40    0.00   38.15   23.29    0.00   38.15     70.15
10:37:31 AM  all    0.00    0.00    0.40    0.00   41.90   23.32    0.00   34.39     71.43
10:37:33 AM  all    0.00    0.00    2.83    0.00   29.68   34.98    0.00   32.51    123.38
10:37:35 AM  all    0.00    0.00   11.07    0.00   33.21   24.81    0.00   30.92     78.74
... goes on like this for almost half-an-hour ...
11:04:03 AM  all    0.00    0.00    0.00    0.00   34.69   22.86    0.00   42.45     71.50
11:04:05 AM  all    0.00    0.00    1.53    0.00   33.72   26.82    0.00   37.93     84.50
11:04:07 AM  all    0.00    0.00    0.40    0.00   38.15   22.89    0.00   38.55     74.26
11:04:09 AM  all    0.00    0.00    0.00    0.00   38.80   21.60    0.00   39.60     72.64
11:04:11 AM  all    0.00    0.00    0.00    0.00   42.17   23.29    0.00   34.54     69.50
11:04:13 AM  all    0.00    0.00    3.60    1.44   31.29   33.45    0.00   30.22    111.39
11:04:15 AM  all    0.00    0.00    0.00    0.00    0.51    0.76    0.00   98.73    110.50
11:04:17 AM  all    0.00    0.00    0.00    0.00    0.00    0.00    0.00  100.00    119.50
11:04:19 AM  all    0.00    0.00    0.25    1.24    0.00    0.00    0.00  98.51    126.87
11:04:21 AM  all    0.00    0.00    0.00    0.00    0.00    0.00    0.00  100.00    106.50
... command finished ...

Sadly I didn't capture the output from ethtool -t, failed anyway. I'm 
running that test a second time right now, I'll post the output later 
(when finished). While the 'ethtool -t eth2' is running eth0 (forcedeth) 
doesn't respond to ping, when going to the console it didn't wake up with 
a keypress, nor did capslock/numlock react.

'mpstat 2' while running modprobe tg3:
Linux 2.6.24.4 (mauer)  03/28/2008

02:47:05 PM  CPU   %user   %nice    %sys %iowait    %irq   %soft  %steal   %idle    intr/s
02:47:07 PM  all    0.00    0.00    0.75    0.00    0.00    0.00    0.00   99.25    138.00
02:47:09 PM  all    0.00    0.00    0.25    0.00    0.00    0.00    0.00   99.75    120.00
02:47:11 PM  all    0.00    0.00    0.00    0.00    0.00    0.00    0.00  100.00    132.50
02:47:13 PM  all    0.00    0.00   14.19    0.00   17.16    1.65    0.00  67.00     92.08
02:47:15 PM  all    0.00    0.00   19.60    0.00   30.40    1.20    0.00  48.80     60.50
02:47:17 PM  all    0.56    0.00    4.20    0.00    5.88    0.28    0.00  89.08    127.14
02:47:19 PM  all    0.00    0.00    0.75    0.00    0.25    0.00    0.00  99.00    127.00

'mpstat 2' while running ifconfig eth2 up:
Linux 2.6.24.4 (mauer)  03/28/2008

02:47:50 PM  CPU   %user   %nice    %sys %iowait    %irq   %soft  %steal   %idle    intr/s
02:47:52 PM  all    0.00    0.00    0.40    0.00   44.95   16.49    0.00   38.16    194.47
02:47:54 PM  all    0.00    0.00    0.76    0.00   46.91   16.77    0.00   35.56    205.47
02:47:56 PM  all    0.00    0.00    2.06    0.00   15.88   14.12    0.00   67.94    107.96

Hope my overlong lines don't get wrapped...


No hints on dmesg on what's going on.



-- 
A: Top Posters!                                      |  s/y Charlotta |
Q: What is the most annoying thing on mailing lists? |    FIN-2674    |
   http://www.fe83.org/ Finn Express Purjehtijat ry   |  ============= |
Harald H Hannelius | harald (At) iki (dot) fi | GSM +358 50 594 1020
