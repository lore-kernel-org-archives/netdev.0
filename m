From: Ben Greear <greearb@candelatech.com>
Subject: Re: [RFC] enhanced version of net_random()
Date: Thu, 12 Aug 2004 13:02:15 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <411BCCC7.2090804@candelatech.com>
References: <20040812104835.3b179f5a@dell_ss3.pdx.osdl.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@redhat.com>, Alan Cox <alan@lxorguk.ukuu.org.uk>,
        "Theodore Ts'o" <tytso@mit.edu>, netdev@oss.sgi.com,
        linux-kernel@vger.kernel.org
Return-path: <netdev-bounce@oss.sgi.com>
To: Stephen Hemminger <shemminger@osdl.org>
In-Reply-To: <20040812104835.3b179f5a@dell_ss3.pdx.osdl.net>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Stephen Hemminger wrote:
> While doing the network emulator, I discovered that the default net_random()
> is too stupid, and get_random_bytes() is more than needed. Rather than put
> another function in just for sch_netem, how about making net_random() smarter?
> The tin-hat crowd already replace net_random() with get_random_bytes anyway.
> 
> Here is a proposed alternative to use a longer period PRNG for net_random().
> The choice of TT800 was because it was freely available, had a long period,
> was fast and relatively small footprint. The existing net_random() was not
> really thread safe, but was immune to thread corruption. 

Is it really worth the extra spin lock & math?  Maybe we could have a
net_more_random() method instead that encompasses this improved random logic?

Ben

-- 
Ben Greear <greearb@candelatech.com>
Candela Technologies Inc  http://www.candelatech.com
