From: Denys Vlasenko <vda.linux@googlemail.com>
Subject: Re: net-2.6.24 breaks powerpc mysteriously
Date: Sun, 14 Oct 2007 04:43:46 +0100
Message-ID: <200710140443.46788.vda.linux@googlemail.com>
References: <20071011192233.23e1c6bc.akpm@linux-foundation.org> <20071011.194543.75428024.davem@davemloft.net> <18190.62351.950590.493322@cargo.ozlabs.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, akpm@linux-foundation.org,
	netdev@vger.kernel.org, sam@ravnborg.org, benh@kernel.crashing.org
To: Paul Mackerras <paulus@samba.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ug-out-1314.google.com ([66.249.92.171]:58122 "EHLO
	ug-out-1314.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754740AbXJNDnz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 13 Oct 2007 23:43:55 -0400
Received: by ug-out-1314.google.com with SMTP id z38so751653ugc
        for <netdev@vger.kernel.org>; Sat, 13 Oct 2007 20:43:54 -0700 (PDT)
In-Reply-To: <18190.62351.950590.493322@cargo.ozlabs.ibm.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Friday 12 October 2007 05:09, Paul Mackerras wrote:
> > I supposed a hacky fix is to add __KERNEL__ ifdef protection around
> > zlib_inflate_blob() and those troublesome includes.  A nicer fix is
> 
> That would do, but I don't see why zlib_inflate_blob had to be added
> to inflate.c rather than being in a new file under lib/zlib_inflate.

Done.

> If nothing else, that bloats configs that currently use inflate.c (in
> the kernel) but don't need zlib_inflate_blob() - which would be all
> the existing uses. :)

I did it.

However, in general I prefer to have a better linker, one which
is capable of eliminate unused fuctions/data on the per-object basis,
not per .o file.

Patches to implement that are sent to Sam Ravnborg.
Hopefully they will make it to mainline.
--
vda
