From: Amir Vadai <amirv@mellanox.com>
Subject: Re: [PATCH net-next V3 3/5] net/mlx4_en: Add HW timestamping (TS)
 support
Date: Sun, 28 Apr 2013 09:33:12 +0300
Message-ID: <517CC2A8.5010303@mellanox.com>
References: <1366733211-10228-1-git-send-email-amirv@mellanox.com> <1366733211-10228-4-git-send-email-amirv@mellanox.com> <20130425192627.GA14429@netboy>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>, <netdev@vger.kernel.org>,
	Or Gerlitz <ogerlitz@mellanox.com>,
	Eugenia Emantayev <eugenia@mellanox.com>
To: Richard Cochran <richardcochran@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from eu1sys200aog108.obsmtp.com ([207.126.144.125]:35878 "EHLO
	eu1sys200aog108.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751058Ab3D1GdS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 28 Apr 2013 02:33:18 -0400
In-Reply-To: <20130425192627.GA14429@netboy>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 25/04/2013 22:26, Richard Cochran wrote:
> On Tue, Apr 23, 2013 at 07:06:49PM +0300, Amir Vadai wrote:
> 
>> +u64 mlx4_en_get_cqe_ts(struct mlx4_cqe *cqe)
>> +{
>> +	u64 hi, lo;
>> +	struct mlx4_ts_cqe *ts_cqe = (struct mlx4_ts_cqe *)cqe;
>> +
>> +	lo = (u64)be16_to_cpu(ts_cqe->timestamp_lo);
>> +	hi = ((u64)be32_to_cpu(ts_cqe->timestamp_hi) + !lo) << 16;
>                                                      ^^^^^
> That looks a bit strange. Can you explain?

We need to increment the high order 32bit by one when the low order
16bit value is zero, due to HW limitation.

> 
>> +
>> +	return hi | lo;
>> +}
> 
> Thanks,
> Richard
> 

Amir.
