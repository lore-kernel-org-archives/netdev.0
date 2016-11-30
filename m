From: Richard Cochran <richardcochran@gmail.com>
Subject: Re: [PATCH 4/6] net: ethernet: ti: cpts: add ptp pps support
Date: Wed, 30 Nov 2016 11:05:19 +0100
Message-ID: <20161130100519.GD28680@localhost.localdomain>
References: <20161128230428.6872-1-grygorii.strashko@ti.com>
 <20161128230428.6872-5-grygorii.strashko@ti.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
        Mugunthan V N <mugunthanvnm@ti.com>,
        Sekhar Nori <nsekhar@ti.com>, linux-kernel@vger.kernel.org,
        linux-omap@vger.kernel.org, Rob Herring <robh+dt@kernel.org>,
        devicetree@vger.kernel.org, Murali Karicheri <m-karicheri2@ti.com>,
        Wingman Kwok <w-kwok2@ti.com>
To: Grygorii Strashko <grygorii.strashko@ti.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20161128230428.6872-5-grygorii.strashko@ti.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Nov 28, 2016 at 05:04:26PM -0600, Grygorii Strashko wrote:
> The TS_COMP output in the CPSW CPTS module is asserted for
> ts_comp_length[15:0] RCLK periods when the time_stamp value compares
> with the ts_comp_val[31:0] and the length value is non-zero. The
> TS_COMP pulse edge occurs three RCLK periods after the values
> compare. A timestamp compare event is pushed into the event FIFO when
> TS_COMP is asserted.
> 
> This patch adds support of Pulse-Per-Second (PPS) by using the
> timestamp compare output. The CPTS driver adds one second of counter
> value to the ts_comp_val register after each assertion of the TS_COMP
> output. The TS_COMP pulse polarity and width are configurable in DT.

I really dislike this patch.  You go through contortions to get from
the timecounter back to the raw HW counter.  That is rather ugly.

Can you adjust the frequency of the keystone devices in hardware?  If
so, then please implement it, and just disable PPS for the CPSW.

The only reason I used the timecounter for frequency adjustment was
because the am335x HW is broken.  But this shouldn't hold back other
newer HW without the same silicon flaws.

Thanks,
Richard
