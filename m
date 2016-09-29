From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v5] bpf: allow access into map value arrays
Date: Thu, 29 Sep 2016 01:36:08 -0400 (EDT)
Message-ID: <20160929.013608.760373071668971559.davem@davemloft.net>
References: <1475074472-23538-1-git-send-email-jbacik@fb.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: daniel@iogearbox.net, tgraf@suug.ch, netdev@vger.kernel.org,
        kernel-team@fb.com, u9012063@gmail.com
To: jbacik@fb.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:45410 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753520AbcI2FgP (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 29 Sep 2016 01:36:15 -0400
In-Reply-To: <1475074472-23538-1-git-send-email-jbacik@fb.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Josef Bacik <jbacik@fb.com>
Date: Wed, 28 Sep 2016 10:54:32 -0400

> Suppose you have a map array value that is something like this
> 
> struct foo {
> 	unsigned iter;
> 	int array[SOME_CONSTANT];
> };
> 
> You can easily insert this into an array, but you cannot modify the contents of
> foo->array[] after the fact.  This is because we have no way to verify we won't
> go off the end of the array at verification time.  This patch provides a start
> for this work.  We accomplish this by keeping track of a minimum and maximum
> value a register could be while we're checking the code.  Then at the time we
> try to do an access into a MAP_VALUE we verify that the maximum offset into that
> region is a valid access into that memory region.  So in practice, code such as
> this
> 
> unsigned index = 0;
> 
> if (foo->iter >= SOME_CONSTANT)
> 	foo->iter = index;
> else
> 	index = foo->iter++;
> foo->array[index] = bar;
> 
> would be allowed, as we can verify that index will always be between 0 and
> SOME_CONSTANT-1.  If you wish to use signed values you'll have to have an extra
> check to make sure the index isn't less than 0, or do something like index %=
> SOME_CONSTANT.
> 
> Signed-off-by: Josef Bacik <jbacik@fb.com>
> Acked-by: Alexei Starovoitov <ast@kernel.org>

Applied, thanks.
