From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [PATCH v2] netlink: align attributes on 64-bits
Date: Tue, 18 Dec 2012 17:11:03 +0000
Message-ID: <20121218171103.GI27746@casper.infradead.org>
References: <1355500160.2626.9.camel@bwh-desktop.uk.solarflarecom.com>
 <1355762980-4285-1-git-send-email-nicolas.dichtel@6wind.com>
 <20121218125735.GG27746@casper.infradead.org>
 <50D09897.8030508@6wind.com>
 <AE90C24D6B3A694183C094C60CF0A2F6026B70F5@saturn3.aculab.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: nicolas.dichtel@6wind.com, bhutchings@solarflare.com,
	netdev@vger.kernel.org, davem@davemloft.net
To: David Laight <David.Laight@ACULAB.COM>
Return-path: <netdev-owner@vger.kernel.org>
Received: from casper.infradead.org ([85.118.1.10]:60192 "EHLO
	casper.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754203Ab2LRRLF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 18 Dec 2012 12:11:05 -0500
Content-Disposition: inline
In-Reply-To: <AE90C24D6B3A694183C094C60CF0A2F6026B70F5@saturn3.aculab.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 12/18/12 at 04:50pm, David Laight wrote:
> > 2/ Suppose that the attribute is:
> > 
> >    struct foo {
> >    	__u64 bar1;
> >    	__u32 bar2;
> >    }
> >    => sizeof(struct foo) = 12 (= payload)
> 
> That is only true if the host architecture aligns 64bit items
> on 32 it boundaries (as i386 does).
> Otherwise there are 4 bytes of padding at the end and the
> size is 16.
> 
> Actually it is worse than that.
> Consider the structure:
> 	struct bar {
> 		__u32 foo1;
> 		__u64 foo2;
> 	}
> On i386 it will have size 12 and foo2 will be at offset 4.
> On sparc32 (and most 64bit) it will have size 16 with foo2
> at offset 8 (and 4 bytes of pad after foo1).

This is a known problem and I can't think of anything
that can be done about it except for memcpy()ing the
data before accessing it.

If you have ideas, I'm more that willing to listen :)

> Do these messages move between systems?
> If they do then any 64bit items need an explicit alignment
> eg tag with __attribute__((aligned(8))) (or aligned(4)).

They don't. Netlink has and will be host bound. It also
uses host byte order for that reason.
