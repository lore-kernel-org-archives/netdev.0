From: Richard Cochran <richardcochran@gmail.com>
Subject: Re: [PATCH 1/2 net] ptp: fix error codes in ptp_clock_register()
Date: Mon, 10 Jul 2017 11:34:57 +0200
Message-ID: <20170710093457.xzc5i5zg34z3thjr@localhost.localdomain>
References: <20170710071137.ui2fhjkqzjqhkopz@mwanda>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Ganesh Goudar <ganeshgr@chelsio.com>,
        Atul Gupta <atul.gupta@chelsio.com>, netdev@vger.kernel.org,
        kernel-janitors@vger.kernel.org
To: Dan Carpenter <dan.carpenter@oracle.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wr0-f169.google.com ([209.85.128.169]:34658 "EHLO
        mail-wr0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752227AbdGJJfQ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 10 Jul 2017 05:35:16 -0400
Content-Disposition: inline
In-Reply-To: <20170710071137.ui2fhjkqzjqhkopz@mwanda>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Jul 10, 2017 at 10:11:37AM +0300, Dan Carpenter wrote:
> The ptp_clock_register() function returns NULL when it's #ifdefed out
> because CONFIG_PTP_1588_CLOCK is disabled.  Otherwise, it's intended to
> return error pointers.  Unfortunately, there are a couple paths where we
> forget to set the error code.  It means that we could result in NULL
> pointer dereferences in the callers.

Actually, this description is bogus.  Callers will not dereference
NULL, because they are required to check the returned pointer:

/**
 * ptp_clock_register() - register a PTP hardware clock driver
 *
 * @info:   Structure describing the new clock.
 * @parent: Pointer to the parent device of the new clock.
 *
 * Returns a valid pointer on success or PTR_ERR on failure.  If PHC
 * support is missing at the configuration level, this function
 * returns NULL, and drivers are expected to gracefully handle that
 * case separately.
 */

Thanks,
Richard
