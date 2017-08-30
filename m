From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [iproute PATCH] ss: Fix for added diag support check
Date: Wed, 30 Aug 2017 08:20:13 -0700
Message-ID: <20170830082013.4b188a26@xeon-e3>
References: <20170828173122.11458-1-phil@nwl.cc>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Phil Sutter <phil@nwl.cc>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f51.google.com ([74.125.83.51]:36789 "EHLO
        mail-pg0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751710AbdH3PUR (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 30 Aug 2017 11:20:17 -0400
Received: by mail-pg0-f51.google.com with SMTP id r133so20720631pgr.3
        for <netdev@vger.kernel.org>; Wed, 30 Aug 2017 08:20:17 -0700 (PDT)
In-Reply-To: <20170828173122.11458-1-phil@nwl.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 28 Aug 2017 19:31:22 +0200
Phil Sutter <phil@nwl.cc> wrote:

> Commit 9f66764e308e9 ("libnetlink: Add test for error code returned from
> netlink reply") changed rtnl_dump_filter_l() to return an error in case
> NLMSG_DONE would contain one, even if it was ENOENT.
> 
> This in turn breaks ss when it tries to dump DCCP sockets on a system
> without support for it: The function tcp_show(), which is shared between
> TCP and DCCP, will start parsing /proc since inet_show_netlink() returns
> an error - yet it parses /proc/net/tcp which doesn't make sense for DCCP
> sockets at all.
> 
> On my system, a call to 'ss' without further arguments prints the list
> of connected TCP sockets twice.
> 
> Fix this by introducing a dedicated function dccp_show() which does not
> have a fallback to /proc, just like sctp_show(). And since tcp_show()
> is no longer "multi-purpose", drop it's socktype parameter.
> 
> Fixes: 9f66764e308e9 ("libnetlink: Add test for error code returned from netlink reply")
> Signed-off-by: Phil Sutter <phil@nwl.cc>

Applied
