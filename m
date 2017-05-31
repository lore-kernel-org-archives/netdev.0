From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH] netlink: Change rtnl_dump_done to always show error
Date: Tue, 30 May 2017 17:35:08 -0700
Message-ID: <20170530173508.0b895904@xeon-e3>
References: <20170516212246.10134-1-dsahern@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: David Ahern <dsahern@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f182.google.com ([209.85.192.182]:33365 "EHLO
        mail-pf0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750938AbdEaAfM (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 30 May 2017 20:35:12 -0400
Received: by mail-pf0-f182.google.com with SMTP id e193so1850046pfh.0
        for <netdev@vger.kernel.org>; Tue, 30 May 2017 17:35:12 -0700 (PDT)
In-Reply-To: <20170516212246.10134-1-dsahern@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 16 May 2017 14:22:46 -0700
David Ahern <dsahern@gmail.com> wrote:

> The original code which became rtnl_dump_done only shows netlink errors
> if the protocol is NETLINK_SOCK_DIAG, but netlink dumps always appends
> the length which contains any error encountered during the dump. Update
> rtnl_dump_done to always show the error if there is one.
> 
> As an *example* without this patch, dumping a route object that exceeds
> the internal buffer size terminates with no message to the user -- the
> dump just ends because the NLMSG_DONE attribute was received. With this
> patch the user at least gets a message that the dump was aborted.
> 
> $ ip ro ls
> default via 10.0.2.2 dev eth0
> 10.0.2.0/24 dev eth0 proto kernel scope link src 10.0.2.15
> 10.10.0.0/16 dev veth1 proto kernel scope link src 10.10.0.1
> 172.16.1.0/24 dev br0.11 proto kernel scope link src 172.16.1.1
> Error: Buffer too small for object
> Dump terminated
> 
> The point of this patch is to notify the user of a failure versus
> silently exiting on a partial dump. Because the NLMSG_DONE attribute
> was received, the entire dump needs to be restarted to use a larger
> buffer for EMSGSIZE errors. That could be done automatically but it
> has other user impacts (e.g., duplicate output if the dump is
> restarted) and should be the subject of a different patch.
> 
> Signed-off-by: David Ahern <dsahern@gmail.com>

Applied.

It is easier to seen iproute2 patches with:

Subject: [PATCH iproute2] netlink: Change rtnl_dump_done to always show error
