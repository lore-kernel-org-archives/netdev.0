From: "David Laight" <David.Laight@ACULAB.COM>
Subject: RE: [PATCH v2] [iproute] ipxfrm: use alloca to allocate stack space
Date: Fri, 18 Jan 2013 10:00:53 -0000
Message-ID: <AE90C24D6B3A694183C094C60CF0A2F6026B7115@saturn3.aculab.com>
References: <1358476746-10810-1-git-send-email-vapier@gentoo.org> <1358481650-20816-1-git-send-email-vapier@gentoo.org>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="Windows-1252"
Content-Transfer-Encoding: 8BIT
To: "Mike Frysinger" <vapier@gentoo.org>,
	<stephen.hemminger@vyatta.com>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0.aculab.com ([213.249.233.131]:42556 "HELO mx0.aculab.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with SMTP
	id S1751300Ab3ARKC5 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 18 Jan 2013 05:02:57 -0500
Received: from mx0.aculab.com ([127.0.0.1])
 by localhost (mx0.aculab.com [127.0.0.1]) (amavisd-new, port 10024) with SMTP
 id 11231-04 for <netdev@vger.kernel.org>;
 Fri, 18 Jan 2013 10:02:54 +0000 (GMT)
Content-class: urn:content-classes:message
In-Reply-To: <1358481650-20816-1-git-send-email-vapier@gentoo.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> Clang doesn't support the gcc extension for embeddeding flexible arrays
> inside of structures.  Use the slightly more portable alloca().
> 
> Signed-off-by: Mike Frysinger <vapier@gentoo.org>
> ---
> v2
> 	- use alloca rather than flexible arrays in structures
...
> +#include <alloca.h>

I'm not sure what happens in Linux, but alloca.h is likely
to try to use the libc version of alloca().
While that worked 20 years ago, these days compilers then
to use %sp relative addressing so you must only use the
compiler builtin alloca() code.

With gcc, compiling with -std=c89 (I think that is the one)
causes the builtin alloca() not to be defined.
By default alloca() is part of the language and the header
isn't needed.

Use of alloca() also stops some of the stack overwrite
protection being enabled.

In this case I suspect malloc() and free() is best.
(Or change the called function ...)

	David
