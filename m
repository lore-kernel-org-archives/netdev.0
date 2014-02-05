From: Stanislaw Gruszka <sgruszka@redhat.com>
Subject: Re: [RFC PATCH] net: wireless: move regulatory timeout work to power
 efficient workqueue
Date: Wed, 5 Feb 2014 10:17:42 +0100
Message-ID: <20140205091742.GA1978@redhat.com>
References: <1391123310-6425-1-git-send-email-zoran.markovic@linaro.org>
 <1391160084.4141.1.camel@jlt4.sipsolutions.net>
 <20140131093531.GA25559@mtj.dyndns.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Johannes Berg <johannes@sipsolutions.net>,
	Zoran Markovic <zoran.markovic@linaro.org>,
	linux-kernel@vger.kernel.org, linux-wireless@vger.kernel.org,
	netdev@vger.kernel.org, Shaibal Dutta <shaibal.dutta@broadcom.com>,
	"John W. Linville" <linville@tuxdriver.com>,
	"David S. Miller" <davem@davemloft.net>
To: Tejun Heo <tj@kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20140131093531.GA25559@mtj.dyndns.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi

On Fri, Jan 31, 2014 at 04:35:31AM -0500, Tejun Heo wrote:
> On Fri, Jan 31, 2014 at 10:21:24AM +0100, Johannes Berg wrote:
> > I'm not sure if this is part of a larger patchset actually adding that
> > "system_power_efficient_wq", but maybe it'd be better to expose a
> > function as an API rather than the wq struct?
> > 
> > Something like
> > 
> > scheduled_delayed_work_pwr_efficient(...)?
> 
> While there are some benefits to using dedicated functions for
> specific workqueues, I don't think it brings enough benefits to
> justify adding dedicated API and am unlikely to add new ones.

What are selection criteria when choosing between system_wq or
system_power_efficient_wq on drivers ? IOW if I would be writing
a new driver which workqueue should I use and when ?

I think that should be driver independent, at least for most of drivers.
If system have to run in low power mode, system_power_efficient_wq
should be chosen automatically by schedule_work(), otherwise when high
performance is more important schedule_work() should use system_wq.

Stanislaw
