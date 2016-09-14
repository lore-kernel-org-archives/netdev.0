From: Richard Cochran <richardcochran@gmail.com>
Subject: Re: [PATCH 7/9] net: ethernet: ti: cpts: calc mult and shift from
 refclk freq
Date: Wed, 14 Sep 2016 23:03:32 +0200
Message-ID: <20160914210332.GG12195@netboy>
References: <20160914130231.3035-1-grygorii.strashko@ti.com>
 <20160914130231.3035-8-grygorii.strashko@ti.com>
 <20160914202618.GC12195@netboy>
 <4add2983-bdfe-8436-de62-4b2fdc2ea750@ti.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
        Mugunthan V N <mugunthanvnm@ti.com>,
        Sekhar Nori <nsekhar@ti.com>, linux-kernel@vger.kernel.org,
        linux-omap@vger.kernel.org, WingMan Kwok <w-kwok2@ti.com>,
        John Stultz <john.stultz@linaro.org>
To: Grygorii Strashko <grygorii.strashko@ti.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <4add2983-bdfe-8436-de62-4b2fdc2ea750@ti.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Sep 14, 2016 at 11:47:46PM +0300, Grygorii Strashko wrote:
> As I understand (and tested), clocks_calc_mult_shift() will 
> return max possible mult which can be used without overflow.

Yes, BUT the returned values depends on the @maxsec input.  As the
kerneldec says,

 * Larger ranges may reduce the conversion accuracy by chosing smaller
 * mult and shift factors.

In addition to that, frequency tuning by calculating a percentage of
'mult', and if 'mult' is small, then the tuning resolution is poor.

So we don't want @maxsec as large as possible, but as small as
possible.

> if calculated results do not satisfy end user - the custom values can
> be passed in DT.  

If we calculate automatically, then the result had better well be
optimal or nearly so.  Otherwise, we should leave it as a manual input
via DTS, IMHO, so that someone is forced to check the values.

Thanks,
Richard
