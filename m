From: jamal <hadi@cyberus.ca>
Subject: speaking of stacks
Date: Mon, 31 Mar 2008 09:15:56 -0400
Message-ID: <1206969356.4424.120.camel@localhost>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Joern Engel <joern@lazybastard.org>,
	David Miller <davem@davemloft.net>,
	Herbert Xu <herbert@gondor.apana.org.au>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from an-out-0708.google.com ([209.85.132.251]:7591 "EHLO
	an-out-0708.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754699AbYCaNQB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 31 Mar 2008 09:16:01 -0400
Received: by an-out-0708.google.com with SMTP id d31so430084and.103
        for <netdev@vger.kernel.org>; Mon, 31 Mar 2008 06:16:01 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


All this talk about stacks got me thirsty.
Heres something thats a mystery to me; probably very basic
when doing static check analysis (kernel make checkstack)

I have ipsec turned on in the linus git tree kernel and
net/xfrm/xfrm_user.c::xfrm_get_policy() shows up as one of
the top offenders. Eyeballing reveals that
struct xfrm_policy seems to be the offender 
in the else {} after if (p->index) in that function.
That seems understandable - once variable "tmp" is declared it goes
on the stack and it is freakin huge. 
However, checkstack only seems to catch it if i have the
line "memset(&tmp, 0, sizeof(struct xfrm_policy))". If i remove
that line - even though tmp is on the stack - checkstack doesnt catch
it.

What gives?

----
hadi@lilsol:~$ gcc -v
Using built-in specs.
Target: i486-linux-gnu
Configured with: ../src/configure -v --enable-languages=c,c
++,fortran,objc,obj-c++,treelang --prefix=/usr --enable-shared
--with-system-zlib --libexecdir=/usr/lib --without-included-gettext
--enable-threads=posix --enable-nls --program-suffix=-4.1
--enable-__cxa_atexit --enable-clocale=gnu --enable-libstdcxx-debug
--enable-mpfr --with-tune=i686 --enable-checking=release i486-linux-gnu
Thread model: posix
gcc version 4.1.2 20061115 (prerelease) (Debian 4.1.1-21)
-----

Not a gcc guru by far.
Anyone interested, I can send you the .o before and after commenting
for your perusal.

cheers,
jamal

