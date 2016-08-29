From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 0/3] strp: Generalize stream parser to work
 with other socket types
Date: Sun, 28 Aug 2016 23:34:50 -0400 (EDT)
Message-ID: <20160828.233450.783176953748442286.davem@davemloft.net>
References: <1472420599-510735-1-git-send-email-tom@herbertland.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, kernel-team@fb.com, davejwatson@fb.com
To: tom@herbertland.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:49010 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1755314AbcH2Dew (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 28 Aug 2016 23:34:52 -0400
In-Reply-To: <1472420599-510735-1-git-send-email-tom@herbertland.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Tom Herbert <tom@herbertland.com>
Date: Sun, 28 Aug 2016 14:43:16 -0700

> Add a read_sock protocol operation function that allows something like
> tcp_read_sock to be called for other protocol types.
> 
> Specific changes in this patch set:
>   - Add read_sock function to proto_ops. This has the same signature as
>     tcp_read_sock. sk_read_actor_t is also defined in net.h.
>   - Set peek_len and read_sock proto_op functions for TCPv4 and TCPv6
>     stream ops.
>   - Remove references to tcp in strparser.
>   - Call peek_len and read_sock operations from strparser instead of
>     calling TCP specific functions.

I'll apply this, but I want you to shore up these new ops.

A check has to happen somewhere to make sure the proto_ops in
question have a non-NULL read_sock and peek_len method before
starting to use it.
