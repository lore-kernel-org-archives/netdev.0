From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH] SUNRPC: Mark buffer used for debug printks
	with	__maybe_unused
Date: Wed, 20 Feb 2008 08:36:38 -0800
Message-ID: <1203525398.7181.178.camel@localhost>
References: <47BC3303.2040101@openvz.org>
	 <1203521357.7181.163.camel@localhost> <1203521514.7181.167.camel@localhost>
	 <47BC48C6.3050208@trash.net>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Pavel Emelyanov <xemul@openvz.org>,
	"J. Bruce Fields" <bfields@citi.umich.edu>,
	Linux Netdev List <netdev@vger.kernel.org>
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from 136-022.dsl.labridge.com ([206.117.136.22]:1133 "EHLO
	mail.perches.com" rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org
	with ESMTP id S933846AbYBTQhJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 20 Feb 2008 11:37:09 -0500
In-Reply-To: <47BC48C6.3050208@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2008-02-20 at 16:35 +0100, Patrick McHardy wrote:
> Alternatively change the dprintk macro to behave similar like
> pr_debug() and mark things like svc_print_addr() __pure, which
> has the advantage that is still performs format checking even
> if debugging is disabled.

I think it's better to change the dprintk style macros
to what Philip Craig suggested.

http://marc.info/?l=linux-wireless&m=120338413108120&w=2

This makes clear to the compiler that the called function is not
going to be used so it can be optimized away, keeps any argument
verification in place, and doesn't require __pure attributes on
arbitrary functions that may be called during the dprintk

#ifdef DEBUG
#define some_print_wrapper(fmt, arg...) \
        do { if (0) printk(KERN_DEBUG fmt, ##arg); } while (0)
#else
#define some_print_wrapper(fmt, arg...) \
	printk(KERN_DEBUG fmt, ##arg)
#endif

