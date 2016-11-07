From: Jason Baron <jbaron@akamai.com>
Subject: Re: [net PATCH] fib_trie: Correct /proc/net/route off by one error
Date: Mon, 7 Nov 2016 11:03:51 -0500
Message-ID: <aad592f0-e815-55a0-0da3-1fd52ce3322c@akamai.com>
References: <20161104191157.13974.70665.stgit@ahduyck-blue-test.jf.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Andy Whitcroft <apw@canonical.com>, <davem@davemloft.net>
To: Alexander Duyck <alexander.h.duyck@intel.com>,
        <netdev@vger.kernel.org>, <alexander.duyck@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from prod-mail-xrelay05.akamai.com ([23.79.238.179]:11828 "EHLO
        prod-mail-xrelay05.akamai.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S932380AbcKGQDx (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 7 Nov 2016 11:03:53 -0500
In-Reply-To: <20161104191157.13974.70665.stgit@ahduyck-blue-test.jf.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



On 11/04/2016 03:11 PM, Alexander Duyck wrote:
> The display of /proc/net/route has had a couple issues due to the fact that
> when I originally rewrote most of fib_trie I made it so that the iterator
> was tracking the next value to use instead of the current.
>
> In addition it had an off by 1 error where I was tracking the first piece
> of data as position 0, even though in reality that belonged to the
> SEQ_START_TOKEN.
>
> This patch updates the code so the iterator tracks the last reported
> position and key instead of the next expected position and key.  In
> addition it shifts things so that all of the leaves start at 1 instead of
> trying to report leaves starting with offset 0 as being valid.  With these
> two issues addressed this should resolve any off by one errors that were
> present in the display of /proc/net/route.
>
> Fixes: 25b97c016b26 ("ipv4: off-by-one in continuation handling in /proc/net/route")
> Cc: Andy Whitcroft <apw@canonical.com>
> Reported-by: Jason Baron <jbaron@akamai.com>
> Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
> ---
>  net/ipv4/fib_trie.c |   21 +++++++++------------
>  1 file changed, 9 insertions(+), 12 deletions(-)
>

Ok. Works for me.

Feel free to add:
Reviewed-and-Tested-by: Jason Baron <jbaron@akamai.com>

Thanks,

-Jason
