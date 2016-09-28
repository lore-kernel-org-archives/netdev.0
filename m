From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] ipv6 addrconf: enable use of proc_dointvec_minmax in
 addrconf_sysctl
Date: Wed, 28 Sep 2016 07:52:04 -0400 (EDT)
Message-ID: <20160928.075204.140017839812712683.davem@davemloft.net>
References: <1474978605-28116-1-git-send-email-zenczykowski@gmail.com>
        <20160928.074901.901607987499248966.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-2
Content-Transfer-Encoding: 8BIT
Cc: maze@google.com, netdev@vger.kernel.org, ek@google.com,
        lorenzo@google.com, hannes@stressinduktion.org
To: zenczykowski@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:33466 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752469AbcI1LwM (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 28 Sep 2016 07:52:12 -0400
In-Reply-To: <20160928.074901.901607987499248966.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David Miller <davem@davemloft.net>
Date: Wed, 28 Sep 2016 07:49:01 -0400 (EDT)

> From: Maciej ¯enczykowski <zenczykowski@gmail.com>
> Date: Tue, 27 Sep 2016 05:16:45 -0700
> 
>> From: Maciej ¯enczykowski <maze@google.com>
>> 
>> Signed-off-by: Maciej ¯enczykowski <maze@google.com>
> 
> I was about to ask you to submit this patch alongside an actual
> addition of a proc_dointvec_minmax user to the table.
> 
> But upon second checking there is one, indirectly via
> addrconf_sysctl_mtu().

And actually these cases use a dummy sysctl blob on the stack to
provide the min/max values to proc_dointvec_minmax.  And they do
it _EXACTLY_ because the extra pointers are for the netns pointer
and a pointer to the idev.

And any user envisioned can do the same thing, use a trampoline
like the existing cases do.
