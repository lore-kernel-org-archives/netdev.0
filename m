From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] ila: Fix crash caused by rhashtable changes
Date: Wed, 02 Nov 2016 15:27:11 -0400 (EDT)
Message-ID: <20161102.152711.1206261970590164814.davem@davemloft.net>
References: <20161101215525.360859-1-tom@herbertland.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, kernel-team@fb.com
To: tom@herbertland.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:45590 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1756931AbcKBT1N (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 2 Nov 2016 15:27:13 -0400
In-Reply-To: <20161101215525.360859-1-tom@herbertland.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Tom Herbert <tom@herbertland.com>
Date: Tue, 1 Nov 2016 14:55:25 -0700

> commit ca26893f05e86 ("rhashtable: Add rhlist interface")
> added a field to rhashtable_iter so that length became 56 bytes
> and would exceed the size of args in netlink_callback (which is
> 48 bytes). The netlink diag dump function already has been
> allocating a iter structure and storing the pointed to that
> in the args of netlink_callback. ila_xlat also uses
> rhahstable_iter but is still putting that directly in
> the arg block. Now since rhashtable_iter size is increased
> we are overwriting beyond the structure. The next field
> happens to be cb_mutex pointer in netlink_sock and hence the crash.
> 
> Fix is to alloc the rhashtable_iter and save it as pointer
> in arg.
> 
> Tested:
> 
>   modprobe ila
>   ./ip ila add loc 3333:0:0:0 loc_match 2222:0:0:1,
>   ./ip ila list  # NO crash now
> 
> Signed-off-by: Tom Herbert <tom@herbertland.com>

Applied.
