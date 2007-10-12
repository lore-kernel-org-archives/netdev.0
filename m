From: Paul Mackerras <paulus@samba.org>
Subject: Re: net-2.6.24 breaks powerpc mysteriously
Date: Fri, 12 Oct 2007 14:09:51 +1000
Message-ID: <18190.62351.950590.493322@cargo.ozlabs.ibm.com>
References: <20071011192233.23e1c6bc.akpm@linux-foundation.org>
	<20071011.194543.75428024.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: akpm@linux-foundation.org, netdev@vger.kernel.org,
	sam@ravnborg.org, benh@kernel.crashing.org,
	vda.linux@googlemail.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ozlabs.org ([203.10.76.45]:54243 "EHLO ozlabs.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752339AbXJLEJ6 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 12 Oct 2007 00:09:58 -0400
In-Reply-To: <20071011.194543.75428024.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

David Miller writes:

> The only thing we touched in zlib is in the patch below.
> 
> I suspect the lib/zlib_inflate/inflate.c changes, I had no idea that
> some pieces of code try to use this into userspace.

Not userspace; the zImage wrapper uses inflate.c to gunzip the
compressed kernel image.  It is a separate program to the kernel,
however, and is compiled in an environment where the headers it uses
are not the kernel headers.

> I supposed a hacky fix is to add __KERNEL__ ifdef protection around
> zlib_inflate_blob() and those troublesome includes.  A nicer fix is

That would do, but I don't see why zlib_inflate_blob had to be added
to inflate.c rather than being in a new file under lib/zlib_inflate.
If nothing else, that bloats configs that currently use inflate.c (in
the kernel) but don't need zlib_inflate_blob() - which would be all
the existing uses. :)

Paul.
