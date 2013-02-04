From: Tejun Heo <tj@kernel.org>
Subject: Re: [PATCH 09/62] atm/nicstar: convert to idr_alloc()
Date: Mon, 4 Feb 2013 09:06:24 -0800
Message-ID: <20130204170624.GJ27963@mtj.dyndns.org>
References: <1359854463-2538-1-git-send-email-tj@kernel.org>
 <1359854463-2538-10-git-send-email-tj@kernel.org>
 <20130204090410.2942f8cc@thirdoffive.cmf.nrl.navy.mil>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: akpm@linux-foundation.org, linux-kernel@vger.kernel.org,
	rusty@rustcorp.com.au, bfields@fieldses.org,
	skinsbursky@parallels.com, ebiederm@xmission.com,
	jmorris@namei.org, axboe@kernel.dk, netdev@vger.kernel.org
To: chas williams - CONTRACTOR <chas@cmf.nrl.navy.mil>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vb0-f54.google.com ([209.85.212.54]:59095 "EHLO
	mail-vb0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753734Ab3BDRGa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 4 Feb 2013 12:06:30 -0500
Content-Disposition: inline
In-Reply-To: <20130204090410.2942f8cc@thirdoffive.cmf.nrl.navy.mil>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello, Chas.

On Mon, Feb 04, 2013 at 09:04:10AM -0500, chas williams - CONTRACTOR wrote:
> I don't quite understand your comment.  idr_pre_get() returns 0 in the
> case of failure.

So, if you do the following,

	int id1 = 0, id2 = 0;

	if (!id1)
		err = idr_get_new_above(&card->idr, handle1, 0, &id1);
	if (!id2 && err == 0)
		err = idr_get_new_above(&card->idr, handle2, 0, &id2);
	if (err)
		goto out;
									    
You have no way of telling whether id1/2 are allocated or not.  0 is
the special "not allocated" value but it also is a valid ID.  The
error path should be freeing id1/2 if either of them has been
allocated but it doesn't and can't with 0 as the non-allocated value.

Thanks.

-- 
tejun
