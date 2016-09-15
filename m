From: Richard Cochran <richardcochran@gmail.com>
Subject: Re: [PATCH 3/9] net: ethernet: ti: cpts: rework
 initialization/deinitialization
Date: Thu, 15 Sep 2016 10:13:41 +0200
Message-ID: <20160915081341.GA25737@localhost.localdomain>
References: <20160914130231.3035-1-grygorii.strashko@ti.com>
 <20160914130231.3035-4-grygorii.strashko@ti.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
        Mugunthan V N <mugunthanvnm@ti.com>,
        Sekhar Nori <nsekhar@ti.com>, linux-kernel@vger.kernel.org,
        linux-omap@vger.kernel.org, WingMan Kwok <w-kwok2@ti.com>
To: Grygorii Strashko <grygorii.strashko@ti.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20160914130231.3035-4-grygorii.strashko@ti.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Sep 14, 2016 at 04:02:25PM +0300, Grygorii Strashko wrote:
> The current implementation CPTS initialization and deinitialization
> (represented by cpts_register/unregister()) is pretty entangled and
> has some issues, like:
> - ptp clock registered before spinlock, which is protecting it, and
> before timecounter and cyclecounter initialization;
> - CPTS ref_clk requested using devm API while cpts_register() is
> called from .ndo_open(), as result additional checks required;
> - CPTS ref_clk is prepared, but never unprepared;
> - CPTS is not disabled even when unregistered..

This list of four items is a clear sign that this one patch should be
broken into a series of four.

Thanks,
Richard
