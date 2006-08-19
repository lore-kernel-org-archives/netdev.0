From: Arnd Bergmann <arnd@arndb.de>
Subject: Re: [2.6.19 PATCH 4/7] ehea: ethtool interface
Date: Sat, 19 Aug 2006 15:47:11 +0200
Message-ID: <200608191547.12161.arnd@arndb.de>
References: <200608181333.23031.ossthema@de.ibm.com> <1155970112.7302.434.camel@tahini.andynet.net> <1155976887.1388.17.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-15"
Content-Transfer-Encoding: 7bit
Cc: Andy Gay <andy@andynet.net>, Thomas Klein <tklein@de.ibm.com>,
	Jan-Bernd Themann <themann@de.ibm.com>, netdev@vger.kernel.org,
	linux-kernel <linux-kernel@vger.kernel.org>,
	Thomas Klein <osstklei@de.ibm.com>,
	Christoph Raisch <raisch@de.ibm.com>,
	Marcus Eder <meder@de.ibm.com>,
	Alexey Dobriyan <adobriyan@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from moutng.kundenserver.de ([212.227.126.187]:16859 "EHLO
	moutng.kundenserver.de") by vger.kernel.org with ESMTP
	id S1751402AbWHSNr2 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 19 Aug 2006 09:47:28 -0400
To: linuxppc-dev@ozlabs.org, michael@ellerman.id.au
In-Reply-To: <1155976887.1388.17.camel@localhost.localdomain>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Saturday 19 August 2006 10:41, Michael Ellerman wrote:
> A lot of these have started appearing recently, which I think is due to
> GCC becoming more vocal. Unfortunately many of them are false positives
> caused by GCC not seeming to grok that this is ok:
> 
> void foo(int *x) { *x = 1; }
> ...
> int x;
> foo(&x);
> return x;
> 

It's more subtle than this, gcc only gets it wrong when multiple
things come together, the most common one seems to be:

- it tries to inline foo()
- foo has a path where it initializes *x and another one where it
  doesn't
- x is accessed after foo() returns, but only when foo indeed has
  initialized it.

The problem is that gcc now is more aggressive about inlining
functions. It used to assume that all functions initialize their
pointer arguments, now it does some more checking, but not enough,
so there are lots of false positives. Every gcc-4.x release seems
to fix some of these cases, but a few others remain.

	Arnd <><
