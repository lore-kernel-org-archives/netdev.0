From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] af_key: suppress a warning for 64k pages.
Date: Tue, 30 Oct 2007 21:42:19 -0700 (PDT)
Message-ID: <20071030.214219.256397507.davem@davemloft.net>
References: <20071031145954.fe106f73.sfr@canb.auug.org.au>
	<20071030.210846.215166155.davem@davemloft.net>
	<20071031153422.44f864e8.sfr@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: sfr@canb.auug.org.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:60349
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1753057AbXJaEmU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 31 Oct 2007 00:42:20 -0400
In-Reply-To: <20071031153422.44f864e8.sfr@canb.auug.org.au>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Stephen Rothwell <sfr@canb.auug.org.au>
Date: Wed, 31 Oct 2007 15:34:22 +1100

> On Tue, 30 Oct 2007 21:08:46 -0700 (PDT) David Miller <davem@davemloft.net> wrote:
> > I think we should retain the check, but modify it so that GCC knows we
> > understand that it's OK if it is always false.  Perhaps a simple (u32)
> > cast on the left branch of the comparison is sufficient?
> 
> Unfortunately, that does not suppress the warning (gcc is getting too
> smart :-().

It seems if you break the comparison out into a function which
takes a u32, that's enough to get rid of the warning.

I can't figure out a way to make this prettier, can you?

#define PAGE_SIZE	(64 * 1024)

typedef unsigned int u32;
typedef unsigned short u16;

int compare(u32 val)
{
	if (val >= PAGE_SIZE)
		return -1;
	return 0;
}

int foo(u16 val)
{
#if 1
	return compare(val);
#else
	if (val >= PAGE_SIZE)
		return -1;
	return 0;
#endif
}
