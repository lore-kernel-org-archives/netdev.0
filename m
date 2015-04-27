From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: iproute2: Make linux/in6.h a stub?
Date: Mon, 27 Apr 2015 09:17:04 -0700
Message-ID: <20150427091704.125f42cb@urahara>
References: <20150425205410.GB9433@euler>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Felix Janda <felix.janda@posteo.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f173.google.com ([209.85.192.173]:35373 "EHLO
	mail-pd0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752972AbbD0QQ7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 27 Apr 2015 12:16:59 -0400
Received: by pdbqd1 with SMTP id qd1so133380001pdb.2
        for <netdev@vger.kernel.org>; Mon, 27 Apr 2015 09:16:59 -0700 (PDT)
In-Reply-To: <20150425205410.GB9433@euler>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, 25 Apr 2015 22:54:11 +0200
Felix Janda <felix.janda@posteo.de> wrote:

> Hello.
> 
> Background:
> Current iproute2 does not build when the libc is musl instead of glibc.
> This is because of redefinition of in6_addr in netinet/in.h and
> linux/in6.h. There are workarounds in linux/libc-compat.h to make it
> somehow work for glibc.
> 
> 
> As I can see linux/in6.h is only indirectly used via the other kernel
> headers linux/if_bridge.h and linux/xfrm.h. These in turn include
> linux/in6.h only in order to get a declaration of in6_addr.
> 
> Since iproute2 depends on the fact that in6_addr is defined in
> <netinet/in.h> it should be safe to replace the content of linux/in6.h
> by
> 
> #include <netinet/in.h>
> 
> This completely removes the possibility for redefinition of in6_addr
> for any libc. Since linux/in6.h is anyway a patched kernel header, such
> a change should also not increase the work needed to sync with newer
> kernel headers.
> 
> Would it be possible to implement such a change?
> 
> Felix

I appreciate the effort to make iproute2 in other environments.
The header files in linux for iproute2 are automatically generated
from the upstream kernel headers. A lot of effort has been done
to align kernel, iproute2 and glibc. Therefore doing something
special just to work around incompatibles with other
environments is not going to be accepted.

Any other libc has to be compatible with glibc in this area
rather than introducing more complexity in what is already fragile.
