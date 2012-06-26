From: "Huang, Xiong" <xiong@qca.qualcomm.com>
Subject: RE: [PATCH 1/1] atl1c: fix issue of transmit queue 0 timed out
Date: Tue, 26 Jun 2012 20:41:11 +0000
Message-ID: <157393863283F442885425D2C454285623DB49B7@NASANEXD02A.na.qualcomm.com>
References: <1340724786-3819-1-git-send-email-cjren@qca.qualcomm.com>
 <20120626180311.GC5070@tux>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "davem@davemloft.net" <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	qca-linux-team <qca-linux-team@qualcomm.com>,
	nic-devel <nic-devel@qualcomm.com>
To: "Rodriguez, Luis" <rodrigue@qca.qualcomm.com>,
	"Ren, Cloud" <cjren@qca.qualcomm.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20120626180311.GC5070@tux>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Luis
   It should be a stable fix, but as Ben Hutchings mentioned in another mail, 
Maybe, removing netif_stop_queue when cable link down is a better choice.

   Do you mean we need add 'cc:stable@vger.kernel.org'  just before 'some people report  ...' ?

Thanks
Xiong

> -----Original Message-----
> From: Rodriguez, Luis
> Sent: Wednesday, June 27, 2012 2:03
> To: Ren, Cloud
> Cc: davem@davemloft.net; netdev@vger.kernel.org; linux-
> kernel@vger.kernel.org; qca-linux-team; nic-devel; Huang, Xiong
> Subject: Re: [PATCH 1/1] atl1c: fix issue of transmit queue 0 timed out
> 
> On Tue, Jun 26, 2012 at 12:33:06PM -0300, Ren, Cloud wrote:
> > From: xiong <xiong@qca.qualcomm.com>
> >
> > some people report atl1c could cause system hang with following kernel
> > trace info:
> > ---------------------------------------
> > WARNING: at.../net/sched/sch_generic.c:258
> > dev_watchdog+0x1db/0x1d0()
> > ...
> > NETDEV WATCHDOG: eth0 (atl1c): transmit queue 0 timed out ...
> > ---------------------------------------
> > This is caused by netif_stop_queue calling when cable Link is down but
> > netif_wake_queue isn't called when cable Link is resume.
> >
> > Signed-off-by: xiong <xiong@qca.qualcomm.com>
> > Signed-off-by: Cloud Ren <cjren@qca.qualcomm.com>
> 
> If this fixes  a system hang then this could be a stable fix -- that is, this should
> be propagated to older stable kernels, no?
> 
> If so then please add to the commit log a line like this:
> 
> Cc: stable@vger.kernel.org [3.4]
> 
> Note: this is for the commit log! Right above the line below that has "---"
> 
>   Luis
