From: Richard Cochran <richardcochran@gmail.com>
Subject: Re: [PATCH 7/9] net: ethernet: ti: cpts: calc mult and shift from
 refclk freq
Date: Thu, 15 Sep 2016 13:58:15 +0200
Message-ID: <20160915115814.GB24676@localhost.localdomain>
References: <20160914130231.3035-1-grygorii.strashko@ti.com>
 <20160914130231.3035-8-grygorii.strashko@ti.com>
 <20160914202618.GC12195@netboy>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
        Mugunthan V N <mugunthanvnm@ti.com>,
        Sekhar Nori <nsekhar@ti.com>, linux-kernel@vger.kernel.org,
        linux-omap@vger.kernel.org, WingMan Kwok <w-kwok2@ti.com>
To: Grygorii Strashko <grygorii.strashko@ti.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20160914202618.GC12195@netboy>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Sep 14, 2016 at 10:26:19PM +0200, Richard Cochran wrote:
> On Wed, Sep 14, 2016 at 04:02:29PM +0300, Grygorii Strashko wrote:
> > +	clocks_calc_mult_shift(&mult, &shift, freq, NSEC_PER_SEC, maxsec);
> > +
> > +	cpts->cc_mult = mult;
> > +	cpts->cc.mult = mult;
> 
> In order to get good resolution on the frequency adjustment, we want
> to keep 'mult' as large as possible.  I don't see your code doing
> this.  We can rely on the watchdog reader (work queue) to prevent
> overflows.

I took a closer look, and assuming cc.mask = 2^32 - 1, then using
clocks_calc_mult_shift() produces good results for a reasonable range
of input frequencies.  Keeping 'maxsec' constant at 4 we have:

   | Freq. MHz |       mult | shift |
   |-----------+------------+-------|
   |       100 | 0xa0000000 |    28 |
   |       250 | 0x80000000 |    29 |
   |       500 | 0x80000000 |    30 |
   |      1000 | 0x80000000 |    31 |

Can the input clock be higher than 1 GHz?  If not, I suggest using
clocks_calc_mult_shift() with maxsec=4 and a setting the watchdog also
to 4*HZ.

Thanks,
Richard
