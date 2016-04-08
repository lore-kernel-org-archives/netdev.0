From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v4 1/2] RDS: memory allocated must be align to 8
Date: Fri, 08 Apr 2016 16:10:55 -0400 (EDT)
Message-ID: <20160408.161055.212162741537870508.davem@davemloft.net>
References: <1460030256-16791-1-git-send-email-shamir.rabinovitch@oracle.com>
	<57080A27.8050509@oracle.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: shamir.rabinovitch@oracle.com, rds-devel@oss.oracle.com,
	netdev@vger.kernel.org
To: santosh.shilimkar@oracle.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:36558 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932169AbcDHUK5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 8 Apr 2016 16:10:57 -0400
In-Reply-To: <57080A27.8050509@oracle.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: santosh shilimkar <santosh.shilimkar@oracle.com>
Date: Fri, 8 Apr 2016 12:44:39 -0700

> On 4/7/2016 4:57 AM, Shamir Rabinovitch wrote:
>> Fix issue in 'rds_ib_cong_recv' when accessing unaligned memory
>> allocated by 'rds_page_remainder_alloc' using uint64_t pointer.
>>
> Sorry I still didn't follow this change still. What exactly is the
> problem.

You can't stop the offset at non-8byte intervals, because the chunks
being used in these arenas can have 64-bit values in it, which must be
8-byte aligned.

It looks extremely obvious to me.
