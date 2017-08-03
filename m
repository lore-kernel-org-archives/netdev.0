From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH net-next] net: dsa: Add support for 64-bit statistics
Date: Thu, 3 Aug 2017 20:11:56 +0200
Message-ID: <20170803181156.GJ15018@lunn.ch>
References: <20170801220036.11355-1-f.fainelli@gmail.com>
 <20170802.164951.1316163070425929253.davem@davemloft.net>
 <e16c44e3-41ee-09cc-a05d-46e22c1404e3@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
        vivien.didelot@savoirfairelinux.com, linux-kernel@vger.kernel.org
To: Florian Fainelli <f.fainelli@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <e16c44e3-41ee-09cc-a05d-46e22c1404e3@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Aug 03, 2017 at 10:30:56AM -0700, Florian Fainelli wrote:
> On 08/02/2017 04:49 PM, David Miller wrote:
> > From: Florian Fainelli <f.fainelli@gmail.com>
> > Date: Tue,  1 Aug 2017 15:00:36 -0700
> > 
> >> DSA slave network devices maintain a pair of bytes and packets counters
> >> for each directions, but these are not 64-bit capable. Re-use
> >> pcpu_sw_netstats which contains exactly what we need for that purpose
> >> and update the code path to report 64-bit capable statistics.
> >>
> >> Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>
> > 
> > Applied, thanks.
> > 
> > I would run ethtool -S and ifconfig under perf to see where it is
> > spending so much time.
> > 
> 
> This appears to be way worse than I thought, will keep digging, but for
> now, I may have to send a revert. Andrew, Vivien can you see if you have
> the same problems on your boards? Thanks!
> 
> # killall iperf
> # [ ID] Interval       Transfer     Bandwidth
> [  3]  0.0-19.1 sec   500 MBytes   220 Mbits/sec
> # while true; do ethtool -S gphy; ifconfig gphy; done
> ^C^C
> 
> 
> [   64.566226] INFO: rcu_sched self-detected stall on CPU
> [   64.571487]  0-...: (25999 ticks this GP) idle=006/140000000000001/0

Hi Florian

I don't get anything so bad, but i think that is because of hardware
restrictions. I see the ethtool; ifconfig loop goes a lot slower when
there is iperf traffic, but i don't get an RCU stall. However, the
board i tested on only has a 100Mbps CPU interface, and it can handle
all that traffic without pushing the CPU to 100%. What is the CPU load
when you run your test? Even if you are going to 100% CPU load, we
still don't want RCU stalls.

      Andrew
