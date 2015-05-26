From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] net: tcp: Fix a PTO timing granularity issue
Date: Tue, 26 May 2015 11:25:21 -0700
Message-ID: <1432664721.4060.294.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1432650358-11470-1-git-send-email-ido@wizery.com>
	 <1432657435.4060.267.camel@edumazet-glaptop2.roam.corp.google.com>
	 <20150526170222.GA13376@WorkStation.home>
	 <1432660420.4060.271.camel@edumazet-glaptop2.roam.corp.google.com>
	 <20150526175540.GB13376@WorkStation.home>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	James Morris <jmorris@namei.org>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	Patrick McHardy <kaber@trash.net>,
	Nandita Dukkipati <nanditad@google.com>,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Ido Yariv <idox.yariv@intel.com>
To: Ido Yariv <ido@wizery.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20150526175540.GB13376@WorkStation.home>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 2015-05-26 at 13:55 -0400, Ido Yariv wrote:

> 
> The platform this was tested on was an embedded platform with a wifi
> module (11n, 20MHZ). The other end was a computer running Windows, and
> the benchmarking software was IxChariot.
> The whole setup was running in a shielded box with minimal
> interferences.
> 
> As it seems, the throughput was limited by the congestion window.
> Further analysis led to TLP - the fact that its timer was expiring
> prematurely impacted cwnd, which in turn prevented the wireless driver
> from having enough skbs to buffer and send.
> 
> Increasing the size of the chunks being sent had a similar impact on
> throughput, presumably because the congestion window had enough time to
> increase.
> 
> Changing the congestion window to Westwood from cubic/reno also had a
> similar impact on throughput.
> 

Have you tested what results you had by completely disabling TLP ?

Maybe a timer of 10 to 20ms is too short anyway in your testbed.
