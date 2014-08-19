From: Haiyang Zhang <haiyangz@microsoft.com>
Subject: RE: [hyperv] BUG at drivers/hv/channel.c:462 while changing MTU
Date: Tue, 19 Aug 2014 21:29:44 +0000
Message-ID: <8dcf334714c44eeda54ecb129479719b@DFM-DB3MBX15-06.exchange.corp.microsoft.com>
References: <20140819123655.GC12160@sucs.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
	"devel@linuxdriverproject.org" <devel@linuxdriverproject.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	Jason Wang <jasowang@redhat.com>,
	Daniel Borkmann <dborkman@redhat.com>,
	"David S. Miller" <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Sitsofe Wheeler <sitsofe@gmail.com>,
	KY Srinivasan <kys@microsoft.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20140819123655.GC12160@sucs.org>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org



> -----Original Message-----
> From: Sitsofe Wheeler [mailto:sitsofe@gmail.com]
> Sent: Tuesday, August 19, 2014 8:37 AM
> To: KY Srinivasan
> Cc: Greg Kroah-Hartman; Haiyang Zhang; devel@linuxdriverproject.org;
> linux-kernel@vger.kernel.org; Jason Wang; Daniel Borkmann; David S.
> Miller; netdev@vger.kernel.org
> Subject: [hyperv] BUG at drivers/hv/channel.c:462 while changing MTU
> 
> Now we get to the issue I've been meaning to report: changing the MTU of
> a Hyper-V network interface while traffic is flowing through it triggers
> a BUG. I've seen this happen on a variety of kernels but the trace below
> is from 3.17.0-rc1.
> 
> Steps to reproduce:
> (Guests were customised Fedora 20 cloud images)
> 1.On Hyper-V VM 1 run
> iperf -s
> 2. On Hyper-V VM 2 run
> iperf -c <Hyper-V VM 1 host address> -t 200
> 3. On Hyper-V VM 2 run
> ip link set dev eth0 mtu 9000
> 
> Expected results:
> MTU of eth0 to be changed, packets to keep flowing or stop, interface to
> be at alive enough to be reconfigured.
> 
> Actual results:
> Error messages on the console, eth0 winds up dead.
> 

Thanks for the report.
I tried changing mtu while iperf is running, but unable to reproduce it.
I repeated the changing MTU test 10+ times, the link is stable, and passing 
traffic at ~8Gbps.

Could you try a Distro without customization?
I just want to narrow down the possible causes for it.

Thanks,
- Haiyang
