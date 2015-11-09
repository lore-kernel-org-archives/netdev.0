From: Dexuan Cui <decui@microsoft.com>
Subject: RE: linux-next network throughput performance regression
Date: Mon, 9 Nov 2015 02:39:24 +0000
Message-ID: <6c0fed5fc63a4c3488f5f08409f508ee@HKXPR30MB0039.064d.mgd.msft.net>
References: <CY1PR03MB13760C9F1AABC4EBC455B85CC4280@CY1PR03MB1376.namprd03.prod.outlook.com>
 <563D1180.60206@cumulusnetworks.com>
 <CY1PR03MB13763CB0C0A9C822660E248AC4280@CY1PR03MB1376.namprd03.prod.outlook.com>
 <563D1BE0.2070107@cumulusnetworks.com>
 <1446924959.17135.23.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
 Haiyang Zhang <haiyangz@microsoft.com>, David Miller <davem@davemloft.net>,
 "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
 "devel@linuxdriverproject.org" <devel@linuxdriverproject.org>
To: Eric Dumazet <eric.dumazet@gmail.com>, David Ahern
 <dsa@cumulusnetworks.com>, Simon Xiao <sixiao@microsoft.com>
Return-path: <driverdev-devel-bounces@linuxdriverproject.org>
In-Reply-To: <1446924959.17135.23.camel@edumazet-glaptop2.roam.corp.google.com>
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

> From: devel [mailto:driverdev-devel-bounces@linuxdriverproject.org] On Behalf
> Of Eric Dumazet
> Sent: Sunday, November 8, 2015 3:36
> To: David Ahern <dsa@cumulusnetworks.com>
> Cc: netdev@vger.kernel.org; Haiyang Zhang <haiyangz@microsoft.com>; linux-
> kernel@vger.kernel.org; devel@linuxdriverproject.org; David Miller
> <davem@davemloft.net>
> Subject: Re: linux-next network throughput performance regression
> 
> On Fri, 2015-11-06 at 14:30 -0700, David Ahern wrote:
> > On 11/6/15 2:18 PM, Simon Xiao wrote:
> > > The .config file used to build linux-next kernel is attached to this mail.
> >
> > Thanks.
> >
> > Failed to notice this on the first response; my brain filled in. Why
> > linux-next tree? Can you try net-next which is more relevant for this
> > mailing list, post the top commit id and config file used?
> 
> Throughput on a single TCP flow for a 40G NIC can be tricky to tune.
Why is a single TCP flow trickier than multiple TCP flows?
IMO it should be easier to analyze the issue of a single TCP flow?

Here the perf drop in Simon's test is very obvious -- 50%, but it looks Eric
can't reproduce it, so I suppose some net-related kernel config options may
do the magic?

Maybe Simon can narrow the regression down by bisecting. :-)
 
> Make sure IRQ are properly setup/balanced, as I know that IRQ names were
> changed recently and your scripts might have not noticed...
> 
> Also "ethtool -c eth0" might show very different interrupt coalescing
> params ?
> 
> I too have a Mellanox 40Gb in my lab and saw no difference in
> performance with recent kernels.
> 
> Of course, a simple "perf record -a -g sleep 4 ; perf report" might
> point to some obvious issue. Like unexpected segmentation in case of
> forwarding...
> 

Thanks,
-- Dexuan
