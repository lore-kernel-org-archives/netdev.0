From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH 2/7] CAN: Add PF_CAN core module
Date: Fri, 21 Sep 2007 09:58:48 -0700
Message-ID: <1190393928.32660.22.camel@localhost>
References: <20070920184323.3795.0@janus.isnogud.escape.de>
	 <20070920184532.3795.2@janus.isnogud.escape.de>
	 <1190318781.26101.148.camel@localhost>
	 <ygf8x705mrq.fsf@janus.isnogud.escape.de>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, David Miller <davem@davemloft.net>,
	Patrick McHardy <kaber@trash.net>,
	Thomas Gleixner <tglx@linutronix.de>,
	Oliver Hartkopp <oliver@hartkopp.net>,
	Oliver Hartkopp <oliver.hartkopp@volkswagen.de>
To: Urs Thuermann <urs@isnogud.escape.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from DSL022.labridge.com ([206.117.136.22]:3816 "EHLO perches.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752344AbXIUQ65 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 21 Sep 2007 12:58:57 -0400
In-Reply-To: <ygf8x705mrq.fsf@janus.isnogud.escape.de>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 2007-09-21 at 12:35 +0200, Urs Thuermann wrote:
> I didn't find a way with gcc-2.95 to make the format
> string a separate macro argument (which I also wanted).

The old 2.x GCC workaround was to use
	#define DBG(fmt, arg) printk(fmt , ## arg)
adding a space before the last comma.

> I use "do { ... } while(0)" only for statements, not for expressions.
> But I could have used the && instead of ?: operator.  I don't think
> the "do { ... } while(0)" looks nicer or has any other advantage.

It's more linux convention.
It allows the macro to be used in if-else constructs.

> > > void can_debug_cframe(const char *msg, struct can_frame *cf, ...)
> > This prototype looks backwards to me.
> You mean the order or `msg' and `cf'?

Yes, I believe the can_frame* should be the first argument.

> Ah, I didn't know print_hex_dump().  That looks nicer.  But as Thomas
> mentioned, we shouldn't convert these functions into macros.

The first print_hex_dump should actually be print_hex_dump_bytes.

I was typing what I hoped was a readable example.
I hope you do convert to functions, but not to inline functions.

cheers, Joe

