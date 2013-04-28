From: Richard Cochran <richardcochran@gmail.com>
Subject: Re: [PATCH net-next V3 3/5] net/mlx4_en: Add HW timestamping (TS)
 support
Date: Sun, 28 Apr 2013 09:46:29 +0200
Message-ID: <20130428074624.GA5324@netboy>
References: <1366733211-10228-1-git-send-email-amirv@mellanox.com>
 <1366733211-10228-4-git-send-email-amirv@mellanox.com>
 <20130425192627.GA14429@netboy>
 <517CC2A8.5010303@mellanox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	Or Gerlitz <ogerlitz@mellanox.com>,
	Eugenia Emantayev <eugenia@mellanox.com>
To: Amir Vadai <amirv@mellanox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ee0-f54.google.com ([74.125.83.54]:50339 "EHLO
	mail-ee0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751538Ab3D1Hqk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 28 Apr 2013 03:46:40 -0400
Received: by mail-ee0-f54.google.com with SMTP id e49so1093380eek.27
        for <netdev@vger.kernel.org>; Sun, 28 Apr 2013 00:46:39 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <517CC2A8.5010303@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Apr 28, 2013 at 09:33:12AM +0300, Amir Vadai wrote:
> On 25/04/2013 22:26, Richard Cochran wrote:
> > On Tue, Apr 23, 2013 at 07:06:49PM +0300, Amir Vadai wrote:
> > 
> >> +u64 mlx4_en_get_cqe_ts(struct mlx4_cqe *cqe)
> >> +{
> >> +	u64 hi, lo;
> >> +	struct mlx4_ts_cqe *ts_cqe = (struct mlx4_ts_cqe *)cqe;
> >> +
> >> +	lo = (u64)be16_to_cpu(ts_cqe->timestamp_lo);
> >> +	hi = ((u64)be32_to_cpu(ts_cqe->timestamp_hi) + !lo) << 16;
> >                                                      ^^^^^
> > That looks a bit strange. Can you explain?
> 
> We need to increment the high order 32bit by one when the low order
> 16bit value is zero, due to HW limitation.

So 'hi' increases by one, when 'lo' goes from 0x0000 to 0x0001?

Thanks,
Richard
