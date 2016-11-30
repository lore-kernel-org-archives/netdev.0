From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net][v2] bpf: fix states equal logic for varlen access
Date: Wed, 30 Nov 2016 14:51:25 -0500 (EST)
Message-ID: <20161130.145125.1593093027365850160.davem@davemloft.net>
References: <1480440429-2531-1-git-send-email-jbacik@fb.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, ast@kernel.org, jannh@google.com,
        daniel@iogearbox.net, kernel-team@fb.com
To: jbacik@fb.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:40980 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754371AbcK3Tv1 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 30 Nov 2016 14:51:27 -0500
In-Reply-To: <1480440429-2531-1-git-send-email-jbacik@fb.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Josef Bacik <jbacik@fb.com>
Date: Tue, 29 Nov 2016 12:27:09 -0500

> If we have a branch that looks something like this
> 
> int foo = map->value;
> if (condition) {
>   foo += blah;
> } else {
>   foo = bar;
> }
> map->array[foo] = baz;
> 
> We will incorrectly assume that the !condition branch is equal to the condition
> branch as the register for foo will be UNKNOWN_VALUE in both cases.  We need to
> adjust this logic to only do this if we didn't do a varlen access after we
> processed the !condition branch, otherwise we have different ranges and need to
> check the other branch as well.
> 
> Fixes: 484611357c19 ("bpf: allow access into map value arrays")
> Reported-by: Jann Horn <jannh@google.com>
> Signed-off-by: Josef Bacik <jbacik@fb.com>
> ---
> v1->v2:
> - renamed and moved varlen_map_access variable.
> - dropped the extra () in the second if statement.
> - added the Fixes and Reported-by tag.

Applied, thanks.
