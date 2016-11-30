From: Richard Cochran <richardcochran@gmail.com>
Subject: Re: [PATCH 4/6] net: ethernet: ti: cpts: add ptp pps support
Date: Wed, 30 Nov 2016 19:45:11 +0100
Message-ID: <20161130184511.GB8209@netboy>
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
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f67.google.com ([74.125.82.67]:33644 "EHLO
        mail-wm0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753815AbcK3SpQ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 30 Nov 2016 13:45:16 -0500
Content-Disposition: inline
In-Reply-To: <20161128230428.6872-5-grygorii.strashko@ti.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Nov 28, 2016 at 05:04:26PM -0600, Grygorii Strashko wrote:
> +static cycle_t cpts_cc_ns2cyc(struct cpts *cpts, u64 nsecs)
> +{
> +	cycle_t cyc = (nsecs << cpts->cc.shift) + nsecs;
> +
> +	do_div(cyc, cpts->cc.mult);
> +
> +	return cyc;
> +}

So you set the comparison value once per second, based on cc.mult.
But when the clock is being actively synchronized, user space calls to
clock_adjtimex() will change cc.mult.  This can happen several times
per second, depending on the PTP Sync rate.

In order to produce the PPS edge correctly, you would have to adjust
the comparison value whenever cc.mult changes, but of course this is
unworkable.

So I'll have to say NAK for this patch.

Thanks,
Richard
