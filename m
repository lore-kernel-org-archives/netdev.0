From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [PATCH] rtnetlink: Mask the rta_type when range checking
Date: Fri, 15 Mar 2013 08:51:24 +0000
Message-ID: <20130315085124.GA17498@casper.infradead.org>
References: <1363184338-15781-1-git-send-email-vyasevic@redhat.com>
 <20130313083654.01d9c924@nehalam.linuxnetplumber.net>
 <51420B75.9060209@redhat.com>
 <20130314212821.GC25591@casper.infradead.org>
 <51426BB6.5030204@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Stephen Hemminger <stephen@networkplumber.org>,
	netdev@vger.kernel.org, davem@davemloft.net
To: Vlad Yasevich <vyasevic@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from casper.infradead.org ([85.118.1.10]:46080 "EHLO
	casper.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753936Ab3COIv2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 15 Mar 2013 04:51:28 -0400
Content-Disposition: inline
In-Reply-To: <51426BB6.5030204@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 03/14/13 at 08:30pm, Vlad Yasevich wrote:
> Doing a quick check on all the callers for rtnl_register and their
> handlers the following do not use nla_parse:
>  1) dn_fib_rtm_newroute/delroute  - Don't seem to care about attribute
>                                     types.
>  2) dn_cache_getroute() - suspect use.  relies on rta_buf populated by
>                           rtnetlink_rcv_msg
> 
>  3) inet_rtm_newroute/delroute - rtm_to_fib_config() uses a custom loop
>                                   with nla_type(), so safe.
> 
> That's all that a quick look finds.  Out of all of them, looks like
> on dn_cache_getroute() would be broken.

So checking values in rta_max[] which lists the maximum attribute
allowed for each message family range, all are limited to low
values so the NLA_F_NESTED bit is guaranteed to have been unused
up to now.

The risk that remains is that we would start accepting an attribute
which we previously didn't but we have that risk with every new
attribute that is added.

Acked-by: Thomas Graf <tgraf@suug.ch>
