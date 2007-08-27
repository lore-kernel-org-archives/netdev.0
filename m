From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH net-2.6.24] introduce MAC_FMT/MAC_ARG
Date: Mon, 27 Aug 2007 08:44:17 -0700
Message-ID: <1188229458.18004.65.camel@localhost>
References: <1187808408.4314.15.camel@johannes.berg>
	 <1188086976.18004.5.camel@localhost>
	 <1188212049.6756.18.camel@johannes.berg>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
To: Johannes Berg <johannes@sipsolutions.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from DSL022.labridge.com ([206.117.136.22]:2764 "EHLO perches.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752700AbXH0Ppt (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 27 Aug 2007 11:45:49 -0400
In-Reply-To: <1188212049.6756.18.camel@johannes.berg>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 2007-08-27 at 12:54 +0200, Johannes Berg wrote:
> Thanks for this patch though, I'd have done it otherwise.

I had it, it was just a s/EUI48/MAC/ and copy/paste thing.

There are also the arch, drivers/[^net], and net directories
that have a few of these.

The patch also added the missing ")" in drivers/net/82596.c

> I was rereading your original conversion and noticed that it is now
> trivial to make the kernel smaller like you originally wanted by doing
> something like this
> 
> -- define this function somewhere --
> print_mac(u8 *mac, char *buf)
> {
> 	sprintf(buf, "%02x:...", mac[0], mac[1], ...);
> }
> EXPORT_SYMBOL(print_mac)
> 
> -- change macros to --
> #define MAC_FMT "%s"
> #define MAC_ARG(a) ({char __buf[18]; print_mac(a, buf); __buf})
> 
> I'm not sure we'd want that, but at the time you said it made the kernel
> significantly smaller and I doubt there's a performance problem with it
> (who prints mac addresses regularly?)

The reduction is ~.1% in an allyesconfig.
The compound statement to hide the automatic works well.
The function call is noise compared to the printk.

cheers, Joe

