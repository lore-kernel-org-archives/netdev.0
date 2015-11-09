From: Dexuan Cui <decui@microsoft.com>
Subject: RE: linux-next network throughput performance regression
Date: Mon, 9 Nov 2015 03:11:35 +0000
Message-ID: <eaea78c44de44abcb7936ab070f1b09d@HKXPR30MB0039.064d.mgd.msft.net>
References: <563D1BE0.2070107@cumulusnetworks.com>
 <1446924959.17135.23.camel@edumazet-glaptop2.roam.corp.google.com>
 <6c0fed5fc63a4c3488f5f08409f508ee@HKXPR30MB0039.064d.mgd.msft.net>
 <20151108.215247.1161049251544860672.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: "eric.dumazet@gmail.com" <eric.dumazet@gmail.com>,
 "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
 Haiyang Zhang <haiyangz@microsoft.com>,
 "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
 "devel@linuxdriverproject.org" <devel@linuxdriverproject.org>,
 "dsa@cumulusnetworks.com" <dsa@cumulusnetworks.com>
To: David Miller <davem@davemloft.net>
Return-path: <driverdev-devel-bounces@linuxdriverproject.org>
In-Reply-To: <20151108.215247.1161049251544860672.davem@davemloft.net>
Content-Language: en-US
List-Unsubscribe: <http://driverdev.linuxdriverproject.org/mailman/options/driverdev-devel>,
 <mailto:driverdev-devel-request@linuxdriverproject.org?subject=unsubscribe>
List-Archive: <http://driverdev.linuxdriverproject.org/pipermail/driverdev-devel/>
List-Post: <mailto:driverdev-devel@linuxdriverproject.org>
List-Help: <mailto:driverdev-devel-request@linuxdriverproject.org?subject=help>
List-Subscribe: <http://driverdev.linuxdriverproject.org/mailman/listinfo/driverdev-devel>,
 <mailto:driverdev-devel-request@linuxdriverproject.org?subject=subscribe>
Errors-To: driverdev-devel-bounces@linuxdriverproject.org
Sender: "devel" <driverdev-devel-bounces@linuxdriverproject.org>
List-Id: netdev.vger.kernel.org

> -----Original Message-----
> From: David Miller [mailto:davem@davemloft.net]
> Sent: Monday, November 9, 2015 10:53
> To: Dexuan Cui <decui@microsoft.com>
> Cc: eric.dumazet@gmail.com; dsa@cumulusnetworks.com; Simon Xiao
> <sixiao@microsoft.com>; netdev@vger.kernel.org; Haiyang Zhang
> <haiyangz@microsoft.com>; linux-kernel@vger.kernel.org;
> devel@linuxdriverproject.org
> Subject: Re: linux-next network throughput performance regression
> 
> From: Dexuan Cui <decui@microsoft.com>
> Date: Mon, 9 Nov 2015 02:39:24 +0000
> 
> >> Throughput on a single TCP flow for a 40G NIC can be tricky to tune.
> > Why is a single TCP flow trickier than multiple TCP flows?
> > IMO it should be easier to analyze the issue of a single TCP flow?
> 
> Because a single TCP flow can only use one of the many TX queues
> that such modern NICs have.
> 
> The single TX queue becomes the bottleneck.
> 
> Whereas if you have several TCP flows, all of them can use independant
> TX queues on the NIC in parallel to fill the link with traffic.
> 
> That's why.

Thanks, David!
I understand 1 TX queue is the bottleneck (however in Simon's
test, TX=1 => 36.7Gb/s, TX=8 => 37.7 Gb/s, so it looks the TX=1 bottleneck
is not so obvious).
I'm just wondering how the bottleneck became much narrower with
recent linux-next in Simon's result (36.7 Gb/s vs. 18.2 Gb/s). IMO there
must be some latency somewhere.

Thanks,
-- Dexuan
