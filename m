From: Xi Wang <xi.wang@gmail.com>
Subject: Re: [PATCH v2] rps: fix insufficient bounds checking in store_rps_dev_flow_table_cnt()
Date: Fri, 23 Dec 2011 09:30:29 -0500
Message-ID: <EC59D18E-82F6-4409-BB29-D7434D63B0C9@gmail.com>
References: <1324493459-19764-1-git-send-email-xi.wang@gmail.com> <4EF3BEBA.4040402@gmail.com> <1324613414.2674.2.camel@edumazet-laptop> <C0DC969A-A32B-4CC8-B565-FF741E9D75DA@gmail.com> <1324616007.2674.8.camel@edumazet-laptop> <ACB00AE8-CFEF-4535-9242-1B5C44F05C13@gmail.com> <1324617390.2674.13.camel@edumazet-laptop> <1324618555.10854.4.camel@edumazet-laptop> <4DA4756B-0654-49F4-B135-9A9F89BC7D21@gmail.com> <1324645592.2223.9.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
Mime-Version: 1.0 (Apple Message framework v1084)
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: Tom Herbert <therbert@google.com>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-iy0-f174.google.com ([209.85.210.174]:52951 "EHLO
	mail-iy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751913Ab1LWOae (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 23 Dec 2011 09:30:34 -0500
Received: by iaeh11 with SMTP id h11so15181062iae.19
        for <netdev@vger.kernel.org>; Fri, 23 Dec 2011 06:30:34 -0800 (PST)
In-Reply-To: <1324645592.2223.9.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Dec 23, 2011, at 8:06 AM, Eric Dumazet wrote:

> I'll submit following patch for net-next, once your patch is in this
> tree.

Thanks for doing this. ;-)

> 		count = roundup_pow_of_two(count);
> +		if (!count ||
> +		    count != (unsigned long)(u32)count)
> +			return -EINVAL;
> 		if (count > (ULONG_MAX - sizeof(struct rps_dev_flow_table))
> 				/ sizeof(struct rps_dev_flow)) {
> 			/* Enforce a limit to prevent overflow */

I would rather avoid undefined behavior in C.

Given count = ULONG_MAX on 64-bit systems, roundup_pow_of_two()
would overflow, and the overflowed result is undefined, e.g.,
on x86-64 it gives 1, not 0.  That's why I used INT_MAX.

BTW, (count > UINT_MAX) is shorter and more easier to understand
than (count != (unsigned long)(u32)count).

- xi
