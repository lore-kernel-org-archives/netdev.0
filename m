From: "David Laight" <David.Laight@ACULAB.COM>
Subject: RE: [PATCH v2] netlink: align attributes on 64-bits
Date: Tue, 18 Dec 2012 16:50:52 -0000
Message-ID: <AE90C24D6B3A694183C094C60CF0A2F6026B70F5@saturn3.aculab.com>
References: <1355500160.2626.9.camel@bwh-desktop.uk.solarflarecom.com> <1355762980-4285-1-git-send-email-nicolas.dichtel@6wind.com> <20121218125735.GG27746@casper.infradead.org> <50D09897.8030508@6wind.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="Windows-1252"
Content-Transfer-Encoding: 8BIT
Cc: <bhutchings@solarflare.com>, <netdev@vger.kernel.org>,
	<davem@davemloft.net>
To: <nicolas.dichtel@6wind.com>, "Thomas Graf" <tgraf@suug.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0.aculab.com ([213.249.233.131]:43517 "HELO mx0.aculab.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with SMTP
	id S1754811Ab2LRQ64 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 18 Dec 2012 11:58:56 -0500
Received: from mx0.aculab.com ([127.0.0.1])
 by localhost (mx0.aculab.com [127.0.0.1]) (amavisd-new, port 10024) with SMTP
 id 26159-05 for <netdev@vger.kernel.org>;
 Tue, 18 Dec 2012 16:58:49 +0000 (GMT)
Content-class: urn:content-classes:message
In-Reply-To: <50D09897.8030508@6wind.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> 2/ Suppose that the attribute is:
> 
>    struct foo {
>    	__u64 bar1;
>    	__u32 bar2;
>    }
>    => sizeof(struct foo) = 12 (= payload)

That is only true if the host architecture aligns 64bit items
on 32 it boundaries (as i386 does).
Otherwise there are 4 bytes of padding at the end and the
size is 16.

Actually it is worse than that.
Consider the structure:
	struct bar {
		__u32 foo1;
		__u64 foo2;
	}
On i386 it will have size 12 and foo2 will be at offset 4.
On sparc32 (and most 64bit) it will have size 16 with foo2
at offset 8 (and 4 bytes of pad after foo1).

Do these messages move between systems?
If they do then any 64bit items need an explicit alignment
eg tag with __attribute__((aligned(8))) (or aligned(4)).

	David
